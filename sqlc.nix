{ pkgs, config, ... }:
let
  eachConfig = command: ''
    cd "${config.git.root}"
    git ls-files -z '*sqlc.yaml' | while IFS= read -r -d "" file; do
      (cd "$(dirname "$file")" && ${command})
    done
  '';
in
{
  config = {
    packages = [
      pkgs.sqlc
      pkgs.sqls
    ];

    tasks."codegen:sqlc" = {
      exec = eachConfig "sqlc generate";
      execIfModified = [
        "**/sqlc.yaml"
        "**/*.sql"
      ];
    };

    tasks."repo:lint:sqlc" = {
      exec = eachConfig "sqlc diff";
      before = [ "repo:lint" ];
    };
  };
}
