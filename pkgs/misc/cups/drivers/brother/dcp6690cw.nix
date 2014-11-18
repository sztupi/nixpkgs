{stdenv, makeWrapper, fetchurl, coreutils, cups, rpm, cpio, ghostscript, file, bash, which }:
let
  version = "1.1.2-2";
  model = "dcp6690cw";
in 
stdenv.mkDerivation rec {
  name = "cups-${model}-${version}";

  srcs = [
    ./dcp6690cw
    (fetchurl {
      url = "http://www.brother.com/pub/bsc/linux/dlf/dcp6690cwlpr-1.1.2-2.i386.rpm";
      sha256 = "1jzvim7yajskw1inm7i22qkszrfg7zml8aiz2rfzczj9pw7z4b1w";
    })
    (fetchurl {
      url = "http://www.brother.com/pub/bsc/linux/dlf/dcp6690cwcupswrapper-1.1.2-2.i386.rpm";
      sha256 = "0mx76mdhj867qy9k0clyy9nb8zs09r1n7l2jkq1wcq3ncvp42hki";
    })
  ];

  buildInputs = [ makeWrapper rpm cpio ];

  unpackCmd = "$(mkdir -p src && cd src && ${rpm}/bin/rpm2cpio $curSrc | ${cpio}/bin/cpio -id)";

  sourceRoot = ".";

  patches = [ ./dcp6690cw/filterdcp6690cw.patch ];
  
  buildPhase = ''
    substituteInPlace dcp6690cw/brdcp6690cw.ppd \
      --subst-var-by out $out \
      --subst-var-by printer_model dcp6690cw \
      --subst-var-by printer_name DCP6690CW \
      --subst-var-by device_name DCP-6690CW \
      --subst-var-by pcfilename 6690 \
      --subst-var-by device_model Printer

    substituteInPlace dcp6690cw/brlpdwrapperdcp6690cw \
      --subst-var-by out $out \
      --subst-var-by pkgs.coreutils ${coreutils} \
      --subst-var-by printer_model dcp6690cw \
      --subst-var-by printer_name DCP6690CW \
      --subst-var-by device_name DCP-6690CW \
      --subst-var-by pcfilename 6690 \
      --subst-var-by device_model Printer

    substituteInPlace src/usr/local/Brother/Printer/dcp6690cw/lpd/filterdcp6690cw \
      --subst-var-by out $out\
      --subst-var-by printer_model dcp6690cw \
      --subst-var-by printer_name DCP6690CW \
      --subst-var-by device_name DCP-6690CW \
      --subst-var-by pcfilename 6690 \
      --subst-var-by device_model Printer
  '';

  installPhase = ''
    install -d $out
    cp -r src/usr $out
    install -m 400 -D dcp6690cw/brdcp6690cw.ppd $out/share/cups/model/brdcp6690cw.ppd
    install -m 400 -D dcp6690cw/brdcp6690cw.ppd $out/usr/share/cups/model/brdcp6690cw.ppd
    install -m 500 -D dcp6690cw/brlpdwrapperdcp6690cw $out/lib/cups/filter/brlpdwrapperdcp6690cw
    install -m 500 -D dcp6690cw/brlpdwrapperdcp6690cw $out/usr/lib/cups/filter/brlpdwrapperdcp6690cw

    wrapProgram $out/usr/local/Brother/Printer/dcp6690cw/lpd/filterdcp6690cw \
      --prefix PATH : "${coreutils}/bin:${file}/bin:${ghostscript}/bin:${which}/bin"

    wrapProgram $out/usr/local/Brother/Printer/dcp6690cw/lpd/psconvertij2 \
      --prefix PATH : ${coreutils}/bin

    patchelf --set-interpreter ${stdenv.glibc}/lib/ld-linux.so.2 \
      $out/usr/local/Brother/Printer/dcp6690cw/lpd/brdcp6690cwfilter

    patchelf --set-interpreter ${stdenv.glibc}/lib/ld-linux.so.2 \
      $out/usr/local/Brother/Printer/dcp6690cw/cupswrapper/brcupsconfpt1
      
    patchelf --set-interpreter ${stdenv.glibc}/lib/ld-linux.so.2 \
      $out/usr/bin/brprintconf_dcp6690cw

    wrapProgram $out/usr/local/Brother/Printer/dcp6690cw/cupswrapper/brcupsconfpt1 \
      --prefix PATH : $out/usr/bin
  '';
}