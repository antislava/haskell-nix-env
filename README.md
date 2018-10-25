# Haskell nix development environment

Simple haskell development environment based on `nix` and `make`.
To be used primarily for the incremental development using cabal new-[build/repl] and `ghcid`, etc.

**The main focus is on declarative approach minimising the time and effort spent on getting a working nix environment without sacrificing any of the flexibility provided by `nix`, as well as tag generation for the haskell dependencies.**. This is in contrast to the more pre-canned solutions, e.g. [styx: A nix-based Haskell project manager](https://github.com/jyp/styx/). The workflow assumes basic experience with `nix` but does not rely on complex `nix` functions, which would make it less 'user-friendly'. For a good intro to developing haskell with nix, use [haskell-nix: Nix and Haskell in production](https://github.com/Gabriel439/haskell-nix).

*Note:* Currently assumes vi as the main editor (but not critical).

## Features
* Simple/flexible/extensible setup (without multiple layers of nix functions).
* Allows declaring the nix shell environment completely via [default-flex.nix](./default-flex.nix), the main [Makefile](./Makefile), and the contents of the [hask-deps](./hask-deps/) folder.
* Minimises set-up time and time and effort needed to add dependency overrides in a way facilitating version control and reproducibility.
* Provides nix functions for generating tag file for code browsing.

## Usage
* Add standard nix files for the target packages to work on. These are normally generated by `cabal2nix`. `haskell.vim` file provides a function for generating these automatically on saving the respective `hpack` `package.yaml` files. Package source directories can (and probably should) be in separate directories.
* Run `make nix/nixpkgs.git.json` to pull in the latest `nixpkgs` snapshot (`nixpkgs.git.json` should be added to the version control). Use `make -B` to update the existing snapshot.
* Specify target package nix files in [default-flex.nix](./default-flex.nix).
* Add haskell dependency overrides in [default-flex.nix](./default-flex.nix) and, if necessary, by providing custom nix files per package in [hask-deps](./hask-deps/) folder. Use [hask-deps/Makefile](./hask-deps/Makefile) rules to generate and update these in the future.
* Customise (add or subtract) dependencies to be pulled in into development nix shell and for tagging in [default-flex.nix](./default-flex.nix) if necessary
* Run e.g. `make shell86` to enter `ghc-8.6.1` development nix shell. Use `cabal new-*` or `ghci` for development.
  - `ghc-pkg-list_ghcXXX.txt` with the list of available haskell dependencies are generated on entering the shell. Add these to version control, if necessary for keeping track of the project dependencies.
* In the nix shell, run `make tags` to collect dependency sources (in `haskdeps` folder generated by nix) and generate the tag file.
* `make` rules in [Makefile](./Makefile) and [hask-deps/Makefile](./hask-deps/Makefile) are trivial and should be customised as necessary. Also, [default-flex.nix](./default-flex.nix) is meant to be significantly customised as a part of the workflow. These are the main configuration files for declaring the development environment.


## Adding haskell dependency overrides

If `shell-nix` reports errors (that cannot be easily resolved with `dontCheck` and `jailbreak` functions in [default-flex.nix](./default-flex.nix)) add custom nix files in [hask-deps](./hask-deps/) folder. The suggested way to do that is by adding `<package>.sh` file containing the required `cabal2nix` command, e.g.

```sh
cd ./hask-deps
echo "cabal2nix cabal://semigroupoids" > semigroupoids.sh
# or
echo "cabal2nix http://github.com/ekmett/semigroupoids" > semigroupoids.sh
# then
make semigroupoids.nix
```
and add the package name to [default-flex.nix](./default-flex.nix) override section.
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
