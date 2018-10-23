{ mkDerivation, ansi-wl-pprint, async, base, bytestring, clock
, containers, criterion, directory, doctest, exceptions, fetchgit
, foldl, hostname, managed, optional-args, optparse-applicative
, process, semigroups, stdenv, stm, system-fileio, system-filepath
, temporary, text, time, transformers, unix, unix-compat
}:
mkDerivation {
  pname = "turtle";
  version = "1.5.12";
  src = fetchgit {
    url = "https://github.com/Gabriel439/Haskell-Turtle-Library";
    sha256 = "0iz5m7qwxyrdwpk1l039w92bkrriq7ng4awlrs7llrhhj8k9djcj";
    rev = "76224d95727d14ec8754aeb37d0fc81e98ae2c94";
    fetchSubmodules = true;
  };
  libraryHaskellDepends = [
    ansi-wl-pprint async base bytestring clock containers directory
    exceptions foldl hostname managed optional-args
    optparse-applicative process semigroups stm system-fileio
    system-filepath temporary text time transformers unix unix-compat
  ];
  testHaskellDepends = [ base doctest system-filepath temporary ];
  benchmarkHaskellDepends = [ base criterion text ];
  description = "Shell programming, Haskell-style";
  license = stdenv.lib.licenses.bsd3;
}
