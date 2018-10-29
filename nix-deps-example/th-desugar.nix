{ mkDerivation, base, containers, fetchgit, hspec, HUnit, mtl
, stdenv, syb, template-haskell, th-expand-syns, th-lift
, th-orphans
}:
mkDerivation {
  pname = "th-desugar";
  version = "1.9";
  src = fetchgit {
    url = "https://github.com/goldfirere/th-desugar";
    sha256 = "192dx6fwldlbpdr8rr4qwhsymj4dqv7fglr5h9r1md8jmy3z03z0";
    rev = "200be2ec175b3f924d9170a55c675528eeedcd9e";
    fetchSubmodules = true;
  };
  libraryHaskellDepends = [
    base containers mtl syb template-haskell th-expand-syns th-lift
    th-orphans
  ];
  testHaskellDepends = [
    base containers hspec HUnit mtl syb template-haskell th-expand-syns
    th-lift th-orphans
  ];
  homepage = "https://github.com/goldfirere/th-desugar";
  description = "Functions to desugar Template Haskell";
  license = stdenv.lib.licenses.bsd3;
}
