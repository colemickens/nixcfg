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
    repo_git = "https://github.com/zellij-org/zellij";
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

  preCheck = ''
    HOME=$TMPDIR
  '';

  postInstall = ''
    installShellCompletion --cmd $pname \
      --bash <($out/bin/zellij setup --generate-completion bash) \
      --fish <($out/bin/zellij setup --generate-completion fish) \
      --zsh <($out/bin/zellij setup --generate-completion zsh)
  '';

  passthru.tests.version = testVersion { package = zellij; };

  meta = with lib; {
    verinfo = metadata;
    description = "A terminal workspace with batteries included";
    homepage = "https://zellij.dev/";
    changelog = "https://github.com/zellij-org/zellij/blob/${version}/Changelog.md";
    license = with licenses; [ mit ];
    maintainers = with maintainers; [ therealansh _0x4A6F ];
  };
}
