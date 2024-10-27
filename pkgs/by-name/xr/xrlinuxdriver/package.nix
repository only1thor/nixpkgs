{ lib, stdenv, fetchFromGitHub, makeWrapper, patchelf, autoPatchelfHook, libusb1, curl, openssl, libevdev, json_c, hidapi, gcc, wayland, cmake, pkg-config, python3 }:

let
  pythonEnv = python3.withPackages (ps: [ ps.pyyaml ]);
in
stdenv.mkDerivation (finalAttrs: {
  pname = "xrlinuxdriver";
  version = "1.0.4-beta";

  src = fetchFromGitHub {
    repo = "XRLinuxDriver";
    owner = "wheaney";
    rev = "v${finalAttrs.version}";
    fetchSubmodules = true;
    hash = "sha256-BCQaNF0RRH5DEAjPnmMoTbgC3fRJIdRpkUGw0+v1LLc=";
  };

  nativeBuildInputs = [ cmake pkg-config pythonEnv patchelf ];
  buildInputs = [ libusb1 curl openssl libevdev json_c hidapi gcc wayland gcc.cc.lib ];

  #dontUnpack = true;
  #dontConfigure = true;
  #dontBuild = true;

  dontStrip = true;

  postPatch = ''
    substituteInPlace systemd/xr-driver.service --replace-fail "Environment=LD_LIBRARY_PATH={ld_library_path}" ""  --replace-fail "ExecStart={bin_dir}/xrDriver" "ExecStart=$out/bin/xrDriver"
   '';

  installPhase = ''
    runHook preInstall
    echo "### install phase ###"
    mkdir -p $out/bin
    cp xrDriver $out/bin
    cp ../bin/xr_driver_cli $out/bin
    cp ../bin/xr_driver_verify $out/bin
    mkdir -p $out/share
    cp -r ../udev $out/
    cp -r ../lib $out/
    mkdir -p $out/lib/systemd/
    cp -r ../systemd $out/lib/systemd/system
    echo "### install phase done ###"
    runHook postInstall
    '';

  doInstallCheck = false;
  # The default release is a script which will do an impure download
  # just ensure that the application can run without network

  postInstall = ''
    echo "### post install ###"
    echo "post install, out dir is:"
    echo $out
    echo "pwd is:"
    pwd
    echo "ls is:"
    find
    echo "### post install done ###"
  '';

  preFixup = ''
    echo "### fixup phase ###"
    find ${hidapi}
    patchelf --print-rpath $out/bin/xrDriver
    patchelf --set-rpath "${wayland}/lib:${hidapi}/lib:${gcc.cc.lib}/lib:$out/lib/x86_64:/nix/store/jjv5khfp0ddix8js6l03ndi0wkjs63sj-xrlinuxdriver-0.12.0.1/lib:/nix/store/nyyddgd1znixp7hg34jmf9hwdh953cgl-libusb-1.0.27/lib:/nix/store/0d6qbqbgq8vl0nb3fy6wi9gfn6j3023d-openssl-3.0.14/lib:/nix/store/2888pjmiry2b58gcjn0bv3p4g4d4il4k-curl-8.7.1/lib:/nix/store/yf1dqrl9iyaihhg9v460prc1l6bmdczn-libevdev-1.13.1/lib:/nix/store/7rmizkzxwqkn1aa12vpr38wm2r8zdgyd-json-c-0.17/lib:/nix/store/c10zhkbp6jmyh0xc5kd123ga8yy2p4hk-glibc-2.39-52/lib:/nix/store/swcl0ynnia5c57i6qfdcrqa72j7877mg-gcc-13.2.0-lib/lib" $out/bin/xrDriver
    patchelf --set-rpath "${hidapi}/lib:${gcc.cc.lib}/lib" $out/lib/x86_64/libGlassSDK.so
    patchelf --set-rpath "${gcc}/lib" $out/lib/x86_64/libRayNeoXRMiniSDK.so
    #runHook postFixup
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
