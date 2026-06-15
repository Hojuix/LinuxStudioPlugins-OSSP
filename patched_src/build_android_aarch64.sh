set -e # Exit on error

LD=/home/user/Desktop/android-ndk-r27d/toolchains/llvm/prebuilt/linux-x86_64/bin/ld.lld
CXX=/home/user/Desktop/android-ndk-r27d/toolchains/llvm/prebuilt/linux-x86_64/bin/aarch64-linux-android31-clang++

# Using '-I .' in CFLAGS so I can include the android compatbility stuff with '#include <android-compat/...>'
CFLAGS="-fPIC -march=armv8-a -O2 -fvisibility=hidden -fno-exceptions -fno-rtti -fdata-sections -ffunction-sections -fno-asynchronous-unwind-tables -pipe -Wall -I ."
SYSROOT="/home/user/Desktop/Actual_LSP_Sysroot"
SYSROOT_INC=$SYSROOT/include
SYSROOT_LIB=$SYSROOT/lib

# Make folders
mkdir -p build-lsp-common-lib/src/main

build_lsp_common_lib() {
    echo "B $1"
    file=$1
    root="${file%.cpp}"
    ofile="build-$root.o"
    dfile="build-$root.d"

    $CXX \
        -o $ofile \
        -c $file \
        $CFLAGS \
        -DLSP_COMMON_LIB_BUILTIN -fvisibility=hidden \
        -I lsp-common-lib/include \
        -DLSP_COMMON_LIB_BUILTIN \
        -MMD -MP -MF $dfile -MT $ofile \
        -I $SYSROOT_INC
}

build_lsp_dsp_lib() {
    echo "B $1"
    file=$1
    root="${file%.cpp}"
    ofile="build-$root.o"
    dfile="build-$root.d"

    $CXX \
        -o $ofile \
        -c $file \
        $CFLAGS \
        -DLSP_DSP_LIB_BUILTIN -fvisibility=hidden -DUSE_LIBPTHREAD -DUSE_LSP_COMMON_LIB \
        -I lsp-common-lib/include -DLSP_COMMON_LIB_BUILTIN \
        -I lsp-dsp-lib/include -DLSP_DSP_LIB_BUILTIN \
        -MMD -MP -MF $dfile -MT $ofile \
        -I $SYSROOT_INC
}

build_lsp_dsp_units() {
    echo "B $1"
    file=$1
    root="${file%.cpp}"
    ofile="build-$root.o"
    dfile="build-$root.d"

    $CXX \
        -o $ofile \
        -c $file \
        $CFLAGS \
        -DLSP_DSP_UNITS_BUILTIN -fvisibility=hidden -DUSE_LSP_COMMON_LIB -DUSE_LSP_DSP_LIB -DUSE_LSP_LLTL_LIB \
        -DUSE_LSP_RUNTIME_LIB -DUSE_LIBPTHREAD -DUSE_LIBDL -DUSE_LIBRT -DUSE_LIBSNDFILE \
        -I lsp-common-lib/include -DLSP_COMMON_LIB_BUILTIN \
        -I lsp-dsp-lib/include -DLSP_DSP_LIB_BUILTIN \
        -I lsp-lltl-lib/include -DLSP_LLTL_LIB_BUILTIN \
        -I lsp-runtime-lib/include -DLSP_RUNTIME_LIB_BUILTIN \
        -I /usr/include/opus -I/usr/include/aarch64-linux-gnu \
        -I lsp-dsp-units/include -DSP_DSP_UNITS_BUILTIN \
        -MMD -MP -MF $dfile -MT $ofile \
        -I $SYSROOT_INC
}

build_lsp_lltl_lib() {
    echo "B $1"
    file=$1
    root="${file%.cpp}"
    ofile="build-$root.o"
    dfile="build-$root.d"

    $CXX \
        -o $ofile \
        -c $file \
        $CFLAGS \
        -DLSP_LLTL_LIB_BUILTIN -fvisibility=hidden -DUSE_LSP_COMMON_LIB \
        -I lsp-common-lib/include -DLSP_COMMON_LIB_BUILTIN \
        -I lsp-lltl-lib/include -DLSP_LLTL_LIB_BUILTIN \
        -MMD -MP -MF $dfile -MT $ofile \
        -I $SYSROOT_INC
}

build_lsp_runtime_lib() {
    echo "B $1"
    file=$1
    root="${file%.cpp}"
    ofile="build-$root.o"
    dfile="build-$root.d"

    $CXX \
        -o $ofile \
        -c $file \
        $CFLAGS \
        -DLSP_RUNTIME_LIB_BUILTIN -fvisibility=hidden -DUSE_LSP_COMMON_LIB -DUSE_LSP_LLTL_LIB -DUSE_LIBPTHREAD -DUSE_LIBDL \
        -DUSE_LIBRT -DUSE_LIBSNDFILE \
        -I lsp-common-lib/include -DLSP_COMMON_LIB_BUILTIN \
        -I lsp-lltl-lib/include -DLSP_LLTL_LIB_BUILTIN \
        -I /usr/include/opus -I /usr/include/aarch64-linux-gnu \
        -I lsp-runtime-lib/include -DLSP_RUNTIME_LIB_BUILTIN \
        -MMD -MP -MF $dfile -MT $ofile \
        -I $SYSROOT_INC
}

build_lsp_plugin_fw() {
    echo "B $1"
    file=$1
    root="${file%.cpp}"
    ofile="build-$root.o"
    dfile="build-$root.d"

    $CXX \
        -o $ofile \
        -c $file \
        $CFLAGS \
        -DLSP_INSTALL_PREFIX="/usr/local" \
        -DUSE_LIBCAIRO -DUSE_LIBDL -DUSE_LIBPTHREAD -DUSE_LIBRT -DUSE_LIBSNDFILE \
        -DUSE_LSP_3RD_PARTY -DUSE_LSP_COMMON_LIB -DUSE_LSP_DSP_LIB -DUSE_LSP_DSP_UNITS -DUSE_LSP_LLTL_LIB \
        -DUSE_LSP_PLUGINS_SHARED -DUSE_LSP_PLUGIN_FW -DUSE_LSP_RUNTIME_LIB \
        -I /usr/include/opus -I /usr/include/aarch64-linux-gnu \
        -idirafter "lsp-3rd-party/include" \
        -I lsp-common-lib/include -DLSP_COMMON_LIB_BUILTIN \
        -I lsp-dsp-lib/include -DLSP_DSP_LIB_BUILTIN \
        -I lsp-dsp-units/include -DLSP_DSP_UNITS_BUILTIN \
        -I lsp-lltl-lib/include -DLSP_LLTL_LIB_BUILTIN \
        -I lsp-plugins-shared/include -DLSP_PLUGINS_SHARED_BUILTIN -DLSP_PLUGINS_SHARED_PUBLISHER \
        -I lsp-plugin-fw/include -DLSP_PLUGIN_FW_BUILTIN \
        -I lsp-runtime-lib/include -DLSP_RUNTIME_LIB_BUILTIN \
        -DWITH_LV2_FEATURE \
        -MMD -MP -MF $dfile -MT $ofile \
        -I $SYSROOT_INC
}

