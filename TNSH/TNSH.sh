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

# Global variables
newPartition="";

#------------------------------------------------------------------------------
# name: mainmenu
# args: none
# Shows main menu and lets user choose what to do
#------------------------------------------------------------------------------
mainmenu () {
	clear
	echo "";
	echo "                                                                      ";
	echo " _____             _____ _____ _____    _____ _____ _____ __    _____ ";
	echo "|_   _|___ _ _ ___|   | |  _  |   __|  |   __|     |  _  |  |  |   __|";
	echo "  | | |  _| | | -_| | | |     |__   |  |__   |   --|     |  |__|   __|";
	echo "  |_| |_| |___|___|_|___|__|__|_____|  |_____|_____|__|__|_____|_____|";
	echo "                                                                      ";
	echo "                               Helper  v0.2                           ";
	echo "";
	echo " 2024, Daniel Ketel. For latest version visit ";
	echo " https://github.com/kage-chan/HomeLab/TNSH";
	echo "";
	echo "";
	echo "Press p to show post-install menu";
	echo "Press 1 to optimize power settings";
	echo "Press 2 to install docker & portainer";
	echo "Press q to quit";
	echo ""
	# Let user choose menu entry.
	while true; do
		read -n 1 -p "Input Selection:  " mainmenuinput
		case $mainmenuinput in
		[1]*)
			optimizepower
			break
			;;
		[2]*)
			installdocker
			break
			;;
		[pP]*)
			postinstall
			break
			;;
		[qQ]*)
			echo "";
			exit;
			;;
		*)
			echo "";
			echo "Invalid selection. Please select one of the above options.";
			echo "";
		esac
	done	
}

#------------------------------------------------------------------------------
# name: postinstall
# args: none
# Shows post-install menu and lets user choose what to do
#------------------------------------------------------------------------------
postinstall () {
	clear
	echo ""
	echo "Post-install Menu"
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
	
	while true; do
		read -n 1 -p "Input Selection:  " postinstallinput
		
		case $postinstallinput in
		[1]*)
			fillSysDrive
			break
			;;
		[2]*)
			makeAvailableZpool
			break
			;;
		[qQ]*)
			mainmenu
			break
			;;
		*)
			echo "Invalid selection. Please select one of the above options."
			echo "Press any key to continue..."
			read -n 1
			clear
			postinstall
			break
			;;
		esac
	done
}

optimizepower () {
  echo "Not implemented yet"
}

installdocker () {
  echo "Not implemented yet"
}

#------------------------------------------------------------------------------
# name: fillSysDrive
# args: none
# Shows post-install menu and lets user choose what to do
#------------------------------------------------------------------------------
fillSysDrive () {
	echo ""
	echo "Block devices detected:"
  
	# Get list of block devices and push into an array
	blks=$(lsblk -o NAME --path | grep "^[/]")
	devices=()
	j=1
	echo "";
	echo "0.  Abort";
	while read -ra dev; do
		for i in "${dev[@]}"; do
			devices+=($i)
			echo  $j". " $i
			((j=j+1))
		done
	done <<< "$blks"
  
	# Show detected block devices and let user choose right one
	echo ""
	while true; do
		read -n 1 -p "Select block device TrueNAS SCALE is installed on: [0-"$((j-1))"] " selectedDrive
		
		# Check if input is numeric
		re='^[0-9]'
		if ! [[ $selectedDrive =~ $re ]] ; then
			echo "";
			echo "Error: Not a number. Please try again.";
			continue
		fi

		# Check if selection is higher than list length
		if [ "$selectedDrive" -gt "${#devices[@]}" ] ; then
			echo "Error: Not a valid option"
			continue
		fi
		
		# Return to menu if user requested abort
		if [[ "$selectedDrive" == 0 ]]; then
			echo "";
			echo "Aborted";
			read -p "Press Enter to return to post-install menu"
			postinstall
		fi
		
		break
	done
  
	# Get sector of current last physical partition's end and create new partition behind that
	device=${devices[(($selectedDrive-1))]}
	parts=$(parted $device unit s print free | grep Free | tail -1)
	read -ra strt <<< "$parts"
	start=${strt::-1}
	parted -s $device unit s mkpart services $start 100%

	# Show result to user and ask for confirmation
	echo "";
	echo "Please check below if the partition \"services\" has been created successfully";
	echo "";
	parted -s $device unit GB print;

	while true; do
		read -n 1 -p "Has the partition successfully been created? [y/n]  " confirmation
  
		case $confirmation in
		[yY]*)
			echo "";
			break
			;;
		[nN]*)
			echo "";
			echo "Error: unable to create services partition. Exiting";
			exit
			;;
		*)
			echo "Invalid choice. Please try again";
		esac
	done
	
	echo "";
	
	# Ask user if script should proceed and make created partition available to zpool
	numPartitions=0;
	while true; do
		read -n 1 -p "Should the new partition be made available to zpool now? [y/n]  " dozpool
  
		case $dozpool in
		[yY]*)
			# Build string that contains device of the newly created partition
			numPartitions=$(lsblk -l -o NAME --path | grep "^$device" | tail -n +2 | wc -l)
			if [[ $device == /dev/nvme* ]] ; then
				newPartition=${device}p$numPartitions
			else
				newPartition=$device$numPartitions
			fi
			makeAvailableZpool
			break
			;;
		[nN]*)
			echo "";
			break
			;;
		*)
			echo "Invalid choice. Please try again";
		esac
	done
}

