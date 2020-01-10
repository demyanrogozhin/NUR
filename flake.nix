{
  description = "Nix User Repository";

  epoch = 201909;

  outputs = { self, nixpkgs }:
    let
      inherit (nixpkgs.lib) filterAttrs hasInfix mapAttrs toLower;

      system = "x86_64-linux";
      nurpkgs = import nixpkgs { inherit system; };
      nurNoPkgs = import ./default.nix { inherit nurpkgs; };
    in {
      overlay = final: prev: {
        nur = import ./default.nix {
          nurpkgs = prev;
          pkgs = final;
        };
      };

      nixosModules = let
        onlyModules =
          mapAttrs (_: v: filterAttrs (n: _: hasInfix "modules" (toLower n)) v)
          nurNoPkgs.repos;
      in onlyModules;

      overlays = let
        onlyOverlays =
          mapAttrs (_: v: filterAttrs (n: _: hasInfix "overlays" (toLower n)) v)
          nurNoPkgs.repos;
      in onlyOverlays;
    };
}