build_lsp_plugins_para_equalizer() {
    echo "B $1"
    file=$1
    root="${file%.cpp}"
    ofile="build-$root.o"
    dfile="build-$root.d"

    $CXX \
        -o $ofile \
        -c $file \
        $CFLAGS \
        -I lsp-common-lib/include -DLSP_COMMON_LIB_BUILTIN \
        -I lsp-dsp-lib/include -DLSP_DSP_LIB_BUILTIN \
        -I lsp-dsp-units/include -DLSP_DSP_UNITS_BUILTIN \
        -I lsp-lltl-lib/include -DLSP_LLTL_LIB_BUILTIN \
        -I lsp-runtime-lib/include -DLSP_RUNTIME_LIB_BUILTIN \
        -I lsp-plugins-shared/include -DLSP_PLUGINS_SHARED_BUILTIN -DLSP_PLUGINS_SHARED_PUBLISHER \
        -idirafter "lsp-3rd-party/include" \
        -I lsp-plugin-fw/include -DLSP_PLUGIN_FW_BUILTIN \
        -I lsp-r3d-iface/include -DLSP_R3D_IFACE_BUILTIN \
        -I lsp-ws-lib/include -DLSP_WS_LIB_BUILTIN \
        -I lsp-tk-lib/include -DLSP_TK_LIB_BUILTIN \
        -I lsp-r3d-base-lib/include -DLSP_R3D_BASE_LIB_BUILTIN \
        -I /usr/include/opus -I /usr/include/aarch64-linux-gnu \
        -I lsp-r3d-glx-lib/include -DLSP_R3D_GLX_LIB_BUILTIN -DLSP_R3D_GLX_LIB_PUBLISHER \
        -I lsp-plugins-para-equalizer/include -DLSP_PLUGINS_PARA_EQUALIZER_BUILTIN -DLSP_PLUGINS_PARA_EQUALIZER_PUBLISHER \
        -MMD -MP -MF $dfile -MT $ofile \
        -I $SYSROOT_INC
}

build_lsp_common_lib "lsp-common-lib/src/main/atomic.cpp"
build_lsp_common_lib "lsp-common-lib/src/main/bits.cpp"
build_lsp_common_lib "lsp-common-lib/src/main/atomic.cpp"
build_lsp_common_lib "lsp-common-lib/src/main/bits.cpp"
build_lsp_common_lib "lsp-common-lib/src/main/debug.cpp"
build_lsp_common_lib "lsp-common-lib/src/main/locale.cpp"
build_lsp_common_lib "lsp-common-lib/src/main/singletone.cpp"
build_lsp_common_lib "lsp-common-lib/src/main/status.cpp"
build_lsp_common_lib "lsp-common-lib/src/main/stdio.cpp"
build_lsp_common_lib "lsp-common-lib/src/main/stdlib.cpp"
build_lsp_common_lib "lsp-common-lib/src/main/types.cpp"

echo "LD lsp-common-lib.o"
$LD \
    -o build-lsp-common-lib/lsp-common-lib.o \
    -r build-lsp-common-lib/src/main/atomic.o \
    -r build-lsp-common-lib/src/main/bits.o \
    -r build-lsp-common-lib/src/main/debug.o \
    -r build-lsp-common-lib/src/main/locale.o \
    -r build-lsp-common-lib/src/main/singletone.o \
    -r build-lsp-common-lib/src/main/status.o \
    -r build-lsp-common-lib/src/main/stdio.o \
    -r build-lsp-common-lib/src/main/stdlib.o \
    -r build-lsp-common-lib/src/main/types.o

mkdir -p build-lsp-dsp-lib/src/main
mkdir -p build-lsp-dsp-lib/src/main/generic
mkdir -p build-lsp-dsp-lib/src/main/aarch64

build_lsp_dsp_lib "lsp-dsp-lib/src/main/dsp.cpp"
build_lsp_dsp_lib "lsp-dsp-lib/src/main/generic/generic.cpp"
build_lsp_dsp_lib "lsp-dsp-lib/src/main/aarch64/aarch64.cpp"
build_lsp_dsp_lib "lsp-dsp-lib/src/main/aarch64/asimd.cpp"

echo "LD lsp-dsp-lib.o"
$LD \
    -o build-lsp-dsp-lib/lsp-dsp-lib.o \
    -r build-lsp-dsp-lib/src/main/dsp.o \
    -r build-lsp-dsp-lib/src/main/generic/generic.o \
    -r build-lsp-dsp-lib/src/main/aarch64/aarch64.o \
    -r build-lsp-dsp-lib/src/main/aarch64/asimd.o

mkdir -p build-lsp-dsp-units/src/main/3d
mkdir -p build-lsp-dsp-units/src/main/3d/bsp
mkdir -p build-lsp-dsp-units/src/main/3d/rt
mkdir -p build-lsp-dsp-units/src/main/ctl
mkdir -p build-lsp-dsp-units/src/main/dynamics
mkdir -p build-lsp-dsp-units/src/main/filters
mkdir -p build-lsp-dsp-units/src/main/iface
mkdir -p build-lsp-dsp-units/src/main/meters
mkdir -p build-lsp-dsp-units/src/main/misc
mkdir -p build-lsp-dsp-units/src/main/noise
mkdir -p build-lsp-dsp-units/src/main/sampling
mkdir -p build-lsp-dsp-units/src/main/sampling/helpers
mkdir -p build-lsp-dsp-units/src/main/shared
mkdir -p build-lsp-dsp-units/src/main/stat
mkdir -p build-lsp-dsp-units/src/main/util

