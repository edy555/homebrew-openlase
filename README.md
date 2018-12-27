homebrew-openlase
=================

# Installation

Tested on Sierra (10.13)

  * Prepare homebrew

        $ curl -fsSk https://raw.github.com/mxcl/homebrew/go | ruby

  * Install recommended package(s) with brew

        $ brew install cmake
        $ brew install ffmpeg
        $ brew install qt
		$ brew install jack --build-from-source
        $ brew install qjackctl
		
  * Install openlase with brew

        $ brew tap edy555/openlase
        $ brew install openlase

   OpenLASE commands are installed in /usr/local/bin

# Run

  Before run openlase command, launch qjackctl on terminal.
  Start one of following openlase commands. And then, connect ports
  with qjackctl.

  * openlase-simple
  * openlase-harp
  * openlase-scope
  * openlase-circlescope
  * openlase-playvid
  * openlase-qplayvid

# Example

        $ openlase-simulator 
        $ openlase-simple
        $ qjackctl

# Credit

  * OpenLASE is developed by Hector Martin.
    http://marcansoft.com/blog/2010/11/openlase-open-realtime-laser-graphics/
    https://github.com/marcan/openlase
  * Homebrew formula by edy555 (TT)

[EOF]
