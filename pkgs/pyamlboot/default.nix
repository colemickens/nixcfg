{
  lib,
  python3,
  fetchFromGitHub,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "pyamlboot";
  version = "1.0.0-unstable-2024-07-01";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "superna9999";
    repo = "pyamlboot";
    rev = "aed6bbc96f7f4580f63da8d2f7b684c96a208efd";
    hash = "sha256-kd6H2sJS6u392UentF2WuXu6vUR0VZwPqH3nRywkN6o=";
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
