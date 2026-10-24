{ ... }:

{
  config = {
    security.pki.caCertificateBlacklist = [
      # CVE-2026-111943
      "Comodo AAA Services root"
      # https://hg-edge.mozilla.org/projects/nss/rev/26d38a0c3fb81e7fb2acedbaf4c42dd21dce0517
      # "emSign ECC Root CA - G3"
      # https://hg-edge.mozilla.org/projects/nss/rev/8159223c48ceeb1273a1915bca95a517294ab0e0
      # "emSign Root CA - C1"
      # "emSign ECC Root CA - C3"
    ];
  };
}
