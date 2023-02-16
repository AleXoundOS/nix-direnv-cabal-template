let
  pkgs2211path = builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/cbe419ed4c8f98bd82d169c321d339ea30904f1f.tar.gz";
    sha256 = "0l6lipg37mzpajiik2rlm4whm53xn3bi0317wdqdwip8dz30sj1h";
  };
  pkgs = import pkgs2211path { };
in
pkgs.haskellPackages.developPackage {
  root = ./.;
  modifier = drv:
    pkgs.haskell.lib.addBuildTools drv (with pkgs.haskellPackages; [
      cabal-install
      ghcid
    ]);
}
