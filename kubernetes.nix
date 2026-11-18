{ pkgs, ... }:
{
  languages.helm = {
    enable = true;
    lsp.enable = true;
  };

  packages = [ pkgs.kubectl ];
}
