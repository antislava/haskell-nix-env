{ mkDerivation, aeson, array, base, criterion, doctest, fetchgit
, ghc-prim, hspec, lens, lens-aeson, linear, microlens, mtl
, mwc-random, primitive, should-not-typecheck, singletons, stdenv
, tagged, text, unordered-containers, vector
}:
mkDerivation {
  pname = "vinyl";
  version = "0.10.0";
  src = fetchgit {
    url = "https://github.com/VinylRecords/Vinyl/";
    sha256 = "0rs6iyyl0wh8k84gy6yj2g47whk6l24dd0q7h2za9vl7fj9gsing";
    rev = "602f44c1b9ce2252b93582e7fd0cd1a2fe092e0c";
    fetchSubmodules = true;
  };
  libraryHaskellDepends = [ array base ghc-prim ];
  testHaskellDepends = [
    aeson base doctest hspec lens lens-aeson microlens mtl
    should-not-typecheck singletons text unordered-containers vector
  ];
  benchmarkHaskellDepends = [
    base criterion linear microlens mwc-random primitive tagged vector
  ];
  description = "Extensible Records";
  license = stdenv.lib.licenses.mit;
}
