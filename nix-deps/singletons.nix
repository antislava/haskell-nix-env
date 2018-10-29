{ mkDerivation, base, Cabal, containers, directory, fetchgit
, filepath, ghc-boot-th, mtl, pretty, process, stdenv, syb, tasty
, tasty-golden, template-haskell, text, th-desugar, transformers
}:
mkDerivation {
  pname = "singletons";
  version = "2.5";
  src = fetchgit {
    url = "http://www.github.com/goldfirere/singletons";
    sha256 = "10x3bfbzlh5i5vg94g9kcnv0wp0xc732vslrxs9czdbidddlxk0h";
    rev = "fcbf6019077cc5f931a1023e3451a8a41ff44bdb";
    fetchSubmodules = true;
  };
  setupHaskellDepends = [ base Cabal directory filepath ];
  libraryHaskellDepends = [
    base containers ghc-boot-th mtl pretty syb template-haskell text
    th-desugar transformers
  ];
  testHaskellDepends = [ base filepath process tasty tasty-golden ];
  homepage = "http://www.github.com/goldfirere/singletons";
  description = "A framework for generating singleton types";
  license = stdenv.lib.licenses.bsd3;
}
