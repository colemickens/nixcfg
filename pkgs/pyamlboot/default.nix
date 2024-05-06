{ lib
, python3
, fetchFromGitHub
,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "pyamlboot";
  version = "1.0.0-unstable-2024-05-01";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "superna9999";
    repo = "pyamlboot";
    rev = "ab788f67c7f1ef5330f1a535f1dcb9a7b550016a";
    hash = "sha256-Kz+5y7WUeVzdSZca4tF5EcEYJ8gvK+f40TJci/1EZng=";
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
