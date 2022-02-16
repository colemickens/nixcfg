{ lib
, fetchFromGitHub
, rustPlatform
, stdenv
, installShellFiles
, pkg-config
, libiconv
, openssl
, zellij
, testVersion
, runCommandNoCC
}:

let
  metadata = rec {
    repo_git = "https://github.com/solokeys/solo2";
    branch = "main";
    rev = "10a22c479ffb4d76627eadbee2dc4b53ae4309c3";
    sha256 = "sha256-nFph0c9GEvZR1Ao7oiNH2ewlQkUBfQxJFtNHfHo6vSI=";
    cargoSha256 = "sha256-UOqaLx0U0/Bwi0H2qd9naFxjLRJB5qiMxsAooamI72g=";
  };
  cargo_new_version = "0.0.999-${builtins.substring 0 10 metadata.rev}";
  src = fetchFromGitHub {
    owner = "zellij-org";
    repo = "zellij";
    inherit (metadata) rev sha256;
  };
  newsrc = runCommandNoCC "patch-zellij-src" {} ''
    cp -a ${src} $out
    chmod +w "$out/zellij-utils/src"
    sed -i "s/env!(\"CARGO_PKG_VERSION\")/\"${cargo_new_version}\"/" "$out/zellij-utils/src/consts.rs"
  '';
in rustPlatform.buildRustPackage rec {
  pname = "zellij";
  version = cargo_new_version;

  # TODO: check on cli
  # TODO: check on udev rules

  src = newsrc;

  cargoSha256 = metadata.cargoSha256;

  nativeBuildInputs = [
    installShellFiles
    pkg-config
  ];

  buildInputs = [
    openssl
  ] ++ lib.optionals stdenv.isDarwin [
    libiconv
  ];

  meta = with lib; {
    verinfo = metadata;
    description = "Solo 2 monorepo";
    homepage = "https://solo2.dev";
    changelog = "https://github.com/solokeys/solo2";
    license = with licenses; [ mit ]; # and apache?
    maintainers = with maintainers; [ therealansh _0x4A6F ];
  };
}
