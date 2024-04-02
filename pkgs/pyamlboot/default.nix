{ lib
, python3
, fetchFromGitHub
,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "pyamlboot";
  version = "1.0.0-unstable-2024-02-22";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "superna9999";
    repo = "pyamlboot";
    rev = "90eb0c0ccfed9fd3f52016a3835122505ea35f5f";
    hash = "sha256-lHSVi+3+bsdPhqL7pxUl3e3mdzAQknBt/h+R5hDL21U=";
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
