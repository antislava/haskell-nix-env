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
    # :r! ls -1tr ./nix-deps | sed -rn 's|([^.]+).nix|"\1"|p;'
    pathAttrsToHaskellOver (namesToNixPathAttrs ./nix-deps ([
      # "turtle"
    ]
    ++
    (if "${compiler}" >= "ghc861" then [
      # "semigroupoids"
    ] else [ ])));
  manualOverrides = self: super: {
    # neat-interpolation      = nc   super.neat-interpolation;
    # microlens-th            =   jb super.microlens-th;
    # vinyl                   = ncjb super.vinyl;
  };
in
  composeExtensionsList [
    generatedOverridesDeps
    manualOverrides
  ]