build_lsp_dsp_units "lsp-dsp-units/src/main/3d/Allocator.cpp"
build_lsp_dsp_units "lsp-dsp-units/src/main/3d/bsp/context.cpp"
build_lsp_dsp_units "lsp-dsp-units/src/main/3d/Object3D.cpp"
build_lsp_dsp_units "lsp-dsp-units/src/main/3d/RayTrace3D.cpp"
build_lsp_dsp_units "lsp-dsp-units/src/main/3d/raytrace.cpp"
build_lsp_dsp_units "lsp-dsp-units/src/main/3d/rt/context.cpp"
build_lsp_dsp_units "lsp-dsp-units/src/main/3d/rt/mesh.cpp"
build_lsp_dsp_units "lsp-dsp-units/src/main/3d/rt/plan.cpp"
build_lsp_dsp_units "lsp-dsp-units/src/main/ctl/Blink.cpp"
build_lsp_dsp_units "lsp-dsp-units/src/main/ctl/Bypass.cpp"
build_lsp_dsp_units "lsp-dsp-units/src/main/ctl/Counter.cpp"
build_lsp_dsp_units "lsp-dsp-units/src/main/ctl/Crossfade.cpp"
build_lsp_dsp_units "lsp-dsp-units/src/main/ctl/Toggle.cpp"
build_lsp_dsp_units "lsp-dsp-units/src/main/dynamics/AutoGain.cpp"
build_lsp_dsp_units "lsp-dsp-units/src/main/dynamics/Compressor.cpp"
build_lsp_dsp_units "lsp-dsp-units/src/main/dynamics/DynamicProcessor.cpp"
build_lsp_dsp_units "lsp-dsp-units/src/main/dynamics/Expander.cpp"
build_lsp_dsp_units "lsp-dsp-units/src/main/dynamics/Gate.cpp"
build_lsp_dsp_units "lsp-dsp-units/src/main/dynamics/Limiter.cpp"
build_lsp_dsp_units "lsp-dsp-units/src/main/dynamics/SimpleAutoGain.cpp"
build_lsp_dsp_units "lsp-dsp-units/src/main/dynamics/SurgeProtector.cpp"
build_lsp_dsp_units "lsp-dsp-units/src/main/filters/ButterworthFilter.cpp"
build_lsp_dsp_units "lsp-dsp-units/src/main/filters/DynamicFilters.cpp"
build_lsp_dsp_units "lsp-dsp-units/src/main/filters/Equalizer.cpp"
build_lsp_dsp_units "lsp-dsp-units/src/main/filters/FilterBank.cpp"
build_lsp_dsp_units "lsp-dsp-units/src/main/filters/Filter.cpp"
build_lsp_dsp_units "lsp-dsp-units/src/main/filters/SpectralTilt.cpp"
build_lsp_dsp_units "lsp-dsp-units/src/main/iface/IStateDumper.cpp"
build_lsp_dsp_units "lsp-dsp-units/src/main/meters/Correlometer.cpp"
build_lsp_dsp_units "lsp-dsp-units/src/main/meters/ILUFSMeter.cpp"
build_lsp_dsp_units "lsp-dsp-units/src/main/meters/LoudnessMeter.cpp"
build_lsp_dsp_units "lsp-dsp-units/src/main/meters/Panometer.cpp"
build_lsp_dsp_units "lsp-dsp-units/src/main/meters/PeakMeter.cpp"
build_lsp_dsp_units "lsp-dsp-units/src/main/meters/TruePeakMeter.cpp"
build_lsp_dsp_units "lsp-dsp-units/src/main/misc/broadcast.cpp"
build_lsp_dsp_units "lsp-dsp-units/src/main/misc/envelope.cpp"
build_lsp_dsp_units "lsp-dsp-units/src/main/misc/fade.cpp"
build_lsp_dsp_units "lsp-dsp-units/src/main/misc/fft_crossover.cpp"
build_lsp_dsp_units "lsp-dsp-units/src/main/misc/interpolation.cpp"
build_lsp_dsp_units "lsp-dsp-units/src/main/misc/lfo.cpp"
build_lsp_dsp_units "lsp-dsp-units/src/main/misc/sigmoid.cpp"
build_lsp_dsp_units "lsp-dsp-units/src/main/misc/windows.cpp"
build_lsp_dsp_units "lsp-dsp-units/src/main/noise/Generator.cpp"
build_lsp_dsp_units "lsp-dsp-units/src/main/noise/LCG.cpp"
build_lsp_dsp_units "lsp-dsp-units/src/main/noise/MLS.cpp"
build_lsp_dsp_units "lsp-dsp-units/src/main/noise/Velvet.cpp"
build_lsp_dsp_units "lsp-dsp-units/src/main/sampling/helpers/batch.cpp"
build_lsp_dsp_units "lsp-dsp-units/src/main/sampling/helpers/playback.cpp"
build_lsp_dsp_units "lsp-dsp-units/src/main/sampling/InSampleStream.cpp"
build_lsp_dsp_units "lsp-dsp-units/src/main/sampling/Playback.cpp"
build_lsp_dsp_units "lsp-dsp-units/src/main/sampling/PlaySettings.cpp"
build_lsp_dsp_units "lsp-dsp-units/src/main/sampling/Sample.cpp"
build_lsp_dsp_units "lsp-dsp-units/src/main/sampling/SamplePlayer.cpp"
build_lsp_dsp_units "lsp-dsp-units/src/main/shared/AudioStream.cpp"
build_lsp_dsp_units "lsp-dsp-units/src/main/shared/Catalog.cpp"
build_lsp_dsp_units "lsp-dsp-units/src/main/stat/QuantizedCounter.cpp"
build_lsp_dsp_units "lsp-dsp-units/src/main/util/ADSREnvelope.cpp"
build_lsp_dsp_units "lsp-dsp-units/src/main/util/Analyzer.cpp"
build_lsp_dsp_units "lsp-dsp-units/src/main/util/Convolver.cpp"
build_lsp_dsp_units "lsp-dsp-units/src/main/util/Crossover.cpp"
build_lsp_dsp_units "lsp-dsp-units/src/main/util/Delay.cpp"
build_lsp_dsp_units "lsp-dsp-units/src/main/util/Depopper.cpp"
build_lsp_dsp_units "lsp-dsp-units/src/main/util/Dither.cpp"
build_lsp_dsp_units "lsp-dsp-units/src/main/util/DynamicDelay.cpp"
build_lsp_dsp_units "lsp-dsp-units/src/main/util/FFTCrossover.cpp"
build_lsp_dsp_units "lsp-dsp-units/src/main/util/LatencyDetector.cpp"
build_lsp_dsp_units "lsp-dsp-units/src/main/util/MeterGraph.cpp"
build_lsp_dsp_units "lsp-dsp-units/src/main/util/MultiSpectralProcessor.cpp"
build_lsp_dsp_units "lsp-dsp-units/src/main/util/Oscillator.cpp"
build_lsp_dsp_units "lsp-dsp-units/src/main/util/Oversampler.cpp"
build_lsp_dsp_units "lsp-dsp-units/src/main/util/Randomizer.cpp"
build_lsp_dsp_units "lsp-dsp-units/src/main/util/RawRingBuffer.cpp"
build_lsp_dsp_units "lsp-dsp-units/src/main/util/ResponseTaker.cpp"
build_lsp_dsp_units "lsp-dsp-units/src/main/util/RingBuffer.cpp"
build_lsp_dsp_units "lsp-dsp-units/src/main/util/ScaledMeterGraph.cpp"
build_lsp_dsp_units "lsp-dsp-units/src/main/util/ShiftBuffer.cpp"
build_lsp_dsp_units "lsp-dsp-units/src/main/util/Sidechain.cpp"
build_lsp_dsp_units "lsp-dsp-units/src/main/util/SpectralProcessor.cpp"
build_lsp_dsp_units "lsp-dsp-units/src/main/util/SpectralSplitter.cpp"
build_lsp_dsp_units "lsp-dsp-units/src/main/util/SyncChirpProcessor.cpp"
build_lsp_dsp_units "lsp-dsp-units/src/main/util/Trigger.cpp"

