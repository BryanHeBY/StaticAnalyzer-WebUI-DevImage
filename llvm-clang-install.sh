#!/bin/bash

source_path_root=/opt/llvm-source-build/llvm-src-archive

cd /opt/llvm-source-build
cp ${source_path_root}/llvm-9.0.1.src.tar.xz .
tar -xf llvm-9.0.1.src.tar.xz
mv llvm-9.0.1.src llvm

cd llvm/tools
cp ${source_path_root}/clang-9.0.1.src.tar.xz .
tar -xf clang-9.0.1.src.tar.xz
mv clang-9.0.1.src clang

cd clang/tools
cp ${source_path_root}/clang-tools-extra-9.0.1.src.tar.xz .
tar -xf clang-tools-extra-9.0.1.src.tar.xz
mv clang-tools-extra-9.0.1.src extra

cd ../../../projects  #now under the folder /llvm-source-build/llvm/projects
cp ${source_path_root}/compiler-rt-9.0.1.src.tar.xz .
tar -xf compiler-rt-9.0.1.src.tar.xz
mv compiler-rt-9.0.1.src compiler-rt
# git patch
rm compiler-rt/lib/sanitizer_common/sanitizer_platform_limits_posix.h
rm compiler-rt/lib/sanitizer_common/sanitizer_platform_limits_posix.cc
cp ${source_path_root}/sanitizer_platform_limits_posix.h compiler-rt/lib/sanitizer_common/sanitizer_platform_limits_posix.h
cp ${source_path_root}/sanitizer_platform_limits_posix.cc compiler-rt/lib/sanitizer_common/sanitizer_platform_limits_posix.cc


cp ${source_path_root}/libcxx-9.0.1.src.tar.xz .
tar -xf libcxx-9.0.1.src.tar.xz
mv libcxx-9.0.1.src libcxx

cp ${source_path_root}/libcxxabi-9.0.1.src.tar.xz .
tar -xf libcxxabi-9.0.1.src.tar.xz
mv libcxxabi-9.0.1.src libcxxabi

