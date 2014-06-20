require 'formula'

# Documentation: https://github.com/mxcl/homebrew/wiki/Formula-Cookbook
# PLEASE REMOVE ALL GENERATED COMMENTS BEFORE SUBMITTING YOUR PULL REQUEST!

class Openlase < Formula
  homepage 'https://github.com/marcan/openlase/wiki'

  head 'https://github.com/marcan/openlase/commit/49cd5b753066d23f47730853bfcc2b12f7adab82'

  depends_on 'cmake' => :build
  depends_on 'yasm' => :build
  #depends_on 'jack'  # Jack OSX http://www.jackosx.com/ is recommended
  depends_on 'ffmpeg' => :recommended
  depends_on 'qt' => :optional

  def patches
    DATA
  end

  def install
    args = std_cmake_args
    args << '-DPYTHON_LIBRARY=/usr/local/Frameworks/Python.framework/Python'
    system "cmake", ".", *args
    system "make"
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
index b9be0f4..b677f57 100644
--- a/examples/CMakeLists.txt
+++ b/examples/CMakeLists.txt
@@ -18,28 +18,37 @@
 
 include_directories (${CMAKE_SOURCE_DIR}/include)
 link_directories (${CMAKE_BINARY_DIR}/libol)
+include_directories (${JACK_INCLUDE_DIR})
 
-add_executable(circlescope circlescope.c)
-target_link_libraries(circlescope ${JACK_LIBRARIES} m)
+add_executable(openlase-circlescope circlescope.c)
+target_link_libraries(openlase-circlescope ${JACK_LIBRARIES} m)
+install (TARGETS openlase-circlescope RUNTIME DESTINATION bin)
 
-add_executable(scope scope.c)
-target_link_libraries(scope ${JACK_LIBRARIES} m)
+add_executable(openlase-scope scope.c)
+target_link_libraries(openlase-scope ${JACK_LIBRARIES} m)
+install(TARGETS openlase-scope RUNTIME DESTINATION bin)
 
-add_executable(simple simple.c)
-target_link_libraries(simple openlase)
+add_executable(openlase-simple simple.c)
+target_link_libraries(openlase-simple openlase)
+install (TARGETS openlase-simple RUNTIME DESTINATION bin)
 
-add_executable(pong pong.c)
-target_link_libraries(pong openlase)
+if(NOT APPLE)
+add_executable(openlase-pong pong.c)
+target_link_libraries(openlase-pong openlase)
+install (TARGETS openlase-pong RUNTIME DESTINATION bin)
+endif()
 
 if(ALSA_FOUND)
-  add_executable(midiview midiview.c)
-  target_link_libraries(midiview openlase ${ALSA_LIBRARIES})
+  add_executable(openlase-midiview midiview.c)
+  target_link_libraries(openlase-midiview openlase ${ALSA_LIBRARIES})
+  install (TARGETS openlase-midiview RUNTIME DESTINATION bin)
 else()
   message(STATUS "Will NOT build midiview (ALSA missing)")
 endif()
 
-add_executable(harp harp.c)
-target_link_libraries(harp openlase)
+add_executable(openlase-harp harp.c)
+target_link_libraries(openlase-harp openlase)
+install (TARGETS openlase-harp RUNTIME DESTINATION bin)
 
 #add_subdirectory(27c3_slides)
 
diff --git a/libol/CMakeLists.txt b/libol/CMakeLists.txt
index da9ffd0..668f859 100644
--- a/libol/CMakeLists.txt
+++ b/libol/CMakeLists.txt
@@ -15,6 +15,7 @@
 # along with this program; if not, write to the Free Software
 # Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 #
+include(CheckFunctionExists)
 
 check_include_files(malloc.h HAVE_MALLOC_H)
 check_function_exists(memalign HAVE_MEMALIGN)
@@ -23,6 +24,7 @@ check_function_exists(_aligned_malloc HAVE_ALIGNED_MALLOC)
 configure_file(${CMAKE_CURRENT_SOURCE_DIR}/config.h.in ${CMAKE_CURRENT_BINARY_DIR}/config.h)
 
 include_directories (${CMAKE_SOURCE_DIR}/include ${CMAKE_CURRENT_BINARY_DIR})
+include_directories (${JACK_INCLUDE_DIR})
 
 set(TRACER_SOURCES "")
 if(BUILD_TRACER)
@@ -36,6 +38,8 @@ endif()
 add_library (openlase SHARED libol.c text.c ilda.c ${TRACER_SOURCES} ${CMAKE_CURRENT_BINARY_DIR}/fontdef.c)
 target_link_libraries (openlase ${CMAKE_THREAD_LIBS_INIT} m jack)
 set_target_properties(openlase PROPERTIES VERSION 0 SOVERSION 0)
+install (TARGETS openlase RUNTIME DESTINATION bin LIBRARY DESTINATION
+lib ARCHIVE DESTINATION lib)
 
 add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/fontdef.c
     DEPENDS ${CMAKE_SOURCE_DIR}/tools/genfont.py
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
index 5bd8815..cd8d929 100644
--- a/python/CMakeLists.txt
+++ b/python/CMakeLists.txt
@@ -1,4 +1,4 @@
-find_package(PythonLibs)
+find_package(PythonLibs) 
 find_program(CYTHON_EXECUTABLE cython)
 
 if(CYTHON_EXECUTABLE MATCHES "NOTFOUND" OR NOT PYTHONLIBS_FOUND)