echo "LD lsp-dsp-units.o"
$LD \
    -o build-lsp-dsp-units/lsp-dsp-units.o \
    -r build-lsp-dsp-units/src/main/3d/Allocator.o \
    -r build-lsp-dsp-units/src/main/3d/bsp/context.o \
    -r build-lsp-dsp-units/src/main/3d/Object3D.o \
    -r build-lsp-dsp-units/src/main/3d/RayTrace3D.o \
    -r build-lsp-dsp-units/src/main/3d/raytrace.o \
    -r build-lsp-dsp-units/src/main/3d/rt/context.o \
    -r build-lsp-dsp-units/src/main/3d/rt/mesh.o \
    -r build-lsp-dsp-units/src/main/3d/rt/plan.o \
    -r build-lsp-dsp-units/src/main/ctl/Blink.o \
    -r build-lsp-dsp-units/src/main/ctl/Bypass.o \
    -r build-lsp-dsp-units/src/main/ctl/Counter.o \
    -r build-lsp-dsp-units/src/main/ctl/Crossfade.o \
    -r build-lsp-dsp-units/src/main/ctl/Toggle.o \
    -r build-lsp-dsp-units/src/main/dynamics/AutoGain.o \
    -r build-lsp-dsp-units/src/main/dynamics/Compressor.o \
    -r build-lsp-dsp-units/src/main/dynamics/DynamicProcessor.o \
    -r build-lsp-dsp-units/src/main/dynamics/Expander.o \
    -r build-lsp-dsp-units/src/main/dynamics/Gate.o \
    -r build-lsp-dsp-units/src/main/dynamics/Limiter.o \
    -r build-lsp-dsp-units/src/main/dynamics/SimpleAutoGain.o \
    -r build-lsp-dsp-units/src/main/dynamics/SurgeProtector.o \
    -r build-lsp-dsp-units/src/main/filters/ButterworthFilter.o \
    -r build-lsp-dsp-units/src/main/filters/DynamicFilters.o \
    -r build-lsp-dsp-units/src/main/filters/Equalizer.o \
    -r build-lsp-dsp-units/src/main/filters/FilterBank.o \
    -r build-lsp-dsp-units/src/main/filters/Filter.o \
    -r build-lsp-dsp-units/src/main/filters/SpectralTilt.o \
    -r build-lsp-dsp-units/src/main/iface/IStateDumper.o \
    -r build-lsp-dsp-units/src/main/meters/Correlometer.o \
    -r build-lsp-dsp-units/src/main/meters/ILUFSMeter.o \
    -r build-lsp-dsp-units/src/main/meters/LoudnessMeter.o \
    -r build-lsp-dsp-units/src/main/meters/Panometer.o \
    -r build-lsp-dsp-units/src/main/meters/PeakMeter.o \
    -r build-lsp-dsp-units/src/main/meters/TruePeakMeter.o \
    -r build-lsp-dsp-units/src/main/misc/broadcast.o \
    -r build-lsp-dsp-units/src/main/misc/envelope.o \
    -r build-lsp-dsp-units/src/main/misc/fade.o \
    -r build-lsp-dsp-units/src/main/misc/fft_crossover.o \
    -r build-lsp-dsp-units/src/main/misc/interpolation.o \
    -r build-lsp-dsp-units/src/main/misc/lfo.o \
    -r build-lsp-dsp-units/src/main/misc/sigmoid.o \
    -r build-lsp-dsp-units/src/main/misc/windows.o \
    -r build-lsp-dsp-units/src/main/noise/Generator.o \
    -r build-lsp-dsp-units/src/main/noise/LCG.o \
    -r build-lsp-dsp-units/src/main/noise/MLS.o \
    -r build-lsp-dsp-units/src/main/noise/Velvet.o \
    -r build-lsp-dsp-units/src/main/sampling/helpers/batch.o \
    -r build-lsp-dsp-units/src/main/sampling/helpers/playback.o \
    -r build-lsp-dsp-units/src/main/sampling/InSampleStream.o \
    -r build-lsp-dsp-units/src/main/sampling/Playback.o \
    -r build-lsp-dsp-units/src/main/sampling/PlaySettings.o \
    -r build-lsp-dsp-units/src/main/sampling/Sample.o \
    -r build-lsp-dsp-units/src/main/sampling/SamplePlayer.o \
    -r build-lsp-dsp-units/src/main/shared/AudioStream.o \
    -r build-lsp-dsp-units/src/main/shared/Catalog.o \
    -r build-lsp-dsp-units/src/main/stat/QuantizedCounter.o \
    -r build-lsp-dsp-units/src/main/util/ADSREnvelope.o \
    -r build-lsp-dsp-units/src/main/util/Analyzer.o \
    -r build-lsp-dsp-units/src/main/util/Convolver.o \
    -r build-lsp-dsp-units/src/main/util/Crossover.o \
    -r build-lsp-dsp-units/src/main/util/Delay.o \
    -r build-lsp-dsp-units/src/main/util/Depopper.o \
    -r build-lsp-dsp-units/src/main/util/Dither.o \
    -r build-lsp-dsp-units/src/main/util/DynamicDelay.o \
    -r build-lsp-dsp-units/src/main/util/FFTCrossover.o \
    -r build-lsp-dsp-units/src/main/util/LatencyDetector.o \
    -r build-lsp-dsp-units/src/main/util/MeterGraph.o \
    -r build-lsp-dsp-units/src/main/util/MultiSpectralProcessor.o \
    -r build-lsp-dsp-units/src/main/util/Oscillator.o \
    -r build-lsp-dsp-units/src/main/util/Oversampler.o \
    -r build-lsp-dsp-units/src/main/util/Randomizer.o \
    -r build-lsp-dsp-units/src/main/util/RawRingBuffer.o \
    -r build-lsp-dsp-units/src/main/util/ResponseTaker.o \
    -r build-lsp-dsp-units/src/main/util/RingBuffer.o \
    -r build-lsp-dsp-units/src/main/util/ScaledMeterGraph.o \
    -r build-lsp-dsp-units/src/main/util/ShiftBuffer.o \
    -r build-lsp-dsp-units/src/main/util/Sidechain.o \
    -r build-lsp-dsp-units/src/main/util/SpectralProcessor.o \
    -r build-lsp-dsp-units/src/main/util/SpectralSplitter.o \
    -r build-lsp-dsp-units/src/main/util/SyncChirpProcessor.o \
    -r build-lsp-dsp-units/src/main/util/Trigger.o

mkdir -p build-lsp-lltl-lib/src/main

build_lsp_lltl_lib "lsp-lltl-lib/src/main/bitset.cpp"
build_lsp_lltl_lib "lsp-lltl-lib/src/main/darray.cpp"
build_lsp_lltl_lib "lsp-lltl-lib/src/main/hash_index.cpp"
build_lsp_lltl_lib "lsp-lltl-lib/src/main/iterator.cpp"
build_lsp_lltl_lib "lsp-lltl-lib/src/main/parray.cpp"
build_lsp_lltl_lib "lsp-lltl-lib/src/main/phashset.cpp"
build_lsp_lltl_lib "lsp-lltl-lib/src/main/pphash.cpp"
build_lsp_lltl_lib "lsp-lltl-lib/src/main/ptrset.cpp"
build_lsp_lltl_lib "lsp-lltl-lib/src/main/state.cpp"
build_lsp_lltl_lib "lsp-lltl-lib/src/main/types.cpp"

