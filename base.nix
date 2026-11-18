{
  pkgs,
  lib,
  config,
  ...
}:
let
  rules = lib.fileset.toSource {
    root = ./.;
    fileset = lib.fileset.unions [
      ./sgconfig.yml
      ./rules
    ];
  };
  sharedLint = pkgs.writeShellApplication {
    name = "repo-lint-shared";
    runtimeInputs = [
      pkgs.ast-grep
      pkgs.git
    ];
    text = ''
      cd "${config.git.root}"
      args=()
      while IFS= read -r -d "" path && IFS= read -r -d "" _ && IFS= read -r -d "" value; do
        if [[ "$value" == true ]]; then
          args+=("--globs=!$path")
        fi
      done < <(git ls-files -z | git check-attr -z --stdin linguist-generated)
      ast-grep scan --config ${rules}/sgconfig.yml "''${args[@]}" .
      if [[ -f sgconfig.yml ]]; then
        ast-grep scan .
      fi
    '';
  };
in
{
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

    tasks."repo:worktree-hooks" = {
      exec = ''
        git_dir="$(git -C "${config.devenv.root}" rev-parse --path-format=absolute --git-dir 2>/dev/null)" || exit 0
        git -C "${config.devenv.root}" config extensions.worktreeConfig true
        git -C "${config.devenv.root}" config --worktree core.hooksPath "$git_dir/hooks"
      '';
      before = [ "devenv:git-hooks:install" ];
    };

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
