homebrew-openlase
=================

# Installation

Tested on Mountain Lion 10.8 with Xcode 4.6.

  * Install Jack OSX

    Download Jack OSX from http://jackosx.com/ and install it.

  * Prepare homebrew

        $ curl -fsSk https://raw.github.com/mxcl/homebrew/go | ruby

  * Install openlase with brew

        $ brew install openlase --HEAD

# Run

  OpenLASE commands are installed in /usr/local/bin. 
  Before run openlase command, launch JackPilot and start it,
  then start openlase command. Open routing window of JackPilot,
  connect openlase output to sound card.

  * openlase-simple
  * openlase-harp
  * openlase-scope
  * openlase-circlescope
  * openlase-playvid
  * openlase-qplayvid

# Credit

  * OpenLASE is developed by Hector Martin.
    http://marcansoft.com/blog/2010/11/openlase-open-realtime-laser-graphics/
    https://github.com/marcan/openlase
  * Homebrew formula by edy555 (TT)

[EOF]