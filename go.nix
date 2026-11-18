{
  pkgs,
  lib,
  config,
  ...
}:
let
  yaml = pkgs.formats.yaml { };
in
{
  options.repo.golangci = lib.mkOption {
    inherit (yaml) type;
    default = { };
    description = "golangci-lint v2 configuration, merged over the shared base and written to .golangci.yml.";
  };

  config = {
    languages.go = {
      enable = true;
      delve.enable = true;
      lsp.enable = true;
    };

    packages = [ pkgs.golangci-lint ];

    repo.golangci = {
      version = "2";
      run.tests = lib.mkDefault true;
      linters = {
        default = lib.mkDefault "standard";
        enable = [
          "errorlint"
          "unconvert"
          "unparam"
          "usestdlibvars"
        ];
      };
      formatters.enable = [ "gofumpt" ];
      formatters.settings.gofumpt.extra = {
        group-params = true;
        clothe-returns = true;
      };
      issues = {
        max-issues-per-linter = 0;
        max-same-issues = 0;
      };
    };

    files.".golangci.yml".yaml = config.repo.golangci;

    treefmt.config.programs.gofumpt = {
      enable = true;
      extra = true;
    };
  };
}
