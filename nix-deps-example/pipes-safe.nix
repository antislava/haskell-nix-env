{ mkDerivation, base, containers, exceptions, monad-control, mtl
, pipes, primitive, stdenv, transformers, transformers-base
}:
mkDerivation {
  pname = "pipes-safe";
  version = "2.3.1";
  sha256 = "9ef249d0a37c18ddc40efeb6a603c01d0438a45b100951ace3a739c6dc68cd35";
  libraryHaskellDepends = [
    base containers exceptions monad-control mtl pipes primitive
    transformers transformers-base
  ];
  description = "Safety for the pipes ecosystem";
  license = stdenv.lib.licenses.bsd3;
}
