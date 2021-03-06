{ cabal, bifunctors, comonad, contravariant, deepseq, distributive
, doctest, exceptions, filepath, free, genericDeriving, hashable
, hlint, HUnit, mtl, nats, parallel, primitive, profunctors
, QuickCheck, reflection, semigroupoids, semigroups, simpleReflect
, split, tagged, testFramework, testFrameworkHunit
, testFrameworkQuickcheck2, testFrameworkTh, text, transformers
, transformersCompat, unorderedContainers, vector, void, zlib
}:

cabal.mkDerivation (self: {
  pname = "lens";
  version = "4.4.0.2";
  sha256 = "03h1r6np1aas5nnw3nsqcvl9an9yriikcgapnfck82pmmdvg5l47";
  buildDepends = [
    bifunctors comonad contravariant distributive exceptions filepath
    free hashable mtl parallel primitive profunctors reflection
    semigroupoids semigroups split tagged text transformers
    transformersCompat unorderedContainers vector void zlib
  ];
  testDepends = [
    deepseq doctest filepath genericDeriving hlint HUnit mtl nats
    parallel QuickCheck semigroups simpleReflect split testFramework
    testFrameworkHunit testFrameworkQuickcheck2 testFrameworkTh text
    transformers unorderedContainers vector
  ];
  patchPhase = ''
    configureFlags="-f-test-hlint"
  '';
  meta = {
    homepage = "http://github.com/ekmett/lens/";
    description = "Lenses, Folds and Traversals";
    license = self.stdenv.lib.licenses.bsd3;
    platforms = self.ghc.meta.platforms;
  };
})