makeAvailableZpool () {
	# Determine if partition has been created in previous step
	if [ "$newPartition" = "" ]; then
		# Let user choose device to use
		# Get list of block devices and push into an array
		blks=$(lsblk -o NAME --path  | grep "^[/]")
		devices=()
		j=1
		echo "";
		echo "0.  Abort";
		while read -ra dev; do
			for i in "${dev[@]}"; do
			devices+=($i)
			echo  $j". " $i
			((j=j+1))
			done
		done <<< "$blks"
		
		echo ""
		while true; do
			read -n 1 -p "Select block device to use: [0-"$((j-1))"] " selectedDev
		
			# Check if input is numeric
			re='^[0-9]'
			if ! [[ $selectedDev =~ $re ]] ; then
				echo "";
				echo "Error: Not a number. Please try again.";
				continue
			fi

			# Check if selection is higher than list length
			if [ "$selectedDev" -gt "${#devices[@]}" ] ; then
				echo "Error: Not a valid option"
				continue
			fi
		
			# Return to menu if user requested abort
			if [[ "$selectedDev" == 0 ]]; then
				echo "";
				echo "Aborted";
				read -p "Press Enter to return to post-install menu"
				postinstall
			fi
			
			break
		done
		
		device=${devices[$selectedDev-1]}
		
		# Let user choose partition to use
		# Discard first entry in list, because it will be the device itself
		parts=$(lsblk -l -o NAME --path  | grep "^$device" | tail -n +2 | wc -l)
		partitions=()
		j=1
		echo "";
		echo "0.  Abort";
		while read -ra part; do
			for i in "${part[@]}"; do
			partitions+=($i)
			echo  $j". " $i
			((j=j+1))
			done
		done <<< "$parts"
		
		echo ""
		while true; do
			read -n 1 -p "Select partition to use: [0-"$((j-1))"] " selectedPart
		
			# Check if input is numeric
			re='^[0-9]'
			if ! [[ $selectedPart =~ $re ]] ; then
				echo "";
				echo "Error: Not a number. Please try again.";
				continue
			fi

			# Check if selection is higher than list length
			if [ "$selectedPart" -gt "${#partitions[@]}" ] ; then
				echo "Error: Not a valid option"
				continue
			fi
		
			# Return to menu if user requested abort
			if [[ "$selectedPart" == 0 ]]; then
				echo "";
				echo "Aborted";
				read -p "Press Enter to return to post-install menu"
				postinstall
			fi
			
			break
		done
		
		if [[ $device == /dev/nvme* ]] ; then
			newPartition=${device}p$selectedPart
		else
			newPartition=$device$selectedPart
		fi
	fi
	
	zpool create services $newPartition
	zpool export services
	
	postinstall
}


# Check if script is running as root
if [ $(whoami) != 'root' ]; then
	echo "This script must be run as root. Please try again as root."
	exit;
fi

mainmenu
