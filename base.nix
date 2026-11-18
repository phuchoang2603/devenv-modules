{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.repo;
  rules = lib.fileset.toSource {
    root = ./.;
    fileset = lib.fileset.unions [
      ./sgconfig.yml
      ./rules
    ];
  };
  sharedLint = pkgs.writeShellApplication {
    name = "repo-lint-shared";
    runtimeInputs = [ pkgs.ast-grep ];
    text = ''
      cd "${config.git.root}"
      ast-grep scan --config ${rules}/sgconfig.yml ${
        lib.concatMapStringsSep " " (glob: lib.escapeShellArg "--globs=!${glob}") cfg.lintIgnores
      } .
      if [[ -f sgconfig.yml ]]; then
        ast-grep scan .
      fi
    '';
  };
in
{
  options.repo.lintIgnores = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [ ];
    description = "Globs the shared ast-grep rules skip, for generated files without a generated-code header.";
  };

  config = {
    packages = [
      sharedLint
      pkgs.ast-grep
      pkgs.conftest
      pkgs.jq
    ];

    treefmt = {
      enable = true;
      config.programs = {
        nixfmt.enable = true;
        actionlint.enable = true;
      };
    };
    git-hooks.hooks.treefmt.enable = true;

    tasks."repo:lint".exec = ''
      repo-lint-shared
      bash "${config.git.root}/scripts/lint.sh"
    '';
    tasks."repo:check" = {
      exec = ''
        if [[ -f "${config.git.root}/scripts/check.sh" ]]; then
          bash "${config.git.root}/scripts/check.sh"
        fi
      '';
      after = [ "repo:lint" ];
    };
  };
}
