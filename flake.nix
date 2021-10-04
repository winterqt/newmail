{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }: flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      packages.newmail = pkgs.callPackage
        ({ lib, stdenv, rustPlatform, Security, auth ? "", domain ? "", mailbox ? "" }: rustPlatform.buildRustPackage {
          pname = "newmail";
          version = (lib.importTOML ./Cargo.toml).package.version;

          src = ./.;

          cargoLock = {
            lockFile = ./Cargo.lock;
          };

          buildInputs = lib.optionals stdenv.isDarwin [ Security ];

          MIGADU_AUTH = auth;
          MIGADU_DOMAIN = domain;
          MIGADU_MAILBOX = mailbox;
        })
        { Security = pkgs.darwin.apple_sdk.frameworks.Security; };

      devShell = pkgs.mkShell {
        nativeBuildInputs = with pkgs; [ rustc cargo ] ++ lib.optionals stdenv.isDarwin [ libiconv darwin.apple_sdk.frameworks.Security ];
      };
    }
  );
}
