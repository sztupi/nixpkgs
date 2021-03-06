{ stdenv, fetchurl, pkgconfig, intltool, exo, gtk, libxfce4util, libxfce4ui
, libglade, xfconf, xorg, libwnck, libnotify, libxklavier, garcon }:

#TODO: optional packages
stdenv.mkDerivation rec {
  p_name  = "xfce4-settings";
  ver_maj = "4.10";
  ver_min = "1";

  src = fetchurl {
    url = "mirror://xfce/src/xfce/${p_name}/${ver_maj}/${name}.tar.bz2";
    sha256 = "1m8k9s7qihwkkbjrrkmk103a6iwahxdfq65aswrsbqshx9cnk2hi";
  };

  name = "${p_name}-${ver_maj}.${ver_min}";

  patches = [ ./xfce4-settings-default-icon-theme.patch ];

  buildInputs =
    [ pkgconfig intltool exo gtk libxfce4util libxfce4ui libglade
      xfconf xorg.libXi xorg.libXcursor libwnck libnotify libxklavier garcon
      #gtk libxfce4util libxfcegui4 libwnck dbus_glib
      #xfconf libglade xorg.iceauth
    ];

  configureFlags = "--enable-pluggable-dialogs --enable-sound-settings";

  meta = {
    homepage = http://www.xfce.org/projects/xfce4-settings;
    description = "Settings manager for Xfce";
    license = stdenv.lib.licenses.gpl2Plus;
    platforms = stdenv.lib.platforms.linux;
    maintainers = [ stdenv.lib.maintainers.eelco ];
  };
}
