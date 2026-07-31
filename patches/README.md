# Maintained source patches

Apply in this order with `scripts/apply-patches.sh`:

1. `2ship-ios.patch` at the pinned 2S2H root;
2. `libultraship-ios.patch` in its pinned submodule;
3. `zapdtr-ios.patch` in its pinned submodule;
4. copy `port/CMake/ios.cmake` and `ios/` as new source overlays.

The release verifier requires every patch to reverse-apply against the tested
checkout and every overlay file to match byte-for-byte.
