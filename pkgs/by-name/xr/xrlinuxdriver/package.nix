{ lib, stdenv, fetchFromGitHub, makeWrapper, patchelf, autoPatchelfHook, libusb1, curl, openssl, libevdev, json_c, hidapi, gcc, wayland, cmake, pkg-config, python3, strace, binutils }:

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
    hash = "sha256-g8cYjnkLX0ArbU8pV+EbzZBMqovUzRPuEpg+Wjf3LZE=";
  };

  nativeBuildInputs = [ cmake pkg-config pythonEnv autoPatchelfHook patchelf ];
  buildInputs = [ libusb1 curl openssl libevdev json_c hidapi wayland gcc.cc.lib binutils ];
  
  cmakeBuildType = "RelWithDebInfo";

  #dontUnpack = true;
  #dontConfigure = true;
  #dontBuild = true;

  dontStrip = true;

  patches = [
    ./remove_submodule_update.patch
  ];

  postPatch = ''
    substituteInPlace systemd/xr-driver.service  \
      --replace-fail "Environment=LD_LIBRARY_PATH={ld_library_path}" ""  \
      --replace-fail "ExecStart={bin_dir}/xrDriver" "ExecStart=${strace}/bin/strace $out/bin/xrDriver"
   '';

  installPhase = ''
    runHook preInstall
    echo "### install phase ###"
    mkdir -p $out/bin
    cp xrDriver $out/bin
    cp ../bin/xr_driver_cli $out/bin
    cp ../bin/xr_driver_verify $out/bin
    mkdir -p $out/etc
    cp -r ../udev $out/etc/
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
    #find ${hidapi}
    #patchelf --print-rpath $out/bin/xrDriver
    #patchelf --set-rpath "${wayland}/lib:${hidapi}/lib:${gcc.cc.lib}/lib:$out/lib/x86_64" $out/bin/xrDriver
    #patchelf --set-rpath "${hidapi}/lib:${gcc.cc.lib}/lib" $out/lib/x86_64/libGlassSDK.so
    #patchelf --set-rpath "${gcc}/lib" $out/lib/x86_64/libRayNeoXRMiniSDK.so
    #stripRpath() {
    #  patchelf --set-rpath "$(patchelf --print-rpath "$1" | tr : \\n | grep -v /build | tr \\n :)" "$1"
    #}
    #stripRpath $out/bin/xrDriver
    #stripRpath $out/lib/x86_64/libGlassSDK.so
    #stripRpath $out/lib/x86_64/libRayNeoXRMiniSDK.so
    patchelf --shrink-rpath --allowed-rpath-prefixes "/nix:$out/lib" $out/bin/xrDriver
    patchelf --shrink-rpath --allowed-rpath-prefixes "/nix" $out/lib/x86_64/*.so

    ldd $out/bin/xrDriver
    patchelf --print-rpath $out/bin/xrDriver
    mv $out/lib/x86_64/* $out/lib
    '';

  postFixup = ''
    patchelf --shrink-rpath --allowed-rpath-prefixes "/nix" $out/lib/*.so
    patchelf --shrink-rpath --allowed-rpath-prefixes "/nix:$out/lib" $out/bin/xrDriver
    echo "##########"
    patchelf --print-rpath $out/bin/xrDriver
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
