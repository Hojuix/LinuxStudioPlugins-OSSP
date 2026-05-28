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

## How to use
The current PoC will only work on GLibC aarch64 (Tested on a Raspberry Pi)<br>
Step 1 - Download the official LSP Plugins source code<br>
Step 2 - Run `build-aarch64-PoC.sh`<br>
Step 3 - Do a native build for the `utils-bin/lv2ttl_gen` executable<br>
         - I don't think `lv2ttl_gen` and the target's archtecture `lsp-plugins-lv2.so` have to be the same.<br>
         - Oh and yes, this will be added into this build system (probably)<br>
Step 4 - Run `lv2ttl_gen` against the generated `.so` file with: `mkdir out && ./lv2ttl_gen -i lv2-plugins-lv2.so -o out`<br>
And that's it. Copy the required `ttl` file along with `manifest.ttl` and `lv2-plugins-lv2.so` to the LV2 directory.