echo "LD lsp-lltl-lib.o"
$LD \
    -o build-lsp-lltl-lib/lsp-lltl-lib.o \
    -r build-lsp-lltl-lib/src/main/bitset.o \
    -r build-lsp-lltl-lib/src/main/darray.o \
    -r build-lsp-lltl-lib/src/main/hash_index.o \
    -r build-lsp-lltl-lib/src/main/iterator.o \
    -r build-lsp-lltl-lib/src/main/parray.o \
    -r build-lsp-lltl-lib/src/main/phashset.o \
    -r build-lsp-lltl-lib/src/main/pphash.o \
    -r build-lsp-lltl-lib/src/main/ptrset.o \
    -r build-lsp-lltl-lib/src/main/state.o \
    -r build-lsp-lltl-lib/src/main/types.o

# lsp-plugins-shared is literally a single file, not going to make a function for that
mkdir -p build-lsp-plugins-shared/src/main/meta

$CXX \
    -o build-lsp-plugins-shared/src/main/meta/developers.o \
    -c lsp-plugins-shared/src/main/meta/developers.cpp \
    -fPIC -march=armv8-a -O2 -fvisibility=hidden -fno-exceptions -fno-rtti -fdata-sections -ffunction-sections \
    -fno-asynchronous-unwind-tables -pipe -Wall \
    -DUSE_LIBPTHREAD -DUSE_LSP_COMMON_LIB -DUSE_LSP_PLUGIN_FW \
    -I lsp-common-lib/include -DLSP_COMMON_LIB_BUILTIN \
    -I lsp-plugin-fw/include -DLSP_PLUGIN_FW_BUILTIN \
    -I lsp-plugins-shared/include -DLSP_PLUGINS_SHARED_BUILTIN -DLSP_PLUGINS_SHARED_PUBLISHER \
    -MMD -MP -MF build-lsp-plugins-shared/src/main/meta/developers.d -MT build-lsp-plugins-shared/src/main/meta/developers.o

$LD \
    -o build-lsp-plugins-shared/lsp-plugins-shared.o \
    -r build-lsp-plugins-shared/src/main/meta/developers.o
echo "Built lsp-plugins-shared"

mkdir -p build-lsp-runtime-lib/src/main/expr
mkdir -p build-lsp-runtime-lib/src/main/fmt
mkdir -p build-lsp-runtime-lib/src/main/fmt/bookmarks
mkdir -p build-lsp-runtime-lib/src/main/fmt/config
mkdir -p build-lsp-runtime-lib/src/main/fmt/java
mkdir -p build-lsp-runtime-lib/src/main/fmt/json/dom
mkdir -p build-lsp-runtime-lib/src/main/fmt/lnk
mkdir -p build-lsp-runtime-lib/src/main/fmt/lspc
mkdir -p build-lsp-runtime-lib/src/main/fmt/lspc/util
mkdir -p build-lsp-runtime-lib/src/main/fmt/obj
mkdir -p build-lsp-runtime-lib/src/main/fmt/sfz
mkdir -p build-lsp-runtime-lib/src/main/fmt/xml
mkdir -p build-lsp-runtime-lib/src/main/i18n
mkdir -p build-lsp-runtime-lib/src/main/io
mkdir -p build-lsp-runtime-lib/src/main/ipc
mkdir -p build-lsp-runtime-lib/src/main/mm
mkdir -p build-lsp-runtime-lib/src/main/protocol
mkdir -p build-lsp-runtime-lib/src/main/protocol/osc
mkdir -p build-lsp-runtime-lib/src/main/resource
mkdir -p build-lsp-runtime-lib/src/main/runtime

build_lsp_runtime_lib "lsp-runtime-lib/src/main/expr/EnvResolver.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/expr/evaluator.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/expr/Expression.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/expr/format.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/expr/functions.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/expr/Parameters.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/expr/parser.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/expr/Resolver.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/expr/Tokenizer.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/expr/types.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/expr/Variables.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/fmt/bookmarks/gtk.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/fmt/bookmarks/lnk.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/fmt/bookmarks/lsp.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/fmt/bookmarks/qt.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/fmt/bookmarks.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/fmt/config/IConfigHandler.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/fmt/config/PullParser.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/fmt/config/PushParser.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/fmt/config/Serializer.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/fmt/config/types.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/fmt/Hydrogen.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/fmt/java/const.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/fmt/java/defs.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/fmt/java/Enum.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/fmt/java/Handles.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/fmt/java/Object.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/fmt/java/ObjectStreamClass.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/fmt/java/ObjectStream.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/fmt/java/ObjectStreamField.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/fmt/java/RawArray.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/fmt/java/String.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/fmt/java/wrappers.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/fmt/json/dom/Array.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/fmt/json/dom/Boolean.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/fmt/json/dom/Double.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/fmt/json/dom/Integer.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/fmt/json/dom/Node.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/fmt/json/dom/Object.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/fmt/json/dom/String.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/fmt/json/dom.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/fmt/json/Parser.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/fmt/json/Serializer.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/fmt/json/token.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/fmt/json/Tokenizer.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/fmt/lnk/types.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/fmt/lspc/AudioReader.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/fmt/lspc/AudioWriter.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/fmt/lspc/ChunkAccessor.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/fmt/lspc/ChunkReader.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/fmt/lspc/ChunkReaderStream.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/fmt/lspc/ChunkWriter.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/fmt/lspc/ChunkWriterStream.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/fmt/lspc/File.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/fmt/lspc/IAudioFormatSelector.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/fmt/lspc/InAudioStream.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/fmt/lspc/util/audio.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/fmt/lspc/util/config.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/fmt/lspc/util/path.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/fmt/obj/Compressor.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/fmt/obj/Decompressor.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/fmt/obj/IObjHandler.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/fmt/obj/PullParser.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/fmt/obj/PushParser.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/fmt/RoomEQWizard.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/fmt/sfz/DocumentProcessor.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/fmt/sfz/IDocumentHandler.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/fmt/sfz/parse.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/fmt/sfz/PullParser.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/fmt/url.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/fmt/xml/const.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/fmt/xml/IXMLHandler.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/fmt/xml/PullParser.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/fmt/xml/PushParser.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/i18n/Dictionary.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/i18n/IDictionary.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/i18n/JsonDictionary.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/io/charset.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/io/CharsetDecoder.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/io/CharsetEncoder.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/io/Dir.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/io/File.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/io/IInSequence.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/io/IInStream.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/io/InBitStream.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/io/InFileStream.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/io/InMarkSequence.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/io/InMemoryStream.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/io/InSequence.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/io/InSharedMemoryStream.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/io/InStringSequence.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/io/IOutSequence.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/io/IOutStream.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/io/NativeFile.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/io/OutBitStream.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/io/OutFileStream.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/io/OutMemoryStream.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/io/OutSequence.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/io/OutStringSequence.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/io/Path.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/io/PathPattern.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/io/StdioFile.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/ipc/IExecutor.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/ipc/IRunnable.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/ipc/ITask.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/ipc/Library.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/ipc/Mutex.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/ipc/NativeExecutor.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/ipc/Process.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/ipc/SharedMem.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/ipc/SharedMutex.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/ipc/Thread.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/mm/ACMStream.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/mm/IInAudioStream.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/mm/InAudioFileStream.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/mm/IOutAudioStream.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/mm/MMIOReader.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/mm/MMIOWriter.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/mm/OutAudioFileStream.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/mm/sample.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/mm/types.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/protocol/midi.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/protocol/osc/debug.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/protocol/osc/forge.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/protocol/osc/parse.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/protocol/osc/pattern.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/resource/BuiltinLoader.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/resource/Compressor.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/resource/Decompressor.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/resource/DirLoader.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/resource/Environment.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/resource/ILoader.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/resource/OutProxyStream.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/resource/PrefixLoader.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/runtime/buffer.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/runtime/Color.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/runtime/LSPString.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/runtime/system.cpp"
build_lsp_runtime_lib "lsp-runtime-lib/src/main/runtime/uuid.cpp"

