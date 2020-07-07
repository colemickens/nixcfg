{ lib, fetchgit, buildGoModule }:

let metadata = import ./metadata.nix; in
buildGoModule rec {
  pname = "alps";
  version = metadata.rev;

  src = fetchgit {
    url = "https://git.sr.ht/~emersion/alps";
    rev = metadata.rev;
    sha256 = metadata.sha256;
  };

  vendorSha256 = metadata.vendorSha256;

  meta = with lib; {
    description = "A basic clipboard manager for Wayland, with support for persisting copy buffers after an application exits";
    homepage = "https://github.com/yory8/clipman";
    license = licenses.gpl3;
    maintainers = with maintainers; [ colemickens ];
  };
}
