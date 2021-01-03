{ lib, stdenv, fetchFromGitHub, fetchurl, gtk2, glib, pkgconfig, unzip, ncurses, zip }:

stdenv.mkDerivation rec {
  version = "11.0";
  pname = "textadept11";

  nativeBuildInputs = [ pkgconfig ];
  buildInputs = [
    gtk2 ncurses glib unzip zip
  ];

  src = fetchFromGitHub {
    name = "textadept11";
    owner = "orbitalquark";
    repo = "textadept";
    rev = "textadept_${version}";
    sha256 = "1ls6z6fjy88rs87hmw19l6y3nx7g0slq303hc0n05ia0y47gkfb6";
  };

  preConfigure =
    lib.concatStringsSep "\n" (lib.mapAttrsToList (name: params:
      "ln -s ${fetchurl params} $PWD/src/${name}"
    ) (import ./deps.nix)) + ''

    cd src
    make deps
  '';

  postBuild = ''
    make curses
  '';

  preInstall = ''
    mkdir -p $out/share/applications
    mkdir -p $out/share/pixmaps
  '';

  postInstall = ''
    make curses install PREFIX=$out MAKECMDGOALS=curses
  '';

  makeFlags = [
    "PREFIX=$(out) WGET=true PIXMAPS_DIR=$(out)/share/pixmaps"
  ];

  meta = with stdenv.lib; {
    description = "An extensible text editor based on Scintilla with Lua scripting. Version 11";
    homepage = "http://foicica.com/textadept";
    license = licenses.mit;
    maintainers = with maintainers; [ raskin mirrexagon ];
    platforms = platforms.linux;
  };
}
