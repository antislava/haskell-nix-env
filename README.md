# Basic haskell nix development environment

Simple haskell development environment based on nix and make.
To be used promarily for the incremental development using cabal new-[build/repl] and ghcid.
Currently assumes vi as the main editor (but not critical).

## Features
* Simple/flexible/extensible setup (without multiple layers of nix functions)
* Minimises set-up time and time and effort needed to add dependency overrides in a way facilitating version control and reproducibility
* Provides nix functions for generating tag file for code for browsing
