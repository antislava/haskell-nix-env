{ mkDerivation, aeson, aeson-pretty, base, bytestring, containers
, directory, either, errors, filepath, foldl, Frames, hashable
, hpack, microlens, microlens-aeson, microlens-platform
, microlens-th, neat-interpolation, path, path-io, singletons
, stdenv, system-fileio, system-filepath, text, time, turtle
, unordered-containers, vinyl
}:
mkDerivation {
  pname = "example-package";
  version = "0.0.1";
  src = ../example-package;
  isLibrary = false;
  isExecutable = true;
  libraryToolDepends = [ hpack ];
  executableHaskellDepends = [
    aeson aeson-pretty base bytestring containers directory either
    errors filepath foldl Frames hashable microlens microlens-aeson
    microlens-platform microlens-th neat-interpolation path path-io
    singletons system-fileio system-filepath text time turtle
    unordered-containers vinyl
  ];
  preConfigure = "hpack";
  description = "Dummy package";
  license = stdenv.lib.licenses.bsd3;
}
