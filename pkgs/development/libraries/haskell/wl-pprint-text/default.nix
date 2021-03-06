# This file was auto-generated by cabal2nix. Please do NOT edit manually!

{ cabal, text }:

cabal.mkDerivation (self: {
  pname = "wl-pprint-text";
  version = "1.1.0.2";
  sha256 = "0wbfqp38as2qpn66sq4hvl3hzvj66v301cz9rmgnx2i62r0a3s81";
  buildDepends = [ text ];
  jailbreak = true;
  meta = {
    description = "A Wadler/Leijen Pretty Printer for Text values";
    license = self.stdenv.lib.licenses.bsd3;
    platforms = self.ghc.meta.platforms;
  };
})
