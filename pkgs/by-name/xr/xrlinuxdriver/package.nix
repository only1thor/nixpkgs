{ lib, stdenv, fetchurl, makeWrapper, autoPatchelfHook, libusb1, curl, openssl, libevdev, json_c }:

stdenv.mkDerivation rec {
  pname = "xrlinuxdriver";
  version = "0.12.0.1";

  src = fetchurl {
    url = "https://github.com/wheaney/XRLinuxDriver/releases/download/v${version}/xrDriver-x86_64.tar.gz";
    hash = "sha256-drgfbEknX076v1bEIY+DsGWrCnJaHIXVzKZAxB0RyAQ=";
  };

  nativeBuildInputs = [ makeWrapper autoPatchelfHook ];
  buildInputs = [ libusb1 stdenv.cc.libc stdenv.cc.cc curl openssl libevdev json_c ];

  #dontUnpack = true;
  #dontConfigure = true;
  #dontBuild = true;

  # this is mostly downloading a pre-built artifact
  preferLocal = true;

  postPatch = ''
    substituteInPlace systemd/xr-driver.service --replace-fail "Environment=LD_LIBRARY_PATH={ld_library_path}" "" --replace-fail "ExecStart={bin_dir}/xrDriver" "ExecStart=$out/bin/xrDriver"
  '';

  installPhase = ''
    runHook preInstall
    echo "installing"
    mkdir -p $out/share
    cp -r udev $out/share
    cp -r bin $out
    cp -r lib $out
    mkdir -p $out/lib/systemd
    cp -r systemd $out/lib/systemd/system
    rm -rf $out/bin/{xr_driver_uninstall,user}
    runHook postInstall
  '';


  doInstallCheck = false;
  # The default release is a script which will do an impure download
  # just ensure that the application can run without network
  installCheckPhase = ''
    #$out/bin/mill --help > /dev/null
    echo "install check phase"
  '';

  meta = with lib; {
    homepage = "https://github.com/wheaney/XRLinuxDriver";
    license = licenses.mit;
    description = "TODO";
    mainProgram = "xrlinuxdriver";
    longDescription = ''
        TODO
    '';
    maintainers = with maintainers; [  ];
    platforms = lib.platforms.all;
  };
}
