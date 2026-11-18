{ pkgs, config, ... }:
{
  config = {
    packages = [
      pkgs.buf
      pkgs.protobuf
      pkgs.protoc-gen-go
      pkgs.protoc-gen-go-grpc
      pkgs.protols
    ];

    tasks."codegen:proto" = {
      exec = ''
        cd "${config.git.root}"
        buf generate
      '';
      execIfModified = [
        "**/*.proto"
        "buf.yaml"
        "buf.gen.yaml"
      ];
    };

    tasks."repo:lint:proto" = {
      exec = ''
        cd "${config.git.root}"
        buf lint
        generated="$(mktemp -d)"
        trap 'rm -rf "$generated"' EXIT
        buf generate --output "$generated"
        stale=0
        while IFS= read -r -d "" file; do
          if ! cmp -s "$generated/$file" "$file"; then
            echo "stale generated code: $file (run devenv tasks run codegen:proto)" >&2
            stale=1
          fi
        done < <(cd "$generated" && find . -type f -printf '%P\0')
        exit "$stale"
      '';
      before = [ "repo:lint" ];
    };

    treefmt.config = {
      programs.buf.enable = true;
      settings.global.excludes = [ "*.pb.go" ];
    };
  };
}
