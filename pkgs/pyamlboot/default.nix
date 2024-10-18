{
  lib,
  python3,
  fetchFromGitHub,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "pyamlboot";
  version = "1.0.0-unstable-2024-10-03";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "superna9999";
    repo = "pyamlboot";
    rev = "d7806acc4f0a9a9d89b4e32a5c9a0ae03f7d11bf";
    hash = "sha256-wN+9QBZ2rgI9CWHhf30MNjfDPuer+CpG4cnSRWY6jQA=";
  };

  nativeBuildInputs = [
    python3.pkgs.setuptools
    python3.pkgs.wheel
  ];

  propagatedBuildInputs = with python3.pkgs; [
    pyusb
    setuptools
  ];

  pythonImportsCheck = [ "pyamlboot" ];

  meta = with lib; {
    description = "Amlogic USB Boot Protocol Library";
    homepage = "https://github.com/superna9999/pyamlboot";
    license = licenses.asl20;
    maintainers = with maintainers; [ ];
    mainProgram = "pyamlboot";
  };
}
