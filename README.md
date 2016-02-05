homebrew-openlase
=================

# Installation

Tested on Lion (10.8) and 10.11 (El Capitan).

  * Prepare homebrew

        $ curl -fsSk https://raw.github.com/mxcl/homebrew/go | ruby

  * Install recommended package(s) with brew

        $ brew install cmake
        $ brew install ffmpeg
        $ brew install qt
		$ brew install jack --build-from-source
		
  * Install openlase with brew

        $ brew tap edy555/openlase
        $ brew install openlase

   OpenLASE commands are installed in /usr/local/bin. 

# Run

  Before run openlase command, launch jack_server_control on terminal.
  And then, start one of following openlase commands. Finally connect ports.

  * openlase-simple
  * openlase-harp
  * openlase-scope
  * openlase-circlescope
  * openlase-playvid
  * openlase-qplayvid

# Example

        $ jack_server_control
        $ openlase-simulator 
        $ openlase-simple
		$ jack_connect libol:out_x simulator:in_x
		$ jack_connect libol:out_y simulator:in_y
        $ jack_connect libol:out_g simulator:in_g
	    $ jack_connect libol:out_r simulator:in_r
        $ jack_connect libol:out_b simulator:in_b

# Credit

  * OpenLASE is developed by Hector Martin.
    http://marcansoft.com/blog/2010/11/openlase-open-realtime-laser-graphics/
    https://github.com/marcan/openlase
  * Homebrew formula by edy555 (TT)

[EOF]