echo "LD lsp-runtime-lib.o"
$LD \
    -o build-lsp-runtime-lib/lsp-runtime-lib.o \
    -r build-lsp-runtime-lib/src/main/expr/EnvResolver.o \
    -r build-lsp-runtime-lib/src/main/expr/evaluator.o \
    -r build-lsp-runtime-lib/src/main/expr/Expression.o \
    -r build-lsp-runtime-lib/src/main/expr/format.o \
    -r build-lsp-runtime-lib/src/main/expr/functions.o \
    -r build-lsp-runtime-lib/src/main/expr/Parameters.o \
    -r build-lsp-runtime-lib/src/main/expr/parser.o \
    -r build-lsp-runtime-lib/src/main/expr/Resolver.o \
    -r build-lsp-runtime-lib/src/main/expr/Tokenizer.o \
    -r build-lsp-runtime-lib/src/main/expr/types.o \
    -r build-lsp-runtime-lib/src/main/expr/Variables.o \
    -r build-lsp-runtime-lib/src/main/fmt/bookmarks/gtk.o \
    -r build-lsp-runtime-lib/src/main/fmt/bookmarks/lnk.o \
    -r build-lsp-runtime-lib/src/main/fmt/bookmarks/lsp.o \
    -r build-lsp-runtime-lib/src/main/fmt/bookmarks/qt.o \
    -r build-lsp-runtime-lib/src/main/fmt/bookmarks.o \
    -r build-lsp-runtime-lib/src/main/fmt/config/IConfigHandler.o \
    -r build-lsp-runtime-lib/src/main/fmt/config/PullParser.o \
    -r build-lsp-runtime-lib/src/main/fmt/config/PushParser.o \
    -r build-lsp-runtime-lib/src/main/fmt/config/Serializer.o \
    -r build-lsp-runtime-lib/src/main/fmt/config/types.o \
    -r build-lsp-runtime-lib/src/main/fmt/Hydrogen.o \
    -r build-lsp-runtime-lib/src/main/fmt/java/const.o \
    -r build-lsp-runtime-lib/src/main/fmt/java/defs.o \
    -r build-lsp-runtime-lib/src/main/fmt/java/Enum.o \
    -r build-lsp-runtime-lib/src/main/fmt/java/Handles.o \
    -r build-lsp-runtime-lib/src/main/fmt/java/Object.o \
    -r build-lsp-runtime-lib/src/main/fmt/java/ObjectStreamClass.o \
    -r build-lsp-runtime-lib/src/main/fmt/java/ObjectStream.o \
    -r build-lsp-runtime-lib/src/main/fmt/java/ObjectStreamField.o \
    -r build-lsp-runtime-lib/src/main/fmt/java/RawArray.o \
    -r build-lsp-runtime-lib/src/main/fmt/java/String.o \
    -r build-lsp-runtime-lib/src/main/fmt/java/wrappers.o \
    -r build-lsp-runtime-lib/src/main/fmt/json/dom/Array.o \
    -r build-lsp-runtime-lib/src/main/fmt/json/dom/Boolean.o \
    -r build-lsp-runtime-lib/src/main/fmt/json/dom/Double.o \
    -r build-lsp-runtime-lib/src/main/fmt/json/dom/Integer.o \
    -r build-lsp-runtime-lib/src/main/fmt/json/dom/Node.o \
    -r build-lsp-runtime-lib/src/main/fmt/json/dom/Object.o \
    -r build-lsp-runtime-lib/src/main/fmt/json/dom/String.o \
    -r build-lsp-runtime-lib/src/main/fmt/json/dom.o \
    -r build-lsp-runtime-lib/src/main/fmt/json/Parser.o \
    -r build-lsp-runtime-lib/src/main/fmt/json/Serializer.o \
    -r build-lsp-runtime-lib/src/main/fmt/json/token.o \
    -r build-lsp-runtime-lib/src/main/fmt/json/Tokenizer.o \
    -r build-lsp-runtime-lib/src/main/fmt/lnk/types.o \
    -r build-lsp-runtime-lib/src/main/fmt/lspc/AudioReader.o \
    -r build-lsp-runtime-lib/src/main/fmt/lspc/AudioWriter.o \
    -r build-lsp-runtime-lib/src/main/fmt/lspc/ChunkAccessor.o \
    -r build-lsp-runtime-lib/src/main/fmt/lspc/ChunkReader.o \
    -r build-lsp-runtime-lib/src/main/fmt/lspc/ChunkReaderStream.o \
    -r build-lsp-runtime-lib/src/main/fmt/lspc/ChunkWriter.o \
    -r build-lsp-runtime-lib/src/main/fmt/lspc/ChunkWriterStream.o \
    -r build-lsp-runtime-lib/src/main/fmt/lspc/File.o \
    -r build-lsp-runtime-lib/src/main/fmt/lspc/IAudioFormatSelector.o \
    -r build-lsp-runtime-lib/src/main/fmt/lspc/InAudioStream.o \
    -r build-lsp-runtime-lib/src/main/fmt/lspc/util/audio.o \
    -r build-lsp-runtime-lib/src/main/fmt/lspc/util/config.o \
    -r build-lsp-runtime-lib/src/main/fmt/lspc/util/path.o \
    -r build-lsp-runtime-lib/src/main/fmt/obj/Compressor.o \
    -r build-lsp-runtime-lib/src/main/fmt/obj/Decompressor.o \
    -r build-lsp-runtime-lib/src/main/fmt/obj/IObjHandler.o \
    -r build-lsp-runtime-lib/src/main/fmt/obj/PullParser.o \
    -r build-lsp-runtime-lib/src/main/fmt/obj/PushParser.o \
    -r build-lsp-runtime-lib/src/main/fmt/RoomEQWizard.o \
    -r build-lsp-runtime-lib/src/main/fmt/sfz/DocumentProcessor.o \
    -r build-lsp-runtime-lib/src/main/fmt/sfz/IDocumentHandler.o \
    -r build-lsp-runtime-lib/src/main/fmt/sfz/parse.o \
    -r build-lsp-runtime-lib/src/main/fmt/sfz/PullParser.o \
    -r build-lsp-runtime-lib/src/main/fmt/url.o \
    -r build-lsp-runtime-lib/src/main/fmt/xml/const.o \
    -r build-lsp-runtime-lib/src/main/fmt/xml/IXMLHandler.o \
    -r build-lsp-runtime-lib/src/main/fmt/xml/PullParser.o \
    -r build-lsp-runtime-lib/src/main/fmt/xml/PushParser.o \
    -r build-lsp-runtime-lib/src/main/i18n/Dictionary.o \
    -r build-lsp-runtime-lib/src/main/i18n/IDictionary.o \
    -r build-lsp-runtime-lib/src/main/i18n/JsonDictionary.o \
    -r build-lsp-runtime-lib/src/main/io/charset.o \
    -r build-lsp-runtime-lib/src/main/io/CharsetDecoder.o \
    -r build-lsp-runtime-lib/src/main/io/CharsetEncoder.o \
    -r build-lsp-runtime-lib/src/main/io/Dir.o \
    -r build-lsp-runtime-lib/src/main/io/File.o \
    -r build-lsp-runtime-lib/src/main/io/IInSequence.o \
    -r build-lsp-runtime-lib/src/main/io/IInStream.o \
    -r build-lsp-runtime-lib/src/main/io/InBitStream.o \
    -r build-lsp-runtime-lib/src/main/io/InFileStream.o \
    -r build-lsp-runtime-lib/src/main/io/InMarkSequence.o \
    -r build-lsp-runtime-lib/src/main/io/InMemoryStream.o \
    -r build-lsp-runtime-lib/src/main/io/InSequence.o \
    -r build-lsp-runtime-lib/src/main/io/InSharedMemoryStream.o \
    -r build-lsp-runtime-lib/src/main/io/InStringSequence.o \
    -r build-lsp-runtime-lib/src/main/io/IOutSequence.o \
    -r build-lsp-runtime-lib/src/main/io/IOutStream.o \
    -r build-lsp-runtime-lib/src/main/io/NativeFile.o \
    -r build-lsp-runtime-lib/src/main/io/OutBitStream.o \
    -r build-lsp-runtime-lib/src/main/io/OutFileStream.o \
    -r build-lsp-runtime-lib/src/main/io/OutMemoryStream.o \
    -r build-lsp-runtime-lib/src/main/io/OutSequence.o \
    -r build-lsp-runtime-lib/src/main/io/OutStringSequence.o \
    -r build-lsp-runtime-lib/src/main/io/Path.o \
    -r build-lsp-runtime-lib/src/main/io/PathPattern.o \
    -r build-lsp-runtime-lib/src/main/io/StdioFile.o \
    -r build-lsp-runtime-lib/src/main/ipc/IExecutor.o \
    -r build-lsp-runtime-lib/src/main/ipc/IRunnable.o \
    -r build-lsp-runtime-lib/src/main/ipc/ITask.o \
    -r build-lsp-runtime-lib/src/main/ipc/Library.o \
    -r build-lsp-runtime-lib/src/main/ipc/Mutex.o \
    -r build-lsp-runtime-lib/src/main/ipc/NativeExecutor.o \
    -r build-lsp-runtime-lib/src/main/ipc/Process.o \
    -r build-lsp-runtime-lib/src/main/ipc/SharedMem.o \
    -r build-lsp-runtime-lib/src/main/ipc/SharedMutex.o \
    -r build-lsp-runtime-lib/src/main/ipc/Thread.o \
    -r build-lsp-runtime-lib/src/main/mm/ACMStream.o \
    -r build-lsp-runtime-lib/src/main/mm/IInAudioStream.o \
    -r build-lsp-runtime-lib/src/main/mm/InAudioFileStream.o \
    -r build-lsp-runtime-lib/src/main/mm/IOutAudioStream.o \
    -r build-lsp-runtime-lib/src/main/mm/MMIOReader.o \
    -r build-lsp-runtime-lib/src/main/mm/MMIOWriter.o \
    -r build-lsp-runtime-lib/src/main/mm/OutAudioFileStream.o \
    -r build-lsp-runtime-lib/src/main/mm/sample.o \
    -r build-lsp-runtime-lib/src/main/mm/types.o \
    -r build-lsp-runtime-lib/src/main/protocol/midi.o \
    -r build-lsp-runtime-lib/src/main/protocol/osc/debug.o \
    -r build-lsp-runtime-lib/src/main/protocol/osc/forge.o \
    -r build-lsp-runtime-lib/src/main/protocol/osc/parse.o \
    -r build-lsp-runtime-lib/src/main/protocol/osc/pattern.o \
    -r build-lsp-runtime-lib/src/main/resource/BuiltinLoader.o \
    -r build-lsp-runtime-lib/src/main/resource/Compressor.o \
    -r build-lsp-runtime-lib/src/main/resource/Decompressor.o \
    -r build-lsp-runtime-lib/src/main/resource/DirLoader.o \
    -r build-lsp-runtime-lib/src/main/resource/Environment.o \
    -r build-lsp-runtime-lib/src/main/resource/ILoader.o \
    -r build-lsp-runtime-lib/src/main/resource/OutProxyStream.o \
    -r build-lsp-runtime-lib/src/main/resource/PrefixLoader.o \
    -r build-lsp-runtime-lib/src/main/runtime/buffer.o \
    -r build-lsp-runtime-lib/src/main/runtime/Color.o \
    -r build-lsp-runtime-lib/src/main/runtime/LSPString.o \
    -r build-lsp-runtime-lib/src/main/runtime/system.o \
    -r build-lsp-runtime-lib/src/main/runtime/uuid.o

