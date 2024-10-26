{ lib, stdenv, fetchFromGitHub, makeWrapper, autoPatchelfHook, libusb1, curl, openssl, libevdev, json_c, cmake, pkg-config, python3 }:

let
  pythonEnv = python3.withPackages (ps: [ ps.pyyaml ]);
in
stdenv.mkDerivation (finalAttrs: {
  pname = "xrlinuxdriver";
  version = "0.12.0.1";

  src = fetchFromGitHub {
    repo = "XRLinuxDriver";
    owner = "wheaney";
    rev = "v${finalAttrs.version}";
    fetchSubmodules = true;
    hash = "sha256-g8cYjnkLX0ArbU8pV+EbzZBMqovUzRPuEpg+Wjf3LZE=";
  };

  nativeBuildInputs = [ cmake pkg-config pythonEnv ];
  buildInputs = [ libusb1 curl openssl libevdev json_c ];

  #dontUnpack = true;
  #dontConfigure = true;
  #dontBuild = true;

  installPhase = ''
    echo "### install phase ###"
    mkdir -p $out/bin
    cp xrDriver $out/bin
    cp ../bin/xr_driver_cli $out/bin
    cp ../bin/xr_driver_verify $out/bin
    mkdir -p $out/share
    cp -r ../udev $out/
    cp -r ../lib $out/
    mkdir -p $out/lib/systemd/system
    cp -r ../systemd $out/lib/systemd/system
    echo "### install phase done ###"
    '';

  doInstallCheck = false;
  # The default release is a script which will do an impure download
  # just ensure that the application can run without network
  installCheckPhase = ''
    echo " ### install check phase ###"
    #$out/bin/mill --help > /dev/null
    echo "install check phase"
    echo " ### install check phase done ###"
  '';

  postInstall = ''
    echo "### post install ###"
    echo "post install, out dir is:"
    echo $out
    echo "pwd is:"
    pwd
    echo "ls is:"
    find
    echo "### post install done ###"
    false
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
})
