@echo off
"C:\\Android\\Sdk\\cmake\\3.22.1\\bin\\cmake.exe" ^
  "-HC:\\Users\\Gerry Hampac\\AppData\\Local\\Pub\\Cache\\hosted\\pub.dev\\jni-1.0.0\\src" ^
  "-DCMAKE_SYSTEM_NAME=Android" ^
  "-DCMAKE_EXPORT_COMPILE_COMMANDS=ON" ^
  "-DCMAKE_SYSTEM_VERSION=21" ^
  "-DANDROID_PLATFORM=android-21" ^
  "-DANDROID_ABI=x86" ^
  "-DCMAKE_ANDROID_ARCH_ABI=x86" ^
  "-DANDROID_NDK=C:\\Android\\Sdk\\ndk\\28.2.13676358" ^
  "-DCMAKE_ANDROID_NDK=C:\\Android\\Sdk\\ndk\\28.2.13676358" ^
  "-DCMAKE_TOOLCHAIN_FILE=C:\\Android\\Sdk\\ndk\\28.2.13676358\\build\\cmake\\android.toolchain.cmake" ^
  "-DCMAKE_MAKE_PROGRAM=C:\\Android\\Sdk\\cmake\\3.22.1\\bin\\ninja.exe" ^
  "-DCMAKE_LIBRARY_OUTPUT_DIRECTORY=C:\\Users\\Gerry Hampac\\Desktop\\clonelibrary\\Librarytrackerapp\\build\\jni\\intermediates\\cxx\\Debug\\2d3s3f11\\obj\\x86" ^
  "-DCMAKE_RUNTIME_OUTPUT_DIRECTORY=C:\\Users\\Gerry Hampac\\Desktop\\clonelibrary\\Librarytrackerapp\\build\\jni\\intermediates\\cxx\\Debug\\2d3s3f11\\obj\\x86" ^
  "-DCMAKE_BUILD_TYPE=Debug" ^
  "-BC:\\Users\\Gerry Hampac\\AppData\\Local\\Pub\\Cache\\hosted\\pub.dev\\jni-1.0.0\\android\\.cxx\\Debug\\2d3s3f11\\x86" ^
  -GNinja
