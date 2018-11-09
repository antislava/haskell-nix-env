# Haskell nix development environment

**TODO: README needs updating after refactoring (2018-10-29)**

Simple haskell development environment based on `nix` and `make`.
To be used primarily for the incremental development using cabal new-repl/build, `ghcid`, etc.

**The main focus is on the ability to declare a working nix environment for a haskell project as quickly and easily as possible without sacrificing any of the flexibility provided by `nix`, as well as tag generation for the haskell dependencies.**. This is in contrast to the more pre-canned solutions, e.g. [styx](https://github.com/jyp/styx/). The workflow assumes basic experience with `nix` but does not rely on complex `nix` functions, which would make it less 'user-friendly'. For a good intro to developing haskell with nix, use [haskell-nix: Nix and Haskell in production](https://github.com/Gabriel439/haskell-nix).

*Note:* Currently assumes vi as the main editor (but not critical).

## Features and design priorities
* Avoiding multiple layers of nix functions, which would make it difficult to deeply customise the set-up
* Allowing declaration of the environment completely (in terms of dependencies) via [project.nix](./project.nix), the main [Makefile](./Makefile).
* Declaring haskell dependency declaraion and overrides in [haskell-dep-overrides.nix](./haskell-dep-overrides.nix), and per-package nix build formulas in [nix-deps](./nix-deps/) folder.

## Usage
* Add standard nix files for the target packages to work on. These are normally generated by `cabal2nix`. `haskell.vim` file provides a function for generating these automatically on saving the respective `hpack` `package.yaml` files. Package source directories can (and probably should) be in separate directories.
* Run `make nix/nixpkgs.git.json` to pull in the latest `nixpkgs` snapshot (`nixpkgs.git.json` should be added to the version control). Use `make -B` to update the existing snapshot.
* Specify target package nix files in [project.nix](./project.nix).
* Add haskell dependency overrides in [project.nix](./project.nix) and, if necessary, by providing custom nix files per package in [nix-deps](./nix-deps/) folder. Use [nix-deps/Makefile](./nix-deps/Makefile) rules to generate and update these in the future.
* Customise (add or subtract) dependencies to be pulled in into development nix shell and for tagging in [project.nix](./project.nix) if necessary
* Run e.g. `make shell86` to enter `ghc-8.6.1` development nix shell. Use `cabal new-*` or `ghci` for development.
  - `ghc-pkg-list_ghcXXX.txt` with the list of available haskell dependencies are generated on entering the shell. Add these to version control, if necessary for keeping track of the project dependencies.
* In the nix shell, run `make tags` to collect dependency sources (in `haskdeps` folder generated by nix) and generate the tag file.
* `make` rules in [Makefile](./Makefile) and [nix-deps/Makefile](./nix-deps/Makefile) are trivial and should be customised as necessary. Also, [project.nix](./project.nix) is meant to be significantly customised as a part of the workflow. These are the main configuration files for declaring the development environment.


## Adding haskell dependency overrides

If `shell-nix` reports errors (that cannot be easily resolved with `dontCheck` and `jailbreak` functions in [project.nix](./project.nix)) add custom nix files in [nix-deps](./nix-deps/) folder. The suggested way to do that is by adding `<package>.sh` file containing the required `cabal2nix` command, e.g.

```sh
cd ./nix-deps
echo "cabal2nix cabal://semigroupoids" > semigroupoids.sh
# or
echo "cabal2nix http://github.com/ekmett/semigroupoids" > semigroupoids.sh
# then
make semigroupoids.nix
```
and add the package name to [project.nix](./project.nix) override section.
Use `make -B <package>.nix` to update the nix file to the most recent version/commit (presuming the `<package>.nix` files are under version control and can be reverted if necessary.

**Tip:** The output of `cabal2nix cabal://<package>` usually contains the package github address if you would like to fetch the package from github (which is preferable from the point of view of reproducibility) and are too lazy to look it up on `hackage` or elsewhere.


## A note on `cabal new-* --build-depends` approach

In simple case, cabal new build can provide the fastest way to fire a working `ghci` with dependencies, e.g.

```sh
nix-shell -p "let nxpkgs = import <unstable> {}; in nxpkgs.haskell.packages.ghc861.ghcWithPackages (pkgs: with pkgs; [])"

cabal new-repl --build-depends lens
```

Unfortunately, this native cabal resolver uses a copious amount of memory, apparently growing exponentially with the number of dependencies. This makes it practically unusable for even a moderate package. Did not manage to start repl for the example application package used here (though got pretty close with 16GB RAM and quitting all other applications, see notes in [cabal-new-zero-conf-example.sh](./cabal-new-zero-conf-example.sh)). For now, this option seems limited to only quick initial idea testing and prototyping.

**Last but not least**, cabal solver generated a 2.5GB plan cache within local dist-newstyle (which is obviously not shared with other projects the way `nix` and `stack` resources are).
