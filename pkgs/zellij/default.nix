{ lib
, fetchFromGitHub
, rustPlatform
, stdenv
, installShellFiles
, pkg-config
, libiconv
, openssl
, zellij
, cargo
, testVersion
, runCommandNoCC
}:

let
  metadata = rec {
    repo_git = "https://github.com/zellij-org/zellij";
    branch = "main";
    rev = "4985864592bcaf45e75d6113006b242a85e226b3";
    sha256 = "sha256-LUMTSZM5YdlktGnmg9SKCuuE/bnqINLB+lma5hJMygo=";
    cargoSha256 = "sha256-Ly2cbPqorKVckfEmyaMsVhslKrQCS2CWSPGhklYgWIE=";
  };
  cargo_new_version = "0.0.999-${builtins.substring 0 10 metadata.rev}";
  src = fetchFromGitHub {
    owner = "zellij-org";
    repo = "zellij";
    inherit (metadata) rev sha256;
  };
  newsrc = src;
  # newsrc = ((fetchFromGitHub {
  #   owner = "zellij-org";
  #   repo = "zellij";
  #   inherit (metadata) rev sha256;
  # }).overrideAttrs(old: {
  #   postFetch = old.postFetch + ''
  #     export HOME=$TMPDIR
  #     cd $out
  #     sed -i "s/^version = .*/version = \"${cargo_new_version}\"/" "$out/Cargo.toml"
  #     sed -i "s/^version = .*/version = \"${cargo_new_version}\"/" "$out/zellij-utils/Cargo.toml"
  #     cargo generate-lockfile
  #   '';
  #   nativeBuildInputs = old.nativeBuildInputs ++ [
  #     cargo
  #     #(builtins.trace rustPlatform.passthru rustPlatform.passthru.cargo)
  #   ];
  # }));
  # newsrc = runCommandNoCC "patch-zellij-src" {} ''
  #   cp -a ${src} $out
  #   chmod +w "$out/zellij-utils/src"
  #   chmod +w "$out/zellij-utils"
  #   chmod +w "$out/"
  #   sed -i "s/^version = .*/version = \"${cargo_new_version}\"/" "$out/Cargo.toml"
  #   sed -i "s/^version = .*/version = \"${cargo_new_version}\"/" "$out/zellij-utils/Cargo.toml"
  #   sed -i "/name = \"zellij\"/{n;s/.*/version = \"${cargo_new_version}\"/}" "$out/Cargo.lock"
  #   sed -i "/name = \"zellij\"/{n;s/.*/version = \"${cargo_new_version}\"/}" "$out/Cargo.lock"
  # '';
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
