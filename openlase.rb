require 'formula'

# Documentation: https://github.com/mxcl/homebrew/wiki/Formula-Cookbook
# PLEASE REMOVE ALL GENERATED COMMENTS BEFORE SUBMITTING YOUR PULL REQUEST!

class Openlase < Formula
  homepage 'https://github.com/edy555/openlase'
  url ''
  sha1 ''

  head 'https://github.com/edy555/openlase.git'

  depends_on 'cmake' => :build
  depends_on 'yasm' => :build
  #depends_on 'jack'  # Jack OSX http://www.jackosx.com/ is recommended
  depends_on 'ffmpeg' => :recommended
  depends_on 'qt' => :optional

  def install
    system "cmake", ".", *std_cmake_args
    system "make install"
  end
end
