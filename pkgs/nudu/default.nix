{
  fetchFromGitHub,
  lib,
  rustPlatform,
}:

rustPlatform.buildRustPackage rec {
  pname = "nudu";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "qempexe";
    repo = "nudu";
    rev = "v${version}";
    hash = "sha256-3zi8LHKR4yAwtAs6ySnHttFAwtjYvPni68+6Ql1dFc8=";
  };

  cargoHash = "sha256-cjs4W22w39CocdViOD/6foSLDS6zkULq9RvRwov6Dow=";

  meta = {
    description = "Fast terminal disk usage analyzer with filesystem-aware sizes";
    homepage = "https://github.com/qempexe/nudu";
    license = lib.licenses.mit;
    mainProgram = "nudu";
    platforms = lib.platforms.linux;
  };
}
