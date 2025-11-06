{ lib
, buildPythonPackage
, fetchPypi
, setuptools
, wheel
, numpy
}:

buildPythonPackage rec {
  pname = "vosk";
  version = "0.3.45"; # check PyPI for the latest version

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # replace with actual hash
  };

  nativeBuildInputs = [ setuptools wheel ];
  propagatedBuildInputs = [ numpy ];

  # Optional: Vosk is pure Python but links to shared libs at runtime
  # (speech models are downloaded separately).
  doCheck = false; # No tests on PyPI tarball

  pythonImportsCheck = [ "vosk" ];

  meta = with lib; {
    description = "Offline speech recognition API for Python";
    homepage = "https://alphacephei.com/vosk/";
    license = licenses.asl20;
    platforms = platforms.all;
  };
}

