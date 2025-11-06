{ lib
, fetchFromGitHub
, python3Packages
, wrapPythonProgram
, xdotool
, vosk   # assuming you package or import the vosk python library
, pulseAudio  # for parec/pw-cat or similar
, sox
, ydotool
}:

python3Packages.buildPythonApplication rec {
  pname = "nerd-dictation";
  version = "41f3727";  # set a tag or commit

  src = fetchFromGitHub {
    owner = "ideasman42";
    repo = "nerd-dictation";
    rev = "41f372789c640e01bb6650339a78312661530843";
    sha256 = lib.hashString "sha256" "placeholder";
  };

  # This script is a single Python script (or very lightweight),
  # so minimal build steps are required.
  # It likely doesn’t use any compiled components.
  propagatedBuildInputs = [
    vosk
  ];

  nativeBuildInputs = [
    wrapPythonProgram
    # maybe setuptools if needed
  ];

  # Install the script into bin
  installPhase = ''
    runHook preInstall
    install -D -m755 "${src}/nerd-dictation" "$out/bin/nerd-dictation"
    runHook postInstall
  '';

  postInstall = ''
    wrapPythonProgram "$out/bin/nerd-dictation" \
      --prefix PATH : "${python3Packages.python}/bin"
    # Might need to add other wrappers for dependencies or environment variables
  '';

  meta = with lib; {
    description = "Offline speech to text for desktop Linux using VOSK-API";
    homepage = "https://github.com/ideasman42/nerd-dictation";
    license = licenses.gpl3;
    maintainers = []; 
    platforms = platforms.linux;
  };
}

