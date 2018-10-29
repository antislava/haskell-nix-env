{ mkDerivation, attoparsec, base, bytestring, containers
, contravariant, criterion, deepseq, directory, discrimination
, fetchgit, foldl, ghc-prim, hashable, hspec, htoml, HUnit, lens
, pipes, pipes-bytestring, pipes-group, pipes-parse, pipes-safe
, pretty, primitive, readable, regex-applicative, stdenv
, template-haskell, temporary, text, transformers
, unordered-containers, vector, vector-th-unbox, vinyl
}:
mkDerivation {
  pname = "Frames";
  version = "0.6.0";
  src = fetchgit {
    url = "http://github.com/acowley/Frames";
    sha256 = "1w2ldc70gl4pc6ly0lh3z04xcijbgdrbrqlcv972x2x4q76yik1w";
    rev = "ddc6474a8cdae5371f83d518b9d7905bdea9c8d8";
    fetchSubmodules = true;
  };
  isLibrary = true;
  isExecutable = true;
  libraryHaskellDepends = [
    base bytestring containers contravariant deepseq discrimination
    ghc-prim hashable pipes pipes-bytestring pipes-group pipes-parse
    pipes-safe primitive readable template-haskell text transformers
    vector vector-th-unbox vinyl
  ];
  testHaskellDepends = [
    attoparsec base directory foldl hspec htoml HUnit lens pipes pretty
    regex-applicative template-haskell temporary text
    unordered-containers vinyl
  ];
  benchmarkHaskellDepends = [ base criterion pipes transformers ];
  description = "Data frames For working with tabular data files";
  license = stdenv.lib.licenses.bsd3;
}
