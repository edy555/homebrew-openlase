require 'formula'

class Openlase < Formula
  homepage 'https://github.com/marcan/openlase/wiki'
  url 'https://github.com/marcan/openlase.git'
  version 'marcan-221a551'
  head 'https://github.com/marcan/openlase.git'

  depends_on 'cmake' => :build
  depends_on 'jack'
  depends_on 'yasm' => :optional
  depends_on 'ffmpeg' => :optional
  depends_on 'qt' => :optional
  depends_on 'cython' => :optional
  depends_on 'python' => :optional

  patch :DATA

  def install
    args = std_cmake_args
    system "cmake", ".", *args
    system "make"
    system "make install"
  end
end

__END__
diff --git a/Modules/CMakeASM_YASMInformation.cmake b/Modules/CMakeASM_YASMInformation.cmake
index 923a915..6729e77 100644
--- a/Modules/CMakeASM_YASMInformation.cmake
+++ b/Modules/CMakeASM_YASMInformation.cmake
@@ -1,7 +1,13 @@
 set(ASM_DIALECT "_YASM")
 set(CMAKE_ASM${ASM_DIALECT}_SOURCE_FILE_EXTENSIONS asm)
 
-if(UNIX)
+if(APPLE)
+  if(BITS EQUAL 64)
+    set(CMAKE_ASM_YASM_COMPILER_ARG1 "-f macho64 -DARCH_X86_64=1 -Dprivate_prefix=_ol -DPIC=1")
+  else()
+    set(CMAKE_ASM_YASM_COMPILER_ARG1 "-f macho32 -DARCH_X86_64=0 -Dprivate_prefix=_ol")
+  endif()
+elseif(UNIX)
   if(BITS EQUAL 64)
     set(CMAKE_ASM_YASM_COMPILER_ARG1 "-f elf64 -DARCH_X86_64=1 -Dprivate_prefix=ol -DPIC=1")
   else()
diff --git a/examples/CMakeLists.txt b/examples/CMakeLists.txt
index 5e495ce..69d88f0 100644
--- a/examples/CMakeLists.txt
+++ b/examples/CMakeLists.txt
@@ -19,27 +19,35 @@
 include_directories (${CMAKE_SOURCE_DIR}/include)
 link_directories (${CMAKE_BINARY_DIR}/libol)
 
-add_executable(circlescope circlescope.c)
-target_link_libraries(circlescope ${JACK_LIBRARIES} m)
-
-add_executable(scope scope.c)
-target_link_libraries(scope ${JACK_LIBRARIES} m)
-
-add_executable(simple simple.c)
-target_link_libraries(simple ol)
-
-add_executable(pong pong.c)
-target_link_libraries(pong ol)
+add_executable(openlase-circlescope circlescope.c)
+target_link_libraries(openlase-circlescope ${JACK_LIBRARIES} m)
+install (TARGETS openlase-circlescope RUNTIME DESTINATION bin)
+
+add_executable(openlase-scope scope.c)
+target_link_libraries(openlase-scope ${JACK_LIBRARIES} m)
+install(TARGETS openlase-scope RUNTIME DESTINATION bin)
+
+add_executable(openlase-simple simple.c)
+target_link_libraries(openlase-simple ol)
+install (TARGETS openlase-simple RUNTIME DESTINATION bin)
+
+if(NOT APPLE)
+add_executable(openlase-pong pong.c)
+target_link_libraries(openlase-pong ol)
+install (TARGETS openlase-pong RUNTIME DESTINATION bin)
+endif()
 
 if(ALSA_FOUND)
-  add_executable(midiview midiview.c)
-  target_link_libraries(midiview ol ${ALSA_LIBRARIES})
+  add_executable(openlase-midiview midiview.c)
+  target_link_libraries(openlase-midiview ol ${ALSA_LIBRARIES})
+  install (TARGETS openlase-midiview RUNTIME DESTINATION bin)
 else()
   message(STATUS "Will NOT build midiview (ALSA missing)")
 endif()
 
-add_executable(harp harp.c)
-target_link_libraries(harp ol)
+add_executable(openlase-harp harp.c)
+target_link_libraries(openlase-harp ol)
+install (TARGETS openlase-harp RUNTIME DESTINATION bin)
 
 #add_subdirectory(27c3_slides)
 
diff --git a/libol/imgproc_sse2.asm b/libol/imgproc_sse2.asm
index 4c86a3c..1df4979 100644
--- a/libol/imgproc_sse2.asm
+++ b/libol/imgproc_sse2.asm
@@ -50,6 +50,12 @@ section .note.GNU-stack noalloc noexec nowrite progbits
 %ifidn __OUTPUT_FORMAT__,elf64
 section .note.GNU-stack noalloc noexec nowrite progbits
 %endif
