{ compiler ? "ghc861"
, withHoogle ? true
, targets # ? [] Somewhat error-prone
}:
# USAGE: nix-shell project.nix --arg targets [./example-package.nix] --argstr compiler ghc843 -A shell

let
  namesToNixPathAttrs = import ./nix-utils/namesToNixPathAttrs.nix;
  utils = builtins.mapAttrs (name: import)
  (namesToNixPathAttrs ./nix-utils [
    "fetchNixpkgs"
    "pathAttrsToHaskellOver"
    "nixPathsToAttrs"
    "queryHaskellPackage"
    "doUnpackSource"
    "extractHaskellSources"
  ]);
in with utils;
let
  # NIXPKGS
  nixpkgs-git = builtins.fromJSON (builtins.readFile ./nix/nixpkgs.git.json);
  nixpkgs = fetchNixpkgs { inherit (nixpkgs-git) rev sha256; };

  # TARGETS: generally assuming multiple packages/cabal.project
  target-paths = targets;
  target-attrs = nixPathsToAttrs target-paths;
  target-names = builtins.attrNames target-attrs;
  target-overr = pathAttrsToHaskellOver target-attrs;

  # CONFIG
  config = {
    allowBroken = true;
    packageOverrides = pkgs:
    { haskell = pkgs.haskell // {
        packages = pkgs.haskell.packages // {
          "${compiler}" = pkgs.haskell.packages."${compiler}".override {
            overrides = pkgs.lib.composeExtensions
              target-overr
              (import ./haskell-dep-overrides.nix nixpkgs compiler pkgs);
          };
        };
      };
    };
  };

  pkgs = import nixpkgs { inherit config; };

  getHaskellDeps = queryHaskellPackage pkgs;

  gatherDepsAll = # Deps for nix shell
    { buildDepends ? []
    , libraryHaskellDepends ? []
    , executableHaskellDepends ? []
    , libraryToolDepends ? []
    , executableToolDepends ? []
    , testHaskellDepends ? []
    , ...}:
    buildDepends ++ libraryHaskellDepends ++ executableHaskellDepends ++ libraryToolDepends ++ executableToolDepends ++ testHaskellDepends;

  gatherDepsCore = # Deps for source tagging
    { libraryHaskellDepends ? []
    , executableHaskellDepends ? []
    , testHaskellDepends ? []
    , ...}:
    libraryHaskellDepends ++ executableHaskellDepends ++ testHaskellDepends;

  # GHC environment for the development nix shell
  ghcWithDepsFunc = with pkgs.haskell.packages.${compiler};
    if withHoogle then ghcWithHoogle
                  else ghcWithPackages;

  ghcWithDeps = ghcWithDepsFunc (ps: with ps;
    pkgs.stdenv.lib.lists.subtractLists
      target-names # all target packages subtracted
      ( pkgs.lib.concatMap (getHaskellDeps gatherDepsAll ps) target-paths
        ++ [ # standard shell tools
             ghcid fast-tags hlint
           ]
        ++ [ # possible extras packages (for testing in ghci)
           ]
      )
    );

  # (!) This GHC environment is not for using in shell but for extracting dep list for tagging/indexing
  ghcWithDepsTags = pkgs.haskell.packages.${compiler}.ghcWithPackages (ps: with ps;
    pkgs.stdenv.lib.lists.subtractLists
      target-names # all target packages subtracted
      ( pkgs.lib.concatMap (getHaskellDeps gatherDepsCore ps) target-paths
        ++ [ # possible extra packages (fir indexing/tagging)
           ]
      )
    );
  src-paths =
    if   builtins.hasAttr "paths" ghcWithDepsTags
    then builtins.filter (builtins.hasAttr "pname") ghcWithDepsTags.paths
    else [];
  package-srcs =
    map (p: {src = "${doUnpackSource p pkgs}"; nm = p.name;}) src-paths;

in
  with pkgs.haskell.packages."${compiler}";
  {
    # TAGS
    haskell-sources = extractHaskellSources pkgs package-srcs;
    # SHELLS
    shell-simple = example-package.env;
    # shell-simple-bench = (pkgs.haskell.lib.doBenchmark turtle).env;
    shell = pkgs.stdenv.mkDerivation {
      name = "haskell-nix-env";
      buildInputs = [ ghcWithDeps ];
      shellHook = ''
 export LANG=en_US.UTF-8
 # export WDATA="/DATA"     # Project env vars
 export GHC_VER=${compiler} # Used by package source extraction build
 eval $(egrep ^export ${ghcWithDeps}/bin/ghc)
 echo ${ghcWithDeps}
'';};
    # Example test shell for the incremental development of the dependency overrides (compatibilitiy testing). No target packages
    shell-test-example = ghcWithPackages (ps: with ps; [
      semigroupoids criterion monad-par
    ]);
  }