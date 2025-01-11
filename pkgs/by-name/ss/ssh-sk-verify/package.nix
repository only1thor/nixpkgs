{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
}:

buildGoModule rec {
  pname = "ssh-sk-verify";
  version = "0.7.0";

  src = fetchFromGitHub {
    owner = "supply-chain-tools";
    repo = "ssh-sk-verify";
    rev = "d0ddc97e5f6f474b0b8332aaec1cfa613fbae829";
    hash = "sha256-yCMaeqG7aY4G+Q8DTk3kg5S/wGkHqEXQg6x0z4Xz3XQ=";
  };

  proxyVendor = true;

  vendorHash = "sha256-Z010fYE2CcmKV0udm5W188X0RB2IE3tRGQFHyQU5HL0=";

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "An **experimental** tool to verify ssh-sk attestations";
    homepage = "https://github.com/supply-chain-tools/ssh-sk-verify";
    license = licenses.asl20;
    platforms = platforms.linux;
    maintainers = with maintainers; [ only1thor ];
    mainProgram = "ssh-sk-verify";
  };
}
