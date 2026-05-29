# Linux Studio Plugins (Fork for OSSP)

## Information
This fork of LSP Plugins contains the smallest amount of code required from the upstream LSP Plugins repository for the features
that OSSP utilizes, pulled out-of-tree with minimal patching and a custom build system that is much smaller, but much
easier to deal with.
(Yes, it comes with many downsides, but this fork has a specific purpose with a preset configuration).
OSSP does not use much of LSP Plugins (A couple filters and the LV2 backend), but it does support many operating systems
that upstream LSP Plugins does not support. As I have added support for these operating systems (Multiple BSDs, Android
in progress), the build system has become a huge pain point. This solves that.<br>

The patched source code and patches are based off LSP Plugins release version 1.2.29.
The `patched_src` folder contains the required parts of the LSP Plugins source code, while the `patches` directory
contain the `.patch` files.

## Dependencies
The only (dynamically linked) runtime dependency when used as an LV2 component is `libsndfile`.
A static version of `libsndfile` cannot be linked into `lsp-plugins-lv2.so` (at least in an Android
context using the Android NDK) because it, for some reason unbeknownst to me, somehow enables `GWP-ASan`,
which Bionic LibC's `libdl()` seems to absolutely hate. I haven't tested this on other platforms at this time
(2026/05/28) as this out-of-tree build system doesn't support x86_64 yet. This is very easy to work around though,
as you can just load `libsndfile.so` using `System.loadLibrary()` at application init time.

## Changes against upstream LSP Plugins
NOTE: All changes made against upstream LSP Plugins contains a `// HOJUIX PATCH` line near them, so you can easily
`grep` for them around the modified codebase.
1 - A new `android-compat` folder.
    - As the name implies, this folder contains code to allow LSP Plugins to both compile and run under Android,
    or more specifically Bionic LibC. At this point, the only addition it contains is an SHM (Shared
    memory) compatibility layer (Copied and modified from Termux's implementation)
2 - `lsp-common-lib/src/main/stdlib.cpp` - QSort modification
    - A lot of platforms either have different implementations or just don't implement QSort in their standard
    libraries. I don't really understand where and how this code is used, but with the modules that OSSP utilizes,
    nothing changes if this code is removed. This patch removes the code if there is not already a pre-existing
    implementation in the source code. If at a later date OSSP requires a plugin that utilizes this code,
    of course implementations for Android, OpenBSD, and NetBSD will be added.
3 - `lsp-runtime-lib/src/main/runtime/system.cpp` - secure_getenv() modification
    - As far as I know, `secure_getenv()` is missing under Bionic LibC. Substituted for the standard
    `getenv()` instead when compiling for Android NDK based platforms.
4 - `lsp-runtime-lib/src/main/ipc/SharedMem.cpp` - Use SHM (Shared Memory) functions from `android-compat`
    - Include `shm_shim.h` from `android-compat` and utilize `bionic_shm_open()` and `bionic_shm_unlink()`
    instead `shm_open()` and `shm_unlink()` when compiling with the Android NDK.
5 - `lsp-runtime-lib/src/main/ipc/SharedMutex.cpp` - Same as `SharedMem.cpp` above,
    - Also use an SHM shim function (for `shm_open()`), and remove some pthread functions. To be completely
    honest, I just removed these if compiling with the Android NDK, and everything seems to work absolutely fine.
    Of course, if these are required in the future, I will patch this properly.

## How to use
The current PoC will only work on GLibC aarch64 (Tested on a Raspberry Pi)<br>
Step 1 - Download the official LSP Plugins source code<br>
Step 2 - Run `build-aarch64-PoC.sh`<br>
Step 3 - Do a native build for the `utils-bin/lv2ttl_gen` executable<br>
         - I don't think `lv2ttl_gen` and the target's archtecture `lsp-plugins-lv2.so` have to be the same.<br>
         - Oh and yes, this will be added into this build system (probably)<br>
Step 4 - Run `lv2ttl_gen` against the generated `.so` file with: `mkdir out && ./lv2ttl_gen -i lv2-plugins-lv2.so -o out`<br>
And that's it. Copy the required `ttl` file along with `manifest.ttl` and `lv2-plugins-lv2.so` to the LV2 directory.
