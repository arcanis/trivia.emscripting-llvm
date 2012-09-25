#!/usr/bin/env bash

LLVM_PATH=$(realpath ~/llvm)
EMSCRIPTEN_PATH=$(realpath ~/emscripten)

EMSCRIPTEN_ENVIRONMENT="-DCMAKE_C_COMPILER='$EMSCRIPTEN_PATH/emcc' -DCMAKE_CXX_COMPILER='$EMSCRIPTEN_PATH/em++' -DCMAKE_AR='$EMSCRIPTEN_PATH/emar' -DCMAKE_RANLIB='$EMSCRIPTEN_PATH/emranlib'"
CMAKE_FLAGS="-DLLVM_ENABLE_THREADS=OFF -DLLVM_INCLUDE_TOOLS=OFF -DLLVM_INCLUDE_EXAMPLES=OFF -DLLVM_TARGETS_TO_BUILD=X86 -DLLVM_TARGETS_WITH_JIT=OFF -DHAVE_SYS_IOCTL_H=OFF -DHAVE_TERMIOS_H=OFF -DHAVE_POSIX_SPAWN=OFF -DHAVE_GETRLIMIT=OFF -DHAVE_EXECINFO_H=OFF -DHAVE_BACKTRACE=OFF -DHAVE_VALGRIND_VALGRIND_H=OFF -DHAVE_FENV_H=OFF"

HERE=$(realpath .)

if [[ ! -e "$HERE/llvm-native-build" ]]; then
    mkdir -p "$HERE/llvm-native-build"; cd "$HERE/llvm-native-build"
    cmake "$LLVM_PATH" $CMAKE_FLAGS
    make llvm-tblgen
fi

if [[ ! -e "$HERE/llvm-emscripted-build" ]]; then
    mkdir -p "$HERE/llvm-emscripted-build"; cd "$HERE/llvm-emscripted-build"
    cmake "$LLVM_PATH" $EMSCRIPTEN_ENVIRONMENT $CMAKE_FLAGS
    make
    cp "$HERE/llvm-native-build/bin/llvm-tblgen" "bin/"
    chmod +x "bin/llvm-tblgen"
    make
fi

LLVM_INCPATH1="$LLVM_PATH/include"
LLVM_INCPATH2="$HERE/llvm-emscripted-build/include"
LLVM_LDPATH="$HERE/llvm-emscripted-build/lib"

LLVM_CPPFLAGS="-I$LLVM_INCPATH1 -I$LLVM_INCPATH2 -DNDEBUG -D_GNU_SOURCE -D__STDC_CONSTANT_MACROS -D__STDC_FORMAT_MACROS -D__STDC_LIMIT_MACROS"
LLVM_LDFLAGS="-L$LLVM_LDPATH -lm"
LLVM_LIBS=$(llvm-config --libs core interpreter)

"$EMSCRIPTEN_PATH/em++" --remove-duplicates -std=c++11 -o "$HERE/test.js" $LLVM_CPPFLAGS "$HERE/test.cc" $LLVM_LDFLAGS $LLVM_LIBS
