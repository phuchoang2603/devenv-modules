{
  pkgs,
  lib,
  ...
}:
{
  languages.python = {
    enable = true;
    package = lib.mkDefault pkgs.python312;
    lsp.enable = true;
  };

  packages = [
    pkgs.uv
    pkgs.ruff
    pkgs.tzdata
  ];

  env = {
    UV_PYTHON_DOWNLOADS = "never";
    UV_PYTHON_PREFERENCE = "only-system";
    TZDIR = "${pkgs.tzdata}/share/zoneinfo";
  };

  treefmt.config.programs.ruff-format.enable = true;
}
