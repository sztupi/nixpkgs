# Haskell / GHC infrastructure in Nixpkgs
#
# In this file, we
#
#    * define sets of default package versions for each GHC compiler version,
#    * associate GHC versions with bootstrap compiler versions and package defaults.
#
# The actual Haskell packages are composed in haskell-packages.nix. There is
# more documentation in there.

{ makeOverridable, lowPrio, hiPrio, stdenv, pkgs, newScope, config, callPackage } : rec {

  # haskell-packages.nix provides the latest possible version of every package,
  # and this file overrides those version choices per compiler when appropriate.
  # Older compilers inherit the overrides from newer ones.

  ghcHEADPrefs = self : super : super // {
    cabalInstall_1_20_0_3 = super.cabalInstall_1_20_0_3.override { Cabal = null; };
    mtl = self.mtl_2_2_1;
    transformersCompat = super.transformersCompat_0_3_3;
  };

  ghc783Prefs = self : super : ghcHEADPrefs self super // {
    cabalInstall_1_20_0_3 = super.cabalInstall_1_20_0_3.override { Cabal = self.Cabal_1_20_0_2; };
    codex = super.codex.override { hackageDb = super.hackageDb.override { Cabal = self.Cabal_1_20_0_2; }; };
    MonadRandom = self.MonadRandom_0_2_0_1; # newer versions require transformers >= 0.4.x
    mtl = self.mtl_2_1_3_1;
  } // (if !pkgs.stdenv.isDarwin then {} else {
    # Temporary workaround for https://github.com/NixOS/nixpkgs/issues/2689
    cabal = super.cabal.override {
      extension = self: super: {
        noHaddock = true;
        hyperlinkSource = false;
        # Temporary workaround for https://github.com/NixOS/nixpkgs/issues/3540
        doCheck = false;
      };
    };
  });

  ghc763Prefs = self : super : ghc783Prefs self super // {
    aeson = self.aeson_0_7_0_4;
    ariadne = super.ariadne.override {
      haskellNames = self.haskellNames.override {
        haskellPackages = self.haskellPackages.override { Cabal = self.Cabal_1_18_1_3; };
      };
    };
    attoparsec = self.attoparsec_0_11_3_1;
    binaryConduit = super.binaryConduit.override { binary = self.binary_0_7_2_2; };
    bson = super.bson.override { dataBinaryIeee754 = self.dataBinaryIeee754.override { binary = self.binary_0_7_2_2; }; };
    cabal2nix = super.cabal2nix.override { hackageDb = super.hackageDb.override { Cabal = self.Cabal_1_18_1_3; }; };
    cabalInstall_1_16_0_2 = super.cabalInstall_1_16_0_2.override {
      HTTP = self.HTTP.override { network = self.network_2_5_0_0; };
      network = self.network_2_5_0_0;
    };
    criterion = super.criterion.override {
      statistics = self.statistics.override {
        vectorBinaryInstances = self.vectorBinaryInstances.override { binary = self.binary_0_7_2_2; };
      };
    };
    entropy = super.entropy.override { cabal = self.cabal.override { Cabal = self.Cabal_1_18_1_3; }; };
    gloss = null;                       # requires base >= 4.7
    modularArithmetic = null;           # requires base >= 4.7
    pipesBinary = super.pipesBinary.override { binary = self.binary_0_7_2_2; };
    rank1dynamic = super.rank1dynamic.override { binary = self.binary_0_7_2_2; };
    distributedStatic = super.distributedStatic.override { binary = self.binary_0_7_2_2; };
    networkTransport = super.networkTransport.override { binary = self.binary_0_7_2_2; };
    distributedProcess = super.distributedProcess.override { binary = self.binary_0_7_2_2; };
    scientific = self.scientific_0_2_0_2;
    singletons = null;                  # requires base >= 4.7
    transformers = self.transformers_0_3_0_0; # core packagen in ghc > 7.6.x
    zipArchive = super.zipArchive_0_2_2_1;    # works without binary 0.7.x
  };

  ghc742Prefs = self : super : ghc763Prefs self super // {
    aeson = self.aeson_0_7_0_4.override { blazeBuilder = self.blazeBuilder; };
    extensibleExceptions = null;        # core package in ghc <= 7.4.x
    hackageDb = super.hackageDb.override { Cabal = self.Cabal_1_16_0_3; };
    haskeline = super.haskeline.override { cabal = self.cabal.override { Cabal = self.Cabal_1_16_0_3; }; };
    primitive = self.primitive_0_5_3_0; # later versions don't compile
    random = self.random_1_0_1_1;       # requires base >= 4.6.x
  };

  ghc722Prefs = self : super : ghc742Prefs self super // {
    caseInsensitive = self.caseInsensitive_1_0_0_1;
    deepseq = self.deepseq_1_3_0_2;
    DrIFT = null;                       # doesn't compile with old GHC versions
    syb = self.syb_0_4_0;
  };

  ghc704Prefs = self : super : ghc722Prefs self super // {
    binary = self.binary_0_7_2_2;       # core package in ghc >= 7.2.2
    caseInsensitive = super.caseInsensitive; # undo the override from ghc 7.2.2
    HsSyck = self.HsSyck_0_51;
    jailbreakCabal = super.jailbreakCabal.override { Cabal = self.Cabal_1_16_0_3; };
    random = null;                      # core package in ghc <= 7.0.x
  };

  ghc6123Prefs = self : super : ghc704Prefs self super // {
    alex = self.alex_3_1_3;
    async = self.async_2_0_1_4;
    attoparsec = self.attoparsec_0_10_4_0;
    cabalInstall = self.cabalInstall_1_16_0_2;
    cgi = self.cgi_3001_1_7_5;
    deepseq = self.deepseq_1_2_0_1;
    dlist = super.dlist.override { cabal = self.cabal.override { Cabal = self.Cabal_1_16_0_3; }; };
    exceptions = null;                  # none of our versions compile
    logict = super.logict.override { cabal = self.cabal.override { Cabal = self.Cabal_1_16_0_3; }; };
    monadPar = self.monadPar_0_1_0_3;
    nats = null;                        # none of our versions compile
    networkUri = super.networkUri.override { cabal = self.cabal.override { Cabal = self.Cabal_1_16_0_3; }; };
    parallel = self.parallel_3_2_0_3;
    primitive = self.primitive_0_5_0_1;
    reflection = super.reflection.override { cabal = self.cabal.override { Cabal = self.Cabal_1_16_0_3; }; };
    scientific = null;                  # none of our versions compile
    split = self.split_0_1_4_3;
    stm = self.stm_2_4_2;
    syb = null;                         # core package in ghc < 7
    tagged = super.tagged.override { cabal = self.cabal.override { Cabal = self.Cabal_1_16_0_3; }; };
    temporary = null;                   # none of our versions compile
    vector = super.vector_0_10_9_3;
    vectorAlgorithms = super.vectorAlgorithms.override { cabal = self.cabal.override { Cabal = self.Cabal_1_16_0_3; }; };
  };

  ghc6104Prefs = self : super : ghc6123Prefs self super // {
    alex = self.alex_2_3_5.override { cabal = self.cabal.override { Cabal = self.Cabal_1_16_0_3; }; };
    async = null;                       # none of our versions compile
    attoparsec = null;                  # none of our versions compile
    binary = super.binary_0_7_2_2.override { cabal = self.cabal.override { Cabal = self.Cabal_1_16_0_3; }; };
    cabalInstall_1_16_0_2 = super.cabalInstall_1_16_0_2;
    caseInsensitive = super.caseInsensitive.override { cabal = self.cabal.override { Cabal = self.Cabal_1_16_0_3; }; };
    GLUT = self.GLUT_2_2_2_1;
    happy = super.happy.override { cabal = self.cabal.override { Cabal = self.Cabal_1_16_0_3; }; };
    hashable = super.hashable.override { cabal = self.cabal.override { Cabal = self.Cabal_1_16_0_3; }; };
    hashtables = super.hashtables.override { cabal = self.cabal.override { Cabal = self.Cabal_1_16_0_3; }; };
    hsyslog = super.hsyslog.override { cabal = self.cabal.override { Cabal = self.Cabal_1_16_0_3; }; };
    HTTP = super.HTTP.override { cabal = self.cabal.override { Cabal = self.Cabal_1_16_0_3; }; };
    HUnit = super.HUnit.override { cabal = self.cabal.override { Cabal = self.Cabal_1_16_0_3; }; };
    network = super.network_2_2_1_7.override { cabal = self.cabal.override { Cabal = self.Cabal_1_16_0_3; }; };
    OpenGLRaw = self.OpenGLRaw_1_3_0_0;
    OpenGL = self.OpenGL_2_6_0_1;
    parsec = super.parsec.override { cabal = self.cabal.override { Cabal = self.Cabal_1_16_0_3; }; };
    QuickCheck = super.QuickCheck.override { cabal = self.cabal.override { Cabal = self.Cabal_1_16_0_3; }; };
    stm = self.stm_2_4_2.override { cabal = self.cabal.override { Cabal = self.Cabal_1_16_0_3; }; };
    systemFilepath = super.systemFilepath.override { cabal = self.cabal.override { Cabal = self.Cabal_1_16_0_3; }; };
    systemFileio = super.systemFileio.override { cabal = self.cabal.override { Cabal = self.Cabal_1_16_0_3; }; };
    tar = super.tar.override { cabal = self.cabal.override { Cabal = self.Cabal_1_16_0_3; }; };
    text = self.text_0_11_2_3.override { cabal = self.cabal.override { Cabal = self.Cabal_1_16_0_3; }; };
    tfRandom = null;                    # does not compile
    time = self.time_1_1_2_4.override { cabal = self.cabal.override { Cabal = self.Cabal_1_16_0_3; }; };
    zlib = super.zlib.override { cabal = self.cabal.override { Cabal = self.Cabal_1_16_0_3; }; };
 };

  # Abstraction for Haskell packages collections
  packagesFun = makeOverridable
   ({ ghcPath ? null
    , ghc ? callPackage ghcPath ({ ghc = ghcBinary; } // extraArgs)
    , ghcBinary ? ghc6101Binary
    , prefFun
    , extension ? (self : super : {})
    , profExplicit ? false, profDefault ? false
    , modifyPrio ? lowPrio
    , extraArgs ? {}
    , cabalPackage ? import ../build-support/cabal
    , ghcWrapperPackage ? import ../development/compilers/ghc/wrapper.nix
    } :
    let haskellPackagesClass = import ./haskell-packages.nix {
          inherit pkgs newScope modifyPrio cabalPackage ghcWrapperPackage;
          enableLibraryProfiling =
            if profExplicit then profDefault
                            else config.cabal.libraryProfiling or profDefault;
          inherit ghc;
        };
        haskellPackagesPrefsClass = self : let super = haskellPackagesClass self; in super // prefFun self super;
        haskellPackagesExtensionClass = self : let super = haskellPackagesPrefsClass self; in super // extension self super;
        haskellPackages = haskellPackagesExtensionClass haskellPackages;
    in haskellPackages);

  defaultVersionPrioFun =
    profDefault :
    if config.cabal.libraryProfiling or false == profDefault
      then (x : x)
      else lowPrio;

  packages = args : let r = packagesFun args;
                    in  r // { lowPrio     = r.override { modifyPrio   = lowPrio; };
                               highPrio    = r.override { modifyPrio   = hiPrio; };
                               noProfiling = r.override { profDefault  = false;
                                                          profExplicit = true;
                                                          modifyPrio   = defaultVersionPrioFun false; };
                               profiling   = r.override { profDefault  = true;
                                                          profExplicit = true;
                                                          modifyPrio   = defaultVersionPrioFun true; };
                             };

  # Binary versions of GHC
  #
  # GHC binaries are around for bootstrapping purposes

  ghc6101Binary = lowPrio (callPackage ../development/compilers/ghc/6.10.1-binary.nix {
    gmp = pkgs.gmp4;
  });

  ghc6102Binary = lowPrio (callPackage ../development/compilers/ghc/6.10.2-binary.nix {
    gmp = pkgs.gmp4;
  });

  ghc6121Binary = lowPrio (callPackage ../development/compilers/ghc/6.12.1-binary.nix {
    gmp = pkgs.gmp4;
  });

  ghc704Binary = lowPrio (callPackage ../development/compilers/ghc/7.0.4-binary.nix {
    gmp = pkgs.gmp4;
  });

  ghc742Binary = lowPrio (callPackage ../development/compilers/ghc/7.4.2-binary.nix {
    gmp = pkgs.gmp4;
  });

  ghc783Binary = lowPrio (callPackage ../development/compilers/ghc/7.8.3-binary.nix {});

  ghc6101BinaryDarwin = if stdenv.isDarwin then ghc704Binary else ghc6101Binary;
  ghc6121BinaryDarwin = if stdenv.isDarwin then ghc704Binary else ghc6121Binary;

  # Compiler configurations
  #
  # Here, we associate compiler versions with bootstrap compiler versions and
  # preference functions.

  packages_ghcHEAD =
    packages { ghcPath = ../development/compilers/ghc/head.nix;
               ghcBinary = pkgs.haskellPackages.ghcPlain;
               prefFun = ghcHEADPrefs;
               extraArgs = {
                 happy = pkgs.haskellPackages.happy;
                 alex = pkgs.haskellPackages.alex;
               };
             };

  packages_ghc783 =
    packages { ghcPath = ../development/compilers/ghc/7.8.3.nix;
               ghcBinary = if stdenv.isDarwin then ghc783Binary else ghc742Binary;
               prefFun = ghc783Prefs;
             };

  packages_ghcjs =
    let parent = packages_ghc783.override {
          extension = self: super: {
            transformersCompat = super.transformersCompat_0_3_3_3;
            network = super.network_2_6_0_2;
            haddock = super.haddock.override {
              Cabal = null;
            };
          };
        };
    in packages {
      ghc = parent.ghcjs // { inherit parent; };
      cabalPackage = import ../build-support/cabal/ghcjs.nix;
      ghcWrapperPackage = import ../development/compilers/ghcjs/wrapper.nix;
      prefFun = self : super : super // {
        # This is the list of packages that are built into a booted ghcjs installation
        # It can be generated with the command:
        # nix-shell '<nixpkgs>' -A pkgs.haskellPackages_ghcjs.ghc --command "ghcjs-pkg list | sed -n 's/^    \(.*\)-\([0-9.]*\)$/\1_\2/ p' | sed 's/\./_/g' | sed 's/-\(.\)/\U\1/' | sed 's/^\([^_]*\)\(.*\)$/\1\2 = null;\n\1 = self.\1\2;/'"
        Cabal_1_21_0_0 = null;
        Cabal = self.Cabal_1_21_0_0;
        aeson_0_8_0_0 = null;
        aeson = self.aeson_0_8_0_0;
        array_0_5_0_0 = null;
        array = self.array_0_5_0_0;
        async_2_0_1_5 = null;
        async = self.async_2_0_1_5;
        attoparsec_0_12_1_0 = null;
        attoparsec = self.attoparsec_0_12_1_0;
        base_4_7_0_1 = null;
        base = self.base_4_7_0_1;
        binary_0_7_2_1 = null;
        binary = self.binary_0_7_2_1;
        rts_1_0 = null;
        rts = self.rts_1_0;
        # bytestring_0_10_4_1 = null;
        # bytestring = self.bytestring_0_10_4_1;
        caseInsensitive_1_2_0_0 = null;
        caseInsensitive = self.caseInsensitive_1_2_0_0;
        containers_0_5_5_1 = null;
        containers = self.containers_0_5_5_1;
        deepseq_1_3_0_2 = null;
        deepseq = self.deepseq_1_3_0_2;
        directory_1_2_1_0 = null;
        directory = self.directory_1_2_1_0;
        dlist_0_7_0_1 = null;
        dlist = self.dlist_0_7_0_1;
        extensibleExceptions_0_1_1_3 = null;
        extensibleExceptions = self.extensibleExceptions_0_1_1_3;
        filepath_1_3_0_2 = null;
        filepath = self.filepath_1_3_0_2;
        ghcPrim_0_3_1_0 = null;
        ghcPrim = self.ghcPrim_0_3_1_0;
        ghcjsBase_0_1_0_0 = null;
        ghcjsBase = self.ghcjsBase_0_1_0_0;
        ghcjsPrim_0_1_0_0 = null;
        ghcjsPrim = self.ghcjsPrim_0_1_0_0;
        hashable_1_2_2_0 = null;
        hashable = self.hashable_1_2_2_0;
        integerGmp_0_5_1_0 = null;
        integerGmp = self.integerGmp_0_5_1_0;
        mtl_2_2_1 = null;
        mtl = self.mtl_2_2_1;
        oldLocale_1_0_0_6 = null;
        oldLocale = self.oldLocale_1_0_0_6;
        oldTime_1_1_0_2 = null;
        oldTime = self.oldTime_1_1_0_2;
        parallel_3_2_0_4 = null;
        parallel = self.parallel_3_2_0_4;
        pretty_1_1_1_1 = null;
        pretty = self.pretty_1_1_1_1;
        primitive_0_5_3_0 = null;
        primitive = self.primitive_0_5_3_0;
        process_1_2_0_0 = null;
        process = self.process_1_2_0_0;
        scientific_0_3_3_0 = null;
        scientific = self.scientific_0_3_3_0;
        stm_2_4_3 = null;
        stm = self.stm_2_4_3;
        syb_0_4_2 = null;
        syb = self.syb_0_4_2;
        # templateHaskell_2_9_0_0 = null;
        # templateHaskell = self.templateHaskell_2_9_0_0;
        text_1_1_1_3 = null;
        text = self.text_1_1_1_3;
        time_1_4_2 = null;
        time = self.time_1_4_2;
        transformers_0_4_1_0 = null;
        transformers = self.transformers_0_4_1_0;
        unix_2_7_0_1 = null;
        unix = self.unix_2_7_0_1;
        unorderedContainers_0_2_5_0 = null;
        unorderedContainers = self.unorderedContainers_0_2_5_0;
        vector_0_10_11_0 = null;
        vector = self.vector_0_10_11_0;

        # This is necessary because haskell-packages will refuse to generate tfRandom for this version of ghc (0.1.0)
        #TODO: haskell-packages shouldn't use the ghcjs version as the ghc version
        tfRandom = self.callPackage ../development/libraries/haskell/tf-random {};

/*
        buildLocalCabalWithArgs = { src, name, args ? {}, cabalDrvArgs ? { jailbreak = true; }, cabal2nix ? packages_ghc783.cabal2nix }: let
          cabalExpr = pkgs.stdenv.mkDerivation ({
            name = "${name}.nix";

            buildCommand = ''
            ${cabal2nix}/bin/cabal2nix ${src + "/${name}.cabal"} --sha256=FILTERME \
                | grep -v FILTERME | sed \
                  -e 's/licenses.proprietary/licenses.unfree/' \
                  -e 's/{ cabal/{ cabal, cabalInstall, cabalDrvArgs ? {}, src/' \
                  -e 's/cabal.mkDerivation (self: {/cabal.mkDerivation (self: cabalDrvArgs \/\/ {/' \
                  -e 's/buildDepends = \[/buildDepends = \[ cabalInstall/' \
                  -e 's/pname = \([^\n]*\)/pname = \1\n  inherit src;\n/'  > $out
            '';

          } // pkgs.lib.optionalAttrs pkgs.stdenv.isLinux {
            LANG = "en_US.UTF-8";
            LOCALE_ARCHIVE = "${pkgs.glibcLocales}/lib/locale/locale-archive";
          });
        in self.callPackage cabalExpr ({ inherit src cabalDrvArgs; } // args);
*/
      };
      extension = self: super: {
        buildLocalCabalWithArgs = args: super.buildLocalCabalWithArgs (args // {
          nativePkgs = packages_ghc783;
        });
      };
    };

  packages_ghc763 =
    packages { ghcPath = ../development/compilers/ghc/7.6.3.nix;
               ghcBinary = ghc704Binary;
               prefFun = ghc763Prefs;
             };

  packages_ghc742 =
    packages { ghcPath = ../development/compilers/ghc/7.4.2.nix;
               ghcBinary = ghc6121BinaryDarwin;
               prefFun = ghc742Prefs;
             };

  packages_ghc722 =
    packages { ghcPath = ../development/compilers/ghc/7.2.2.nix;
               ghcBinary = ghc6121BinaryDarwin;
               prefFun = ghc722Prefs;
             };

  packages_ghc704 =
    packages { ghcPath = ../development/compilers/ghc/7.0.4.nix;
               ghcBinary = ghc6101BinaryDarwin;
               prefFun = ghc704Prefs;
             };

  packages_ghc6123 =
    packages { ghcPath = ../development/compilers/ghc/6.12.3.nix;
               prefFun = ghc6123Prefs;
             };

  packages_ghc6104 =
    packages { ghcPath = ../development/compilers/ghc/6.10.4.nix;
               prefFun = ghc6104Prefs;
             };

}
