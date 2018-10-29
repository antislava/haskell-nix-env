nixpgks: compiler: pkgs:
let
  namesToNixPathAttrs = import ./nix-utils/namesToNixPathAttrs.nix;
  utils = builtins.mapAttrs (name: import)
  (namesToNixPathAttrs ./nix-utils [
    "namesToNixPathAttrs"
    "pathAttrsToHaskellOver"
  ]);
in with utils;
let
  composeExtensionsList =
         pkgs.lib.fold pkgs.lib.composeExtensions (_: _: {});
  nc   = pkgs.haskell.lib.dontCheck;
    jb = pkgs.haskell.lib.doJailbreak;
  ncjb = p: nc (jb p);
  generatedOverridesDeps =
    # :r! ls -1tr ./nix-deps-example | sed -rn 's|([^.]+).nix|"\1"|p;'
    pathAttrsToHaskellOver (namesToNixPathAttrs ./nix-deps-example ([
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
    ] else [ ])));
  manualOverrides = self: super: {
    turtle                  = nc   super.turtle;
    microlens-th            =   jb super.microlens-th;
    vinyl                   = ncjb super.vinyl;
    discrimination          = ncjb super.discrimination;
    Frames                  = nc   super.Frames;
    neat-interpolation      = nc   super.neat-interpolation;
  };
in
  composeExtensionsList [
    generatedOverridesDeps
    manualOverrides
  ]
