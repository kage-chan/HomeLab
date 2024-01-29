#!/bin/bash

# http://www.patorjk.com/software/taag/#p=display&c=echo&f=Shaded%20Blocky&t=TrueNAS%20SCALE
#  _____             _____ _____ _____    _____ _____ _____ __    _____ 
# |_   _|___ _ _ ___|   | |  _  |   __|  |   __|     |  _  |  |  |   __|
#   | | |  _| | | -_| | | |     |__   |  |__   |   --|     |  |__|   __|
#   |_| |_| |___|___|_|___|__|__|_____|  |_____|_____|__|__|_____|_____|
#                                                                      
# TrueNAS SCALE Helper by Daniel Ketel, 2024
# For latest version visit https://github.com/kage-chan/HomeLab/TNSH
# TrueNAS® is a registered Trademark of IXsystems, Inc.

# Ititialization

mainmenu () {
  clear
  echo "";
  echo "                                                                      ";
  echo " _____             _____ _____ _____    _____ _____ _____ __    _____ ";
  echo "|_   _|___ _ _ ___|   | |  _  |   __|  |   __|     |  _  |  |  |   __|";
  echo "  | | |  _| | | -_| | | |     |__   |  |__   |   --|     |  |__|   __|";
  echo "  |_| |_| |___|___|_|___|__|__|_____|  |_____|_____|__|__|_____|_____|";
  echo "                                                                      ";
  echo "                                  Helper                              ";
  echo "";
  echo " 2024, Daniel Ketel. For latest version visit ";
  echo " https://github.com/kage-chan/HomeLab/TNSH";
  echo ""
  echo "Press p to show post-install menu"
  echo "Press 1 to optimize power settings"
  echo "Press 2 to install a jail"
  echo ""
  read -n 1 -p "Input Selection:" mainmenuinput
  if [ "$mainmenuinput" = "1" ]; then
            optimizepower
        elif [ "$mainmenuinput" = "2" ]; then
            installjail
		elif [ "$mainmenuinput" = "p" ]; then
            postinstall
        else
            echo "Invalid selection. Please select one of the above options."
            echo "Press any key to continue..."
            read -n 1
            clear
            mainmenu
        fi
}

postinstall () {
  clear
  echo ""
  echo ""
  echo "!!! DANGER ZONE !!!"
  echo "Executing these options is meant to be done right after the installation."
  echo "They might break your system if used on a non-clean install."
  echo "Proceed on your own risk!"
  echo ""
  echo "Press 1 to fill up system drive with new parititon"
  echo "Press 2 to make new partition available in zpool"
  echo "Press q to return to main menu"
  echo ""
  read -n 1 -p "Input Selection:  " mainmenuinput
  if [ "$mainmenuinput" = "1" ]; then
            optimizepower
        elif [ "$mainmenuinput" = "2" ]; then
            installjail
		elif [ "$mainmenuinput" = "q" ]; then
            mainmenu
        else
            echo "Invalid selection. Please select one of the above options."
            echo "Press any key to continue..."
            read -n 1
            clear
            postinstall
        fi
}

optimizepower () {
  echo "Not implemented yet"
}

installjail () {
  echo "Not implemented yet"
}

# This builds the main menu and routs the user to the function selected.
mainmenu
