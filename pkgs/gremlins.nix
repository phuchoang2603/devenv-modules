{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule rec {
  pname = "gremlins";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "go-gremlins";
    repo = "gremlins";
    rev = "v${version}";
    hash = "sha256-QwMj7aA4eafMT25gBLAomZMliCbueoEsDHD/nxtnmk4=";
  };

  vendorHash = "sha256-TYbbDN2V6GLj+YRNQIKggCnNspk3M96cP1DSe8P9qlY=";
  subPackages = [ "cmd/gremlins" ];
  doCheck = false;

  meta = {
    description = "Mutation testing for Go";
    homepage = "https://github.com/go-gremlins/gremlins";
    license = lib.licenses.asl20;
    mainProgram = "gremlins";
  };
}
