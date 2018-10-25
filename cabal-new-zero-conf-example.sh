nix-shell -p "let nxpkgs = import <unstable> {}; in nxpkgs.haskell.packages.ghc861.ghcWithPackages (pkgs: with pkgs; [])"

# Small example works just fine!
cabal new-repl all \
  --build-depends singletons \
  --build-depends QuickCheck \
  --build-depends containers \
  --build-depends template-haskell \
  --build-depends th-lift-instances \
  --build-depends parsec \
  --build-depends HUnit \
  --build-depends dlist


# Somewhat bigger set (example project):
# Cabal solver uses the insane amount of memory (which apparently grows exponentially with the number of dependencies) and crashes. (16GB RAM and quitting all other application helps.) Also, the solver created a 2.5GB cache folder inside the dist-newstyle(!)
cabal new-repl all \
  --build-depends bytestring \
  --build-depends text \
  --build-depends containers \
  --build-depends unordered-containers \
  --build-depends hashable \
  --build-depends aeson \
  --build-depends aeson-pretty \
  --build-depends microlens \
  --build-depends microlens-th \
  --build-depends microlens-platform \
  --build-depends microlens-aeson \
  --build-depends time \
  --build-depends errors \
  --build-depends either \
  --build-depends vinyl \
  --build-depends Frames \
  --build-depends singletons \
  --build-depends turtle \
  --build-depends foldl \
  --build-depends path \
  --build-depends path-io \
  --build-depends filepath \
  --build-depends directory \
  --build-depends system-filepath \
  --build-depends system-fileio \

# Didn't manage to add the next dependency :(
#   --build-depends neat-interpolation