# lsp-plugin-fw-core
mkdir -p build-lsp-plugin-fw/src/main/core

build_lsp_plugin_fw "lsp-plugin-fw/src/main/core/AudioBuffer.cpp"
build_lsp_plugin_fw "lsp-plugin-fw/src/main/core/AudioReturn.cpp"
build_lsp_plugin_fw "lsp-plugin-fw/src/main/core/AudioSend.cpp"
build_lsp_plugin_fw "lsp-plugin-fw/src/main/core/Catalog.cpp"
build_lsp_plugin_fw "lsp-plugin-fw/src/main/core/CatalogManager.cpp"
build_lsp_plugin_fw "lsp-plugin-fw/src/main/core/config.cpp"
build_lsp_plugin_fw "lsp-plugin-fw/src/main/core/ICatalogClient.cpp"
build_lsp_plugin_fw "lsp-plugin-fw/src/main/core/ICatalogFactory.cpp"
build_lsp_plugin_fw "lsp-plugin-fw/src/main/core/IDBuffer.cpp"
build_lsp_plugin_fw "lsp-plugin-fw/src/main/core/JsonDumper.cpp"
build_lsp_plugin_fw "lsp-plugin-fw/src/main/core/KVTDispatcher.cpp"
build_lsp_plugin_fw "lsp-plugin-fw/src/main/core/KVTStorage.cpp"
build_lsp_plugin_fw "lsp-plugin-fw/src/main/core/osc_buffer.cpp"
build_lsp_plugin_fw "lsp-plugin-fw/src/main/core/presets.cpp"
build_lsp_plugin_fw "lsp-plugin-fw/src/main/core/Resources.cpp"
build_lsp_plugin_fw "lsp-plugin-fw/src/main/core/SamplePlayer.cpp"
build_lsp_plugin_fw "lsp-plugin-fw/src/main/core/ShmClient.cpp"
build_lsp_plugin_fw "lsp-plugin-fw/src/main/core/ShmStateBuilder.cpp"
build_lsp_plugin_fw "lsp-plugin-fw/src/main/core/ShmState.cpp"

