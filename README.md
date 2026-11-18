# devenv-modules

Shared [devenv](https://devenv.sh) modules, ast-grep rules and CI for my projects.

```yaml
# devenv.yaml
inputs:
  nixpkgs:
    url: github:cachix/devenv-nixpkgs/rolling
  devenv-modules:
    url: github:phuchoang2603/devenv-modules
    flake: false
  git-hooks:
    url: github:cachix/git-hooks.nix
    inputs:
      nixpkgs:
        follows: nixpkgs
  treefmt-nix:
    url: github:numtide/treefmt-nix
    inputs:
      nixpkgs:
        follows: nixpkgs
```

```nix
# devenv.nix
{ inputs, ... }:
{
  imports = map (m: "${inputs.devenv-modules}/${m}.nix") [ "base" "go" "python" ];
}
```

| Module | Provides |
|---|---|
| `base` | treefmt and git hook, nixfmt, actionlint, ast-grep, conftest; `repo:lint` runs the shared rules then `scripts/lint.sh`; `repo:check` runs `scripts/check.sh` after `repo:lint` |
| `go` | Go toolchain, golangci-lint, gofumpt, gremlins with `repo.gremlins.enable`; `.golangci.yml` generated from `repo.golangci` over a shared base (gitignore it) |
| `python` | Python 3.12 by default, uv with one `.venv` per project, ruff, tzdata |
| `sqlc` | sqlc, sqls; `codegen:sqlc` runs `sqlc generate` beside every `sqlc.yaml`, and `repo:lint` fails when generated code is stale (`sqlc diff`) |
| `kubernetes` | Helm, kubectl |
| `opentofu` | OpenTofu |

Each project provides `scripts/lint.sh` (static checks, no tests) and an optional `scripts/check.sh` (tests and anything else CI runs). Project-specific ast-grep rules go in a root `sgconfig.yml` and Rego policies in `policy/`; the shared rules skip files marked `linguist-generated` in `.gitattributes`.

CI runs the same tasks inside devenv:

```yaml
jobs:
  check:
    uses: phuchoang2603/devenv-modules/.github/workflows/devenv.yml@main
    with:
      run: devenv tasks run repo:check
```

The workflow restores the Go build and module caches and the Maven repository on every run, keyed by `cache-key` (pass one per matrix entry) and the `go.sum`/`pom.xml` hashes; only `main` saves them. It also takes `fetch-depth`, `timeout-minutes`, `cache-path`/`cache-key`/`cache-hash-files` for extra caches, and `artifact-name`/`artifact-path` to upload results even when the run fails.

Update a project with `devenv update devenv-modules`. To try local changes first, run `devenv shell --override-input devenv-modules path:../devenv-modules`.
