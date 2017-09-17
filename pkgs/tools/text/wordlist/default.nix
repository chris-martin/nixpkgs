{ fetchurl, fetchFromGitHub, haskell, makeWrapper, stdenv, ... }:

let

  trezor-rev = "ec21884db9f3af236732121e7ccf97435b924915";

  data = fetchurl {
    url = "https://raw.githubusercontent.com/trezor/python-mnemonic/" +
          trezor-rev + "/mnemonic/wordlist/english.txt";
    sha256 = "1nnv4hxyv8pkxzw9yvb40f2yb47wkqckz3qdi3w4nyvjli9yspig";
  };

  src = fetchFromGitHub {
    owner = "chris-martin";
    repo = "wordlist";
    rev = "492e26fa4fdf5bda4ef3ea15939a0bc191fcbb71";
    sha256 = "1q5isydifcfjp5bykg15p46vvx8223bx166pi30znl5v6mb4ajw1";
  };

  haskellAndPackages = haskell.packages.ghc802.ghcWithPackages (p: with p; [
    base containers MonadRandom optparse-applicative stdenv text
    ghc cabal-install hpack
  ]);

in stdenv.mkDerivation {
  name = "wordlist";
  inherit src;
  buildInputs = [ makeWrapper haskellAndPackages ];
  installPhase = ''
    hpack
    HOME="$TMP" cabal build
    mkdir -p $out/bin
    cp ./dist/build/wordlist/wordlist $out/bin
    wrapProgram $out/bin/wordlist --set WORD_LIST_PATH ${data}
  '';
}