@@ -21,5 +21,8 @@ else()
     PREFIX ""
     OUTPUT_NAME "pylase"
     LIBRARY_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR})
-  target_link_libraries(pylase openlase)
+  target_link_libraries(pylase ${PYTHON_LIBRARIES} openlase)
+
+  execute_process ( COMMAND ${PYTHON_EXECUTABLE} -c "from distutils.sysconfig import get_python_lib; print get_python_lib(plat_specific=1)" OUTPUT_VARIABLE PYTHON_SITE_PACKAGES OUTPUT_STRIP_TRAILING_WHITESPACE)
+  install(TARGETS pylase DESTINATION ${PYTHON_SITE_PACKAGES} ) 
 endif()
diff --git a/tools/CMakeLists.txt b/tools/CMakeLists.txt
index 51f20c6..1c16ea0 100644
--- a/tools/CMakeLists.txt
+++ b/tools/CMakeLists.txt
@@ -18,28 +18,34 @@
 
 include_directories (${CMAKE_SOURCE_DIR}/include)
 link_directories (${CMAKE_BINARY_DIR}/libol)
+include_directories (${JACK_INCLUDE_DIR})
 
-add_executable(playilda playilda.c)
-target_link_libraries(playilda ${JACK_LIBRARIES})
+add_executable(openlase-playilda playilda.c)
+target_link_libraries(openlase-playilda ${JACK_LIBRARIES})
+install (TARGETS openlase-playilda RUNTIME DESTINATION bin)
 
-add_executable(invert invert.c)
-target_link_libraries(invert ${JACK_LIBRARIES})
+add_executable(openlase-invert invert.c)
+target_link_libraries(openlase-invert ${JACK_LIBRARIES})
+install (TARGETS openlase-invert RUNTIME DESTINATION bin)
 
-add_executable(cal cal.c)
-target_link_libraries(cal ${JACK_LIBRARIES} m)
+add_executable(openlase-cal cal.c)
+target_link_libraries(openlase-cal ${JACK_LIBRARIES} m)
+install (TARGETS openlase-cal RUNTIME DESTINATION bin)
 
 if(FFMPEG_FOUND AND BUILD_TRACER)
   include_directories(${FFMPEG_INCLUDE_DIR})
-  add_executable(playvid playvid.c)
-  target_link_libraries(playvid openlase ${FFMPEG_LIBRARIES} avresample)
+  add_executable(openlase-playvid playvid.c)
+  target_link_libraries(openlase-playvid openlase ${FFMPEG_LIBRARIES} avresample)
+  install (TARGETS openlase-playvid RUNTIME DESTINATION bin)
 else()
   message(STATUS "Will NOT build playvid (FFmpeg or tracer missing)")
 endif()
 
 if(OPENGL_FOUND AND GLUT_FOUND)
-  add_executable(simulator simulator.c)
+  add_executable(openlase-simulator simulator.c)
   include_directories(${OPENGL_INCLUDE_DIRS} ${GLUT_INCLUDE_DIRS})
-  target_link_libraries(simulator m ${OPENGL_LIBRARIES} ${GLUT_LIBRARY} ${JACK_LIBRARIES})
+  target_link_libraries(openlase-simulator m ${OPENGL_LIBRARIES} ${GLUT_LIBRARY} ${JACK_LIBRARIES})
+  install(TARGETS openlase-simulator RUNTIME DESTINATION bin)
 else()
   message(STATUS "Will NOT build simulator (OpenGL or GLUT missing)")
 endif()
diff --git a/tools/playilda.c b/tools/playilda.c
index b8d1746..288d856 100644
--- a/tools/playilda.c
+++ b/tools/playilda.c
@@ -44,6 +44,10 @@ the laser image updates.
 #include <sys/param.h>
 #include <sys/stat.h>
 
+#if defined(__APPLE__)
+#define st_mtim        st_mtimespec
+#endif
+
 #if BYTE_ORDER == LITTLE_ENDIAN
 static inline uint16_t swapshort(uint16_t v) {
 	return (v >> 8) | (v << 8);
diff --git a/tools/qplayvid/CMakeLists.txt b/tools/qplayvid/CMakeLists.txt
index b68e5de..dabb2db 100644
--- a/tools/qplayvid/CMakeLists.txt
+++ b/tools/qplayvid/CMakeLists.txt
@@ -23,8 +23,9 @@ if(QT4_FOUND AND FFMPEG_FOUND AND SWSCALE_FOUND AND BUILD_TRACER)
 
   include_directories(${CMAKE_CURRENT_BINARY_DIR})
 
-  add_executable(qplayvid qplayvid.c qplayvid_gui.cpp ${qplayvid_MOCS})
-  target_link_libraries(qplayvid openlase ${FFMPEG_LIBRARIES} ${SWSCALE_LIBRARIES} ${QT_LIBRARIES} avresample)
+  add_executable(openlase-qplayvid qplayvid.c qplayvid_gui.cpp ${qplayvid_MOCS})
+  target_link_libraries(openlase-qplayvid openlase ${FFMPEG_LIBRARIES} ${SWSCALE_LIBRARIES} ${QT_LIBRARIES} avresample)
+  install(TARGETS openlase-qplayvid RUNTIME DESTINATION bin)
 else()
   message(STATUS "Will NOT build qplayvid (Qt4 or FFmpeg or tracer missing)")
 endif()
diff --git a/tools/simulator.c b/tools/simulator.c
index 66ae6e3..1b80da1 100644
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
 
