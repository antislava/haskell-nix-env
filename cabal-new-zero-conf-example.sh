nix-shell -p "let nxpkgs = import <unstable> {}; in nxpkgs.haskell.packages.ghc861.ghcWithPackages (pkgs: with pkgs; [])"

# NOTE: Cabal resolver uses an insane amount of memory (which apparently grows exponentially with the number of dependencies) and crashes. (16gb RAM and quitting all other application helps! ;-) )
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

# Didn't manage to add the next dependency even incrementally
#   --build-depends neat-interpolation