+%ifidn __OUTPUT_FORMAT__,macho64
+section .note.GNU-stack noalloc
+%endif
+%ifidn __OUTPUT_FORMAT__,macho32
+section .note.GNU-stack noalloc
+%endif
 
 SECTION .text
 INIT_XMM
diff --git a/libol/trace.c b/libol/trace.c
index 364abdc..0a4aab8 100644
--- a/libol/trace.c
+++ b/libol/trace.c
@@ -22,7 +22,7 @@ Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 #include <string.h>
 #include <stdio.h>
 #include <stdlib.h>
-#include <malloc.h>
+#include <malloc/malloc.h>
 
 #include "trace.h"
 #include "align.h"
diff --git a/python/CMakeLists.txt b/python/CMakeLists.txt
index 8003451..12513ff 100644
--- a/python/CMakeLists.txt
+++ b/python/CMakeLists.txt
@@ -22,5 +22,9 @@ else()
     PREFIX ""
     OUTPUT_NAME "pylase"
     LIBRARY_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR})
-  target_link_libraries(pylase ol)
+  target_link_libraries(pylase ${PYTHON_LIBRARIES} ol)
+
+  execute_process ( COMMAND ${PYTHON_EXECUTABLE} -c "from distutils.sysconfig import get_python_lib; print get_python_lib(plat_specific=1)" OUTPUT_VARIABLE PYTHON_SITE_PACKAGES OUTPUT_STRIP_TRAILING_WHITESPACE)
+  #install(TARGETS pylase DESTINATION ${PYTHON_SITE_PACKAGES} ) 
+
 endif()
diff --git a/tools/CMakeLists.txt b/tools/CMakeLists.txt
index 7f83ede..4c85a1d 100644
--- a/tools/CMakeLists.txt
+++ b/tools/CMakeLists.txt
@@ -19,27 +19,32 @@
 include_directories (${CMAKE_SOURCE_DIR}/include)
 link_directories (${CMAKE_BINARY_DIR}/libol)
 
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
 
-#if(FFMPEG_FOUND AND BUILD_TRACER)
-# include_directories(${FFMPEG_INCLUDE_DIR})
-# add_executable(playvid playvid.c)
-# target_link_libraries(playvid openlase ${FFMPEG_LIBRARIES} avresample)
-#else()
-#  message(STATUS "Will NOT build playvid (FFmpeg or tracer missing)")
-#endif()
+if(FFMPEG_FOUND AND BUILD_TRACER)
+ include_directories(${FFMPEG_INCLUDE_DIR})
+ add_executable(openlase-playvid playvid.c)
+ target_link_libraries(openlase-playvid ol ${FFMPEG_LIBRARIES} avresample)
+ install (TARGETS openlase-playvid RUNTIME DESTINATION bin)
+else()
+  message(STATUS "Will NOT build playvid (FFmpeg or tracer missing)")
+endif()
 
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
index c942701..6458687 100644
--- a/tools/playilda.c
+++ b/tools/playilda.c
@@ -522,7 +522,7 @@ int main (int argc, char *argv[])
 
 	while (1) {
 		stat(fname, &st2);
-		if(st1.st_mtim.tv_sec != st2.st_mtim.tv_sec || st1.st_mtim.tv_nsec != st2.st_mtim.tv_nsec) {
+		if(st1.st_mtimespec.tv_sec != st2.st_mtimespec.tv_sec || st1.st_mtimespec.tv_nsec != st2.st_mtimespec.tv_nsec) {
 			frameno = (frameno+1)%FRAMEBUFS;
 			printf("Loading new frame to slot %d\n", frameno);
 			if(frames[frameno].points)
diff --git a/tools/playvid.c b/tools/playvid.c
index 1b20ba9..a4f4fcb 100644
--- a/tools/playvid.c
+++ b/tools/playvid.c
@@ -61,7 +61,7 @@ is a hack.
 
 #define FRAMES_BUF 8
 
-#define AUDIO_BUF AVCODEC_MAX_AUDIO_FRAME_SIZE
+#define AUDIO_BUF 192000
 
 AVFormatContext        *pFormatCtx = NULL;
 AVFormatContext        *pAFormatCtx = NULL;
@@ -130,7 +130,7 @@ void moreaudio(float *lb, float *rb, int samples)
 			} while(packet.stream_index!=audioStream);
 
 			pAudioFrame->nb_samples = AUDIO_BUF;
-			pACodecCtx->get_buffer(pACodecCtx, pAudioFrame);
+			pACodecCtx->get_buffer2(pACodecCtx, pAudioFrame, 0);
 			avcodec_decode_audio4(pACodecCtx, pAudioFrame, &decoded_frame, &packet);
 			if(!decoded_frame)
 			{
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
 