echo "LD lsp-plugin-fw-core.o"
$LD \
    -o build-lsp-plugin-fw/lsp-plugin-fw-core.o \
    -r build-lsp-plugin-fw/src/main/core/AudioBuffer.o \
    -r build-lsp-plugin-fw/src/main/core/AudioReturn.o \
    -r build-lsp-plugin-fw/src/main/core/AudioSend.o \
    -r build-lsp-plugin-fw/src/main/core/Catalog.o \
    -r build-lsp-plugin-fw/src/main/core/CatalogManager.o \
    -r build-lsp-plugin-fw/src/main/core/config.o \
    -r build-lsp-plugin-fw/src/main/core/ICatalogClient.o \
    -r build-lsp-plugin-fw/src/main/core/ICatalogFactory.o \
    -r build-lsp-plugin-fw/src/main/core/IDBuffer.o \
    -r build-lsp-plugin-fw/src/main/core/JsonDumper.o \
    -r build-lsp-plugin-fw/src/main/core/KVTDispatcher.o \
    -r build-lsp-plugin-fw/src/main/core/KVTStorage.o \
    -r build-lsp-plugin-fw/src/main/core/osc_buffer.o \
    -r build-lsp-plugin-fw/src/main/core/presets.o \
    -r build-lsp-plugin-fw/src/main/core/Resources.o \
    -r build-lsp-plugin-fw/src/main/core/SamplePlayer.o \
    -r build-lsp-plugin-fw/src/main/core/ShmClient.o \
    -r build-lsp-plugin-fw/src/main/core/ShmStateBuilder.o \
    -r build-lsp-plugin-fw/src/main/core/ShmState.o

mkdir -p build-lsp-plugin-fw/src/wrap
build_lsp_plugin_fw "lsp-plugin-fw/src/wrap/lv2.cpp"

# lsp-plugins-fw-meta
mkdir -p build-lsp-plugin-fw/src/main/meta

build_lsp_plugin_fw "lsp-plugin-fw/src/main/meta/func.cpp"
build_lsp_plugin_fw "lsp-plugin-fw/src/main/meta/manifest.cpp"
build_lsp_plugin_fw "lsp-plugin-fw/src/main/meta/ports.cpp"
build_lsp_plugin_fw "lsp-plugin-fw/src/main/meta/registry.cpp"

echo "LD lsp-plugin-fw-meta.o"
$LD \
    -o build-lsp-plugin-fw/lsp-plugin-fw-meta.o \
    -r build-lsp-plugin-fw/src/main/meta/func.o \
    -r build-lsp-plugin-fw/src/main/meta/manifest.o \
    -r build-lsp-plugin-fw/src/main/meta/ports.o \
    -r build-lsp-plugin-fw/src/main/meta/registry.o

# lsp-plugin-fw-dsp
mkdir build-lsp-plugin-fw/src/main/plug
build_lsp_plugin_fw "lsp-plugin-fw/src/main/plug/data.cpp"
build_lsp_plugin_fw "lsp-plugin-fw/src/main/plug/Factory.cpp"
build_lsp_plugin_fw "lsp-plugin-fw/src/main/plug/ICanvas.cpp"
build_lsp_plugin_fw "lsp-plugin-fw/src/main/plug/ICanvasFactory.cpp"
build_lsp_plugin_fw "lsp-plugin-fw/src/main/plug/IPort.cpp"
build_lsp_plugin_fw "lsp-plugin-fw/src/main/plug/IWrapper.cpp"
build_lsp_plugin_fw "lsp-plugin-fw/src/main/plug/Module.cpp"

echo "LD lsp-plugin-fw-dsp.o"
$LD \
    -o build-lsp-plugin-fw/lsp-plugin-fw-dsp.o \
    -r build-lsp-plugin-fw/src/main/plug/data.o \
    -r build-lsp-plugin-fw/src/main/plug/Factory.o \
    -r build-lsp-plugin-fw/src/main/plug/ICanvas.o \
    -r build-lsp-plugin-fw/src/main/plug/ICanvasFactory.o \
    -r build-lsp-plugin-fw/src/main/plug/IPort.o \
    -r build-lsp-plugin-fw/src/main/plug/IWrapper.o \
    -r build-lsp-plugin-fw/src/main/plug/Module.o

# lsp-plugins-para-equalizer
mkdir -p build-lsp-plugins-para-equalizer/src/main/meta
mkdir -p build-lsp-plugins-para-equalizer/src/main/plug

build_lsp_plugins_para_equalizer "lsp-plugins-para-equalizer/src/main/meta/para_equalizer.cpp"

$LD \
    -o build-lsp-plugins-para-equalizer/lsp-plugins-para-equalizer-meta.o \
    -r build-lsp-plugins-para-equalizer/src/main/meta/para_equalizer.o

build_lsp_plugins_para_equalizer "lsp-plugins-para-equalizer/src/main/plug/para_equalizer.cpp"

$LD \
    -o build-lsp-plugins-para-equalizer/lsp-plugins-para-equalizer-dsp.o \
    -r build-lsp-plugins-para-equalizer/src/main/plug/para_equalizer.o

echo "Building Android Compat Layer"

$CXX \
    -o android-compat/shm_shim.o \
    -c android-compat/shm_shim.c \
    $CFLAGS -Wno-alloca

echo "Finalizing"
$CXX \
    -L $SYSROOT_LIB \
    -o lsp-plugins-lv2.so \
    build-lsp-common-lib/lsp-common-lib.o \
    build-lsp-dsp-lib/lsp-dsp-lib.o \
    build-lsp-dsp-units/lsp-dsp-units.o \
    build-lsp-lltl-lib/lsp-lltl-lib.o \
    build-lsp-runtime-lib/lsp-runtime-lib.o \
    build-lsp-plugins-shared/lsp-plugins-shared.o \
    build-lsp-plugin-fw/lsp-plugin-fw-core.o \
    build-lsp-plugin-fw/lsp-plugin-fw-meta.o \
    build-lsp-plugin-fw/lsp-plugin-fw-dsp.o \
    build-lsp-plugins-para-equalizer/lsp-plugins-para-equalizer-meta.o \
    build-lsp-plugins-para-equalizer/lsp-plugins-para-equalizer-dsp.o \
    build-lsp-plugin-fw/src/wrap/lv2.o \
    android-compat/shm_shim.o \
    -march=armv8-a -Wl,-z,relro,-z,now -Wl,--gc-sections -Wl,-as-needed -shared -fPIC -ldl -lsndfile

# Debugging
# -march=armv8-a -Wl,-soname,liblsp-plugins-lv2.so -Wl,-z,relro,-z,now -Wl,--gc-sections -Wl,-as-needed -shared -fPIC -ldl -lsndfile
