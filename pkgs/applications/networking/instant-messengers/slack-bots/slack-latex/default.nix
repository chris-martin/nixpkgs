{ lib, stdenv, fetchFromGitHub, makeWrapper
, python3Packages, imagemagick, texlive
}:

let
  name = "slack-latex-2017-08-16";

  meta = {
    description = "Slack bot for rendering LaTeX formulas";
    homepage = https://github.com/chris-martin/slacklatex;
  };

  src-tmp = fetchFromGitHub {
    owner = "chris-martin";
    repo = "slacklatex";
    rev = "11bd0f6067d624f8c4bf4acb5dbc5bee003973c2";
    sha256 = "100w2413fiwkkrw7xa4aq3cf7ki4sy7zlfpg1nbx3cxawzygqhdz";
  };

  src = /home/chris/code/slacklatex;

  deps = [ python-env latex imagemagick ];

  python-env = python3Packages.python.buildEnv.override {
    extraLibs = with python3Packages; [ flask requests ];
  };

  latex = texlive.combine {
    inherit (texlive)
      scheme-basic jknapltx amsmath standalone xkeyval preview rsfs metafont;
  };

  buildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p "$out/bin"
    cp "$src/template.tex" "$out/template.tex"
    cp "$src/main.py" "$out/bin/slack-latex"
    wrapProgram "$out/bin/slack-latex" \
      --prefix PATH : "${lib.makeBinPath deps}" \
      --add-flags "--template-file $out/template.tex"
  '';

in

  stdenv.mkDerivation { inherit name src meta buildInputs installPhase; }
