{ nixpkgs ? import ((import <nixpkgs> {}).fetchFromGitHub {
    owner = "NixOS";
    repo = "nixpkgs";
    rev = "692a8cabbcc540b75c6275e4458fee6aaa20b1e6";
    sha256 = "02ifbwp2iwzavig5xnfs5s43ip7prx70lkxcy794b4vav37mlb6q";
  }) {}
}: with nixpkgs;

let
  beamPackages = [
    "beam-core"
    "beam-migrate"
    "beam-migrate-cli"
    "beam-postgres"
    "beam-sqlite"
  ];
  ghcVersions = [
    "ghc844"
    "ghc865"
    # TODO: Add GHC 8.8 once sqlite-simple is updated.
  ];
  hackageVersions = {
    postgresql-libpq = "0.9.4.2";
  };

  composeExtensionList = lib.foldr lib.composeExtensions (_: _: {});
  mergeMaps = lib.foldr (a: b: a // b) {};
  applyToPackages = f: packages: _: super: lib.genAttrs packages
    (name: f super."${name}");

  mkPackageSet = ghc: ghc.extend (composeExtensionList [
    (self: _: lib.mapAttrs (n: v: self.callHackage n v {}) hackageVersions)
    (self: _: lib.genAttrs beamPackages (name:
      self.callCabal2nix name (./. + "/${name}") {}
    ))
    (applyToPackages haskell.lib.dontCheck [
      "aeson"
      "beam-postgres" # TODO: Add postgres dependency to run tests.
    ])
  ]);
  mkPrefixedPackages = version: lib.mapAttrs'
    (name: value: lib.nameValuePair "${version}_${name}" value)
    (lib.genAttrs beamPackages
      (name: (mkPackageSet haskell.packages."${version}")."${name}")
    );

in mergeMaps (map mkPrefixedPackages ghcVersions)

