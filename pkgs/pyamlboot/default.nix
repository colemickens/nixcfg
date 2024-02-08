{
  lib,
  python3,
  fetchFromGitHub,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "pyamlboot";
  version = "unstable-2021-08-17";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "superna9999";
    repo = "pyamlboot";
    rev = "ffaaad9503192ece98970b7100a03c54ba58befc";
    hash = "sha256-2TD9UtMcxA29p3K6i5+SDSAVDiFhY1050QWx5MHne3s=";
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
