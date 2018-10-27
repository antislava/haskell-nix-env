{ compiler ? "ghc861"
, withHoogle ? true
}:

# USAGE: nix-shell default-flex.nix -A shell --argstr compiler "ghc843"
let
  fetchNixpkgs            = import ./nix-utils/fetchNixpkgs.nix;
  readDirectory           = import ./nix-utils/readDirectory.nix;
  callFromDirectory       = import ./nix-utils/callFromDirectory.nix;
  unpack                  = import ./nix-utils/do-unpack-source.nix;
  extract-haskell-sources = import ./nix-utils/extract-haskell-sources.nix;
  nixpkgs-git = builtins.fromJSON (builtins.readFile ./nix/nixpkgs.git.json);
  nixpkgs = fetchNixpkgs { inherit (nixpkgs-git) rev sha256; };

  # Targets: generally assuming multiple packages/cabal.project
  target-paths = [ ./example-package.nix ];
  target-names = map (p:
      builtins.replaceStrings [ ".nix" ] [ "" ] (
        pkgs.lib.lists.last
          (pkgs.lib.strings.splitString "/" (builtins.toString p)))
    ) target-paths;
  target-pkgs = callFromDirectory ./. target-names;

  config = {
    allowBroken = true;
    packageOverrides = pkgs:
    let
      composeExtensionsList =
             pkgs.lib.fold pkgs.lib.composeExtensions (_: _: {});
      jb   = pkgs.haskell.lib.doJailbreak;
      nc   = pkgs.haskell.lib.dontCheck;
      ncjb = p: nc (jb p);
      nh   = pkgs.haskell.lib.dontHaddock;
    in rec {
      haskell = pkgs.haskell // {
        packages = pkgs.haskell.packages // {
          "${compiler}" = pkgs.haskell.packages."${compiler}".override {
            overrides =
              let
                generatedOverridesDeps = callFromDirectory ./hask-deps ([
                # :r! ls -1tr ./hask-deps | sed -rn 's|([^.]+).nix|"\1"|p;'
                  "turtle"
                  "vinyl"
                  "Frames"
                  "pipes-safe"
                ]
                ++
                (if "${compiler}" >= "ghc861" then [
                  "semigroupoids"
                  "singletons"
                  "th-desugar"
                ] else [ ]));
                manualOverrides = self: super:
                let o = super; in {
                  turtle                  = nc   o.turtle;
                  microlens-th            =   jb o.microlens-th;
                  vinyl                   = ncjb o.vinyl;
                  discrimination          = ncjb o.discrimination;
                  Frames                  = nc   o.Frames;
                  neat-interpolation      = nc   o.neat-interpolation;

                  # USED ONLY FOR SOURCE EXTRACTION/TAGGING
                  # base_4_11_1_0 = o.callPackage (import ./hask-deps/base_4_11_1_0.nix) { invalid-cabal-flag-settings = null; };
                };
              in
                composeExtensionsList [
                  target-pkgs
                  generatedOverridesDeps
                  manualOverrides
                ];
          };
        };
      };
    };
  };

  pkgs = import nixpkgs { inherit config; };

  getHaskellDeps = import ./nix-utils/query-haskell-package.nix pkgs;

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

  # ghc environment for the development nix shell
  ghcWithDepsFunc = if withHoogle
    then pkgs.haskell.packages.${compiler}.ghcWithHoogle
    else pkgs.haskell.packages.${compiler}.ghcWithPackages;

  ghcWithDeps = ghcWithDepsFunc (ps: with ps;
    pkgs.stdenv.lib.lists.subtractLists
      target-names # all target packages subtracted
      ( [ ] # possible extras packages (for testing in ghci)
      ++ [ ghcid fast-tags ] # shell tools
      ++ pkgs.lib.concatMap (getHaskellDeps gatherDepsAll ps) target-paths
      )
    );

  # (!) This ghc environment is not for using in shell but for extracting dep list for tagging/indexing
  ghcWithDepsTags = pkgs.haskell.packages.${compiler}.ghcWithPackages (ps: with ps;
    pkgs.stdenv.lib.lists.subtractLists
      target-names # all target packages subtracted
      ( [ # possible extra packages (to be indexed for tagging/browsing)
        ]
      ++ pkgs.lib.concatMap (getHaskellDeps gatherDepsCore ps) target-paths
      )
    );
  src-paths = builtins.filter (builtins.hasAttr "pname") ghcWithDepsTags.paths;
  src-paths-core = builtins.filter (p: !(builtins.hasAttr "pname" p)) ghcWithDepsTags.paths;
  package-srcs =
    # map (p: {src = p.src.outPath; nm = p.name;}) ghcpkgs.paths
    map (p: {src = "${unpack p pkgs}"; nm = p.name;}) src-paths;

in
  with pkgs.haskell.packages."${compiler}";
  {
    # TAGS
    haskell-sources = extract-haskell-sources pkgs package-srcs;

    # SHELLS
    shell-simple = example-package.env;
    # shell-simple-bench = (pkgs.haskell.lib.doBenchmark turtle).env;
    shell = pkgs.stdenv.mkDerivation {
      name = "weba-table-servant-env";
      buildInputs = [ ghcWithDeps ];
      shellHook = ''
 export LANG=en_US.UTF-8
 eval $(egrep ^export ${ghcWithDeps}/bin/ghc)
 # export WDATA="/DATA"     # Various project env vars
 export GHC_VER=${compiler} # Used by package source extraction build
 echo ${ghcWithDeps}
'';};
    tagshell = pkgs.stdenv.mkDerivation {
      name = "weba-table-servant-env";
      buildInputs = [ ghcWithDepsTags ];
      shellHook = ''
 export LANG=en_US.UTF-8
 eval $(egrep ^export ${ghcWithDeps}/bin/ghc)
 # export WDATA="/DATA"     # Various project env vars
 export GHC_VER=${compiler} # Used by package source extraction build
 echo ${ghcWithDeps}
'';};
    # Used for inspecting in nix-repl:
    inherit pkgs;
    inherit src-paths;
    inherit src-paths-core;
    inherit package-srcs;
    inherit ghcWithDeps;
    inherit ghcWithDepsTags;

    # Example test shell for the incremental development of the dependency overrides (compatibilitiy testing)
    shell-test = ghcWithPackages (ps: with ps; [
      semigroupoids patience polyparse vector-binary-instances
      haskell-src-exts criterion monad-par
    ]);
  }
