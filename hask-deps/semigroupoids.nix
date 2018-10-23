{ mkDerivation, base, base-orphans, bifunctors, Cabal
, cabal-doctest, comonad, containers, contravariant, distributive
, doctest, fetchgit, hashable, stdenv, tagged, template-haskell
, transformers, transformers-compat, unordered-containers
}:
mkDerivation {
  pname = "semigroupoids";
  version = "5.3.1";
  src = fetchgit {
    url = "http://github.com/ekmett/semigroupoids";
    sha256 = "02298fyys0ffchl402vgrj8nzigwpz8pr80j6madb5y4w8b25vlr";
    rev = "7d7f28c249fbd4352636448c9b4f90d60f400c7e";
    fetchSubmodules = true;
  };
  setupHaskellDepends = [ base Cabal cabal-doctest ];
  libraryHaskellDepends = [
    base base-orphans bifunctors comonad containers contravariant
    distributive hashable tagged template-haskell transformers
    transformers-compat unordered-containers
  ];
  testHaskellDepends = [ base doctest ];
  homepage = "http://github.com/ekmett/semigroupoids";
  description = "Semigroupoids: Category sans id";
  license = stdenv.lib.licenses.bsd3;
}
