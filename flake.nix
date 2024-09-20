{
  description = "py_temper_exporter";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/4cf7951a91440879f61e05460441762d59adc017";
    flake-utils.url = "github:numtide/flake-utils/c1dfcf08411b08f6b8615f7d8971a2bfa81d5e8a";
    pre-commit-hooks = {
      type = "github";
      owner = "cachix";
      repo = "git-hooks.nix";
      rev = "c7012d0c18567c889b948781bc74a501e92275d1";
    };

  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      pre-commit-hooks,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        checks = {
          pre-commit-check = pre-commit-hooks.lib.${system}.run {
            src = ./.;
            hooks = {
              dprint = {
                enable = true;
                name = "dprint check";
                entry = "dprint check --allow-no-files";
              };
              nixfmt = {
                enable = true;
                name = "nixfmt check";
                entry = "nixfmt -c ";
                types = [ "nix" ];
              };
            };
          };
        };

        devShells = {
          inherit (self.checks.${system}.pre-commit-check) shellHook;
          buildInputs = self.checks.${system}.pre-commit-check.enabledPackages;

          default = pkgs.mkShell {
            packages = with pkgs; [
              python3
              python312Packages.pyserial
              dprint
              nixfmt-rfc-style
            ];
          };
        };
      }
    );
}
