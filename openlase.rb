require 'formula'

# Documentation: https://github.com/mxcl/homebrew/wiki/Formula-Cookbook
# PLEASE REMOVE ALL GENERATED COMMENTS BEFORE SUBMITTING YOUR PULL REQUEST!

class Openlase < Formula
  homepage 'https://github.com/marcan/openlase/wiki'
  url ''
  sha1 ''

  head 'https://github.com/marcan/openlase.git'

  depends_on 'cmake' => :build
  depends_on 'yasm' => :build
  #depends_on 'jack'  # Jack OSX http://www.jackosx.com/ is recommended
  depends_on 'ffmpeg' => :recommended
  depends_on 'qt' => :optional

  def patches
    DATA
  end

  def install
    system "cmake", ".", *std_cmake_args
    system "make install"
  end
end

__END__
diff --git a/Modules/CMakeASM_YASMInformation.cmake b/Modules/CMakeASM_YASMInformation.cmake
index 50b2848..3d7b330 100644
--- a/Modules/CMakeASM_YASMInformation.cmake
+++ b/Modules/CMakeASM_YASMInformation.cmake
@@ -1,7 +1,13 @@
 set(ASM_DIALECT "_YASM")
 set(CMAKE_ASM${ASM_DIALECT}_SOURCE_FILE_EXTENSIONS asm)
 
-if(UNIX)
+if(APPLE)
+  if(BITS EQUAL 64)
+    set(CMAKE_ASM_YASM_COMPILER_ARG1 "-f macho64 -DARCH_X86_64 -DPREFIX")
+  else()
+    set(CMAKE_ASM_YASM_COMPILER_ARG1 "-f macho32 -DPREFIX")
+  endif()
+elseif(UNIX)
   if(BITS EQUAL 64)
     set(CMAKE_ASM_YASM_COMPILER_ARG1 "-f elf64 -DARCH_X86_64")
   else()
diff --git a/examples/CMakeLists.txt b/examples/CMakeLists.txt
index b9be0f4..ec1884d 100644
--- a/examples/CMakeLists.txt
+++ b/examples/CMakeLists.txt
@@ -28,8 +28,10 @@ target_link_libraries(scope ${JACK_LIBRARIES} m)
 add_executable(simple simple.c)
 target_link_libraries(simple openlase)
 
+if(NOT APPLE)
 add_executable(pong pong.c)
 target_link_libraries(pong openlase)
+endif()
 
 if(ALSA_FOUND)
   add_executable(midiview midiview.c)
diff --git a/libol/CMakeLists.txt b/libol/CMakeLists.txt
index 36caa08..b742a5b 100644
--- a/libol/CMakeLists.txt
+++ b/libol/CMakeLists.txt
@@ -15,6 +15,7 @@
 # along with this program; if not, write to the Free Software
 # Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 #
+include(CheckFunctionExists)
 
 check_include_files(malloc.h HAVE_MALLOC_H)
 check_function_exists(memalign HAVE_MEMALIGN)
diff --git a/libol/trace.c b/libol/trace.c
index 8439830..829d8d6 100644
--- a/libol/trace.c
+++ b/libol/trace.c
@@ -22,7 +22,9 @@ Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 #include <string.h>
 #include <stdio.h>
 #include <stdlib.h>
+#ifdef HAVE_MALLOC_H
 #include <malloc.h>
+#endif
 
 #include "trace.h"
 #include "align.h"
diff --git a/python/CMakeLists.txt b/python/CMakeLists.txt
index 5bd8815..c0a4db4 100644
--- a/python/CMakeLists.txt
+++ b/python/CMakeLists.txt
@@ -21,5 +21,5 @@ else()
     PREFIX ""
     OUTPUT_NAME "pylase"
     LIBRARY_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR})
-  target_link_libraries(pylase openlase)
+  target_link_libraries(pylase ${PYTHON_LIBRARIES} openlase)
 endif()
diff --git a/tools/playilda.c b/tools/playilda.c
index b8d1746..e997bfc 100644
--- a/tools/playilda.c
+++ b/tools/playilda.c
@@ -44,6 +44,10 @@ the laser image updates.
 #include <sys/param.h>
 #include <sys/stat.h>
 
+#if defined(__APPLE__)
+#define st_mtim	st_mtimespec
+#endif
+
 #if BYTE_ORDER == LITTLE_ENDIAN
 static inline uint16_t swapshort(uint16_t v) {
 	return (v >> 8) | (v << 8);
diff --git a/tools/simulator.c b/tools/simulator.c
index 6b24466..b001020 100644
--- a/tools/simulator.c
+++ b/tools/simulator.c
@@ -25,9 +25,15 @@ Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 #include <math.h>
 #include <jack/jack.h>
 
+#ifdef __APPLE__
+#include <GLUT/glut.h>
+#include <OpenGL/gl.h>
+#include <OpenGL/glu.h>
+#else
 #include <GL/glut.h>
 #include <GL/gl.h>
 #include <GL/glu.h>
+#endif
 
 int window;
 
