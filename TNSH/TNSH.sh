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
#

# Settings that are user-editable
debug=false;

# Global variables
newPartition="";
version="0.5"

printHeader () {
	echo "                                                                      ";
	echo " _____             _____ _____ _____    _____ _____ _____ __    _____ ";
	echo "|_   _|___ _ _ ___|   | |  _  |   __|  |   __|     |  _  |  |  |   __|";
	echo "  | | |  _| | | -_| | | |     |__   |  |__   |   --|     |  |__|   __|";
	echo "  |_| |_| |___|___|_|___|__|__|_____|  |_____|_____|__|__|_____|_____|";
	echo "                                                                      ";
	echo "                               Helper  v"$version"                           ";
	echo "";
	echo " 2024, Daniel Ketel. For latest version visit ";
	echo " https://github.com/kage-chan/HomeLab/TNSH";
	echo "";
}

#------------------------------------------------------------------------------
# name: mainMenu
# args: none
# Shows main menu and lets user choose what to do
#------------------------------------------------------------------------------
mainMenu () {
	clear
	echo "";
	
	printHeader
	
	echo "";
	echo "  Press p to show post-install menu";
	echo "  Press 1 to optimize power settings";
	echo "  Press 2 to install docker & portainer";
	echo "  Press 0 to remove init script and revert changes";
	echo "  Press q to quit";
	echo ""
	# Let user choose menu entry.
	while true; do
		read -n 1 -p "  Input Selection:  " mainMenuInput
		case $mainMenuInput in
		[0]*)
			removeInitScript
			break
			;;
		[1]*)
			optimizePower
			break
			;;
		[2]*)
			installDocker
			break
			;;
		[pP]*)
			postInstall
			break
			;;
		[qQ]*)
			echo "";
			echo "";
			exit;
			;;
		*)
			echo "";
			echo "  Invalid selection. Please select one of the above options.";
			echo "";
		esac
	done	
}

#------------------------------------------------------------------------------
# name: postinstall
# args: none
# Shows post-install menu and lets user choose what to do
#------------------------------------------------------------------------------
postInstall () {
	clear
	echo ""
	echo "  Post-install Menu"
	echo ""
	echo "  !!! DANGER ZONE !!!"
	echo "  Executing these options is meant to be done right after the installation."
	echo "  They might break your system if used on a non-clean install."
	echo "  Proceed on your own risk!"
	echo ""
	echo "  Press 1 to fill up system drive with new parititon"
	echo "  Press 2 to make new partition available in zpool"
	echo "  Press q to return to main menu"
	echo ""
	
	while true; do
		read -n 1 -p "  Input Selection:  " postInstallInput
		
		case $postInstallInput in
		[1]*)
			fillSysDrive
			break
			;;
		[2]*)
			makeAvailableZpool
			break
			;;
		[qQ]*)
			mainMenu
			break
			;;
		*)
			echo ""
			echo "  Invalid selection. Please select one of the above options."
			echo ""
			continue
		esac
	done
}

#------------------------------------------------------------------------------
# name: installModeMenu
# args: none
# Modifies the TrueNAS SCALE installer, user can choose partition size
#------------------------------------------------------------------------------
installModeMenu () {
	clear
	echo "";
	
	printHeader
	
	echo "";
	echo "  ---=== INSTALL MODE ===---";
	echo "  In install mode this script offers only one function:";
	echo "  Install TrueNAS SCALE on a partition rather than the whole disk.";
	echo "";
	echo "  Please choose the size of the system partition";
	echo "";
	echo "  1.  16 GB  (is enough, might get tight at some point)";
	echo "  2.  32 GB  (generally recommended)";
	echo "  3.  64 GB  (to be on the safe side, if you have some disk space to spare)";
	echo "  Press q to quit";
	echo "";
	
	size="";
	
	# Let user choose partition size
	while true; do
		read -n 1 -p "  Input Selection:  " installInput
		
		case $installInput in
		[1]*)
			size="16G"
			break
			;;
		[2]*)
			size="32G"
			break
			;;
		[3]*)
			size="64G"
			break
			;;
		[qQ]*)
			exit;
			;;
		*)
			echo ""
			echo "  Invalid selection. Please select one of the above options."
			echo ""
			continue
		esac
	done
	
	sed -i 's/sgdisk -n3:0:0/sgdisk -n3:0:+'$size'/g' /usr/sbin/truenas-install /usr/sbin/truenas-install
	/usr/sbin/truenas-install
	exit
}

#------------------------------------------------------------------------------
# name: optimizePower
# args: none
# Shows post-install menu and lets user choose what to do
#------------------------------------------------------------------------------
optimizePower () {
	echo "";
	echo "  Checking if PCIE ASPM is enabled..."
	if [ $(dmesg | grep "OS supports" | grep ASPM | wc -l) -ge 1 ] ; then
		echo "  PCIE ASPM supported by os and active. Activating powersave modes."
	else
		echo ""
		echo "  No PCIE ASPM detected"
		echo "  If hardware supports ASPM, please check BIOS if ASPM is to be handled by OS or BIOS. If \"Auto\" setting exists, force ASPM to be handled by OS. You may also try using the4 pcie_aspm=force kernel parameter. Before doing so, please ensure that all your PCIe devices do support ASPM, otherwise forcing the kernel to enable ASPM might result in an unstable system."
	fi
	
	powertop --auto-tune -q >> /dev/null
	echo "powersave" > /sys/module/pcie_aspm/parameters/policy
	
	while true; do
		echo "  Power usage optimized. May take a minute to settle in. Please check power usage if available";
		echo "";
		read -n 1 -p "  Do you want these settings to be made permanent? [y/n]  " keepChanges
		
		case $keepChanges in
		[yY]*)
			# Create RC script
			buildInitScript POWER
			echo "  Changes made permanent"
			break
			;;
		[nN]*)
			echo "";
			echo "  Resetting PCIe ASPM mode to default. To fully revert to default power management, please reboot";
			echo default > /sys/module/pcie_aspm/parameters/policy
			break
			;;
		*)
			echo ""
			echo "  Invalid selection. Please select yes or no."
			continue
		esac
	done
	
	read -n 1 -p "  Press any key to return to the main menu"
	mainMenu
}

installDocker () {
  echo "Not implemented yet"
  mainMenu
  
  # TODO Steps needed
  # Create Bridge interface (if not already done by user)
	ifaces=$(ifconfig -s)
	interfaces=()
	bridges=()
	j=1
	echo "";
	echo "  0.  Abort";
	while read -ra dev; do
		for i in "${dev[@]}"; do
			interfaces+=($i)
			echo "  "$j". " $i
			
			# If interface is a bridge interface, additionally put it into the list of bridges,
			# so we can correctly determine the number for the new bridge interface without breaking things
			if [[ $string == br[0-9]* ]] ; then
				bridges+=($i)
			fi
			((j=j+1))
		done
	done <<< "$ifaces"
	
	# Show detected network interfaces and let user choose the one ha wants to use
	echo ""
	while true; do
		read -n 1 -p "  Select network interface currently in use: [0-"$((j-1))"] " selectedInterface
		
		# Check if input is numeric
		re='^[0-9]'
		if ! [[ $selectedInterface =~ $re ]] ; then
			echo "";
			echo "  Error: Not a number. Please try again.";
			continue
		fi

		# Check if selection is higher than list length
		if [ "$selectedInterface" -gt "${#devices[@]}" ] ; then
			echo "  Error: Not a valid option"
			continue
		fi
		
		# Return to menu if user requested abort
		if [[ "$selectedInterface" == 0 ]]; then
			echo "";
			echo "  Aborted";
			read -p "  Press any key to return to the main menu"
			mainMenu
		fi
		
		break
	done
   
	# Create the new network bridge
	# cli -c "network interface create name=\"br0\" type=BRIDGE bridge_members=\"enp4s0\" ipv4_dhcp=true"
	# cli -c "network interface update enp4s0 ipv4_dhcp=false"
	cli -c "network interface create name=\"br"${#bridges[@]}"\" type=BRIDGE bridge_members=\""${interfaces[(($selectedInterface-1))]}"\" ipv4_dhcp=true"
	cli -c "network interface update name=\""${interfaces[(($selectedInterface-1))]}"\" ipv4_dhcp=false"
  
  # Create systemd-nspawn "container" (ask user which filesystems to "import" there)
  # Install docker inside the container (ask if portainer + watchtower)
  # Add code to init script that starts container at boot post init
}

#------------------------------------------------------------------------------
# name: fillSysDrive
# args: none
# Shows post-install menu and lets user choose what to do
#------------------------------------------------------------------------------
fillSysDrive () {
	echo ""
	echo "  Block devices detected:"
  
	# Get list of block devices and push into an array
	blks=$(lsblk -o NAME --path | grep "^[/]")
	devices=()
	j=1
	echo "";
	echo "  0.  Abort";
	while read -ra dev; do
		for i in "${dev[@]}"; do
			devices+=($i)
			echo "  "$j". " $i
			((j=j+1))
		done
	done <<< "$blks"
  
	# Show detected block devices and let user choose right one
	echo ""
	while true; do
		read -n 1 -p "  Select block device TrueNAS SCALE is installed on: [0-"$((j-1))"] " selectedDrive
		
		# Check if input is numeric
		re='^[0-9]'
		if ! [[ $selectedDrive =~ $re ]] ; then
			echo "";
			echo "  Error: Not a number. Please try again.";
			continue
		fi

		# Check if selection is higher than list length
		if [ "$selectedDrive" -gt "${#devices[@]}" ] ; then
			echo "  Error: Not a valid option"
			continue
		fi
		
		# Return to menu if user requested abort
		if [[ "$selectedDrive" == 0 ]]; then
			echo "";
			echo "  Aborted";
			read -p "  Press Enter to return to post-install menu"
			postInstall
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
	echo "  Please check below if the partition \"services\" has been created successfully";
	echo "";
	parted -s $device unit GB print;

	while true; do
		read -n 1 -p "  Has the partition successfully been created? [y/n]  " confirmation
  
		case $confirmation in
		[yY]*)
			echo "";
			break
			;;
		[nN]*)
			echo "";
			echo "  Error: unable to create services partition. Exiting";
			exit
			;;
		*)
			echo "  Invalid choice. Please try again";
		esac
	done
	
	echo "";
	
	# Ask user if script should proceed and make created partition available to zpool
	numPartitions=0;
	while true; do
		read -n 1 -p "  Should the new partition be made available to zpool now? [y/n]  " dozpool
  
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
			echo "  Invalid choice. Please try again";
		esac
	done
}

#------------------------------------------------------------------------------
# name: makeAvailableZpool
# args: none
# Creates a zpool using the additional partition on the system disk and
# exports it, so it can be imported again from the UI
#------------------------------------------------------------------------------
makeAvailableZpool () {
	# Determine if partition has been created in previous step
	if [ "$newPartition" = "" ]; then
		# Let user choose device to use
		# Get list of block devices and push into an array
		blks=$(lsblk -o NAME --path  | grep "^[/]")
		devices=()
		j=1
		echo "";
		echo "  0.  Abort";
		while read -ra dev; do
			for i in "${dev[@]}"; do
			devices+=($i)
			echo "  "$j". " $i
			((j=j+1))
			done
		done <<< "$blks"
		
		echo ""
		while true; do
			read -n 1 -p "  Select block device to use: [0-"$((j-1))"] " selectedDev
		
			# Check if input is numeric
			re='^[0-9]'
			if ! [[ $selectedDev =~ $re ]] ; then
				echo "";
				echo "  Error: Not a number. Please try again.";
				continue
			fi

			# Check if selection is higher than list length
			if [ "$selectedDev" -gt "${#devices[@]}" ] ; then
				echo "  Error: Not a valid option"
				continue
			fi
		
			# Return to menu if user requested abort
			if [[ "$selectedDev" == 0 ]]; then
				echo "";
				echo "  Aborted";
				read -p "  Press Enter to return to post-install menu"
				postinstall
			fi
			
			break
		done
		
		device=${devices[$selectedDev-1]}
		
		# Let user choose partition to use
		# Discard first entry in list, because it will be the device itself
		parts=$(lsblk -l -o NAME --path  | grep "^$device" | tail -n +2)
		partitions=()
		j=1
		echo "";
		echo "  0.  Abort";
		while read -ra part; do
			for i in "${part[@]}"; do
			partitions+=($i)
			echo "  "$j". " $i
			((j=j+1))
			done
		done <<< "$parts"
		
		echo ""
		while true; do
			read -n 1 -p "  Select partition to use: [0-"$((j-1))"] " selectedPart
		
			# Check if input is numeric
			re='^[0-9]'
			if ! [[ $selectedPart =~ $re ]] ; then
				echo "";
				echo "  Error: Not a number. Please try again.";
				continue
			fi

			# Check if selection is higher than list length
			if [ "$selectedPart" -gt "${#partitions[@]}" ] ; then
				echo "  Error: Not a valid option"
				continue
			fi
		
			# Return to menu if user requested abort
			if [[ "$selectedPart" == 0 ]]; then
				echo "";
				echo "  Aborted";
				read -p "  Press Enter to return to post-install menu"
				postInstall
			fi
			
			break
		done
		
		if [[ $device == /dev/nvme* ]] ; then
			newPartition=${device}p$selectedPart
		else
			newPartition=$device$selectedPart
		fi
	fi
	
	if $debug ; then
		echo "";
		echo "  Partition to be used:" $newPartition;
	fi
	
	# Using the TrueNAS CLI here is not possible, since storage pool create does not support
	# creating pools with partitoins, but only whole devices.
	zpool create -f services $newPartition
	zpool export services
	# TODO Maybe use the following command in future versions?
	# cli -c "storage pool create name=\"services\" topology={\"data\":{\"type\":\"STRIPE\",\"disks\":[\"/dev/nvme0n1p5\"]}}
	# Should do the same, but must do a little more testing
	
	echo "  Successfully created and exported zpool.";
	echo "  Sadly, at this point TrueNAS SCALE's CLI's storage pool import_pool command is broken and does not correspond to the documentation."
	echo "  So, to have full control over the pool, please import it from the \"Storage\" screen in the WebUI.";
	echo "  Please import the pool with the name \"services\".";
	
	echo ""
	read -p "  Press Enter to return to post-install menu"
	postInstall
}

#------------------------------------------------------------------------------
# name: buildInitScript
# args: none
# Builds the init script, writes it and registers it with TrueNAS SCALES's
# init system so it will be called during boot
#------------------------------------------------------------------------------
buildInitScript () {
	configPower=false
	configDocker=false
	initScript=""
	initExists=false
	# If rc script exists, find out current configuration
	if test -d /mnt/services ; then
		if $debug ; then
			echo "";
			echo "  Detected services partition. Will place config file there";
		fi
		
		initScript=/mnt/services/tnshInit.sh
	else
		echo "";
		echo "  No services partition detected in /mnt/services!";
		echo "";
		echo "  You can choose a custom path for the init script at this point. Please note that ";
		echo "  this in theory is optional. \"/etc/init.d/tnsh\" will be used if you leave the";
		echo "  path empty. ";
		echo "  WARNING: In the default location the init script will likely be removed each time";
		echo "           you install an update for TrueNAS SCALE. Only paths on a different dataset";
		echo "           than the system will survive updates!";
		echo "";
		
		while true; do
			read -p "  Please specify desired directory for the init script: " initScript
		
			if [[ -z "$initScript" ]] ; then
				echo "";
				echo "  Using /etc/init.d/tnsh. ";
				echo "  It is very likely that the script will be removed by future TrueNAS SCALE updates.";
				echo "  Please be aware of this and periodically rerun this script after updating TrueNAS SCALE.";
				echo "";
				initScript=/etc/init.d/tnsh
				break
			fi
			
			if [[ ! -d "$initScript" ]] ; then
				echo "";
				echo "  Directory does not exist. Please specify an existing folder.";
				echo "";
				continue
			fi
		
			if [[ $initScript != /* ]] ; then
				echo ""
				echo "  Please specify an absolute path";
				echo ""
				continue
			fi
		
			if [[ $initScript != /mnt/* ]] ; then
				echo "";
				echo "  Path is not inside a different dataset.";
				echo "  It is very likely that the script will be removed by future TrueNAS SCALE updates.";
				echo "  Please be aware of this and periodically rerun this script after updating TrueNAS SCALE.";
				echo "";
				
				if [[ $initScript == */ ]] ; then
					initScript+="tnshInit.sh"
				else
					initScript+="/tnshInit.sh"
				fi
				break
			fi
		done
	fi
	
	if test -f $initScript; then
		initExists=true
	
		if $debug ; then
			echo "";
			echo "  Init script already exists. Checking contents";
		fi
		
		# Current configuration is coded into the third line of init script
		config=$(sed -n '3q;d' $initScript)
		for i in "${config[@]}"; do
			case $i in
			[POWER]*)
				configPower=true
				break
				;;
			[DOCKER]*)
				configDocker=true
				break
				;;
			*)
			esac
		done
	else
		touch $initScript
	fi
	
	# Check what is to be added
	case $1 in
	[POWER]*)
		configPower=true
		;;
	[DOCKER]*)
		configDocker=true
		;;
	*)
	esac
	
	# Write file header including current config
	echo "#!/bin/bash" > $initScript;
	echo "# ! DO NOT EDIT THIS FILE !" >> $initScript;

	echo -n "#" >> $initScript;
	
	if $configPower == true ; then
		echo -n " POWER" >> $initScript;
	fi
	
	if $configDocker == true ; then
		echo -n " DOCKER" >> $initScript;
	fi
	
	echo ""
	if $debug ; then
		echo "  Writing init script...";
	fi
	
	# Write file's description
	echo "" >> $initScript;
	echo "#" >> $initScript;
	# Make sure header is commented, otherwise script will be broken
	printHeader | sed 's/^/# /' >> $initScript
	echo ""  >> $initScript;
	echo "#  This is a supplement script to make the original script's settings   "  >> $initScript;
	echo "#  permanent and enable them at boot."  >> $initScript;
	echo ""  >> $initScript;
	
	
	# Actual init script starts here
	if $configPower == true ; then
		echo ""  >> $initScript;
		echo "# Powermanagement"  >> $initScript;
		echo "powertop --auto-tune"  >> $initScript;
		echo "echo powersave > /sys/module/pcie_aspm/parameters/policy"  >> $initScript;
	fi
	
	if $configDocker == true; then
		echo ""  >> $initScript;
		echo "# Docker container"  >> $initScript;
		echo ""  >> $initScript;
		echo ""  >> $initScript;
	fi
	
	# Enable init script
	query=$(cli -c "system init_shutdown_script query" | grep tnsh | wc -l)
	if [ "$query" -lt 1 ] ; then
		chmod ugo+x $initScript
		cli -c "system init_shutdown_script create type=SCRIPT script=\""$initScript"\" when=POSTINIT"
	fi
}

#------------------------------------------------------------------------------
# name: removeInitScript
# args: none
# Deletes the init script and unregisters it from TrueNAS SCALE's init system
#------------------------------------------------------------------------------
removeInitScript () {
	initScript="/mnt/services/tnshInit.sh"
	# Ask user if he is sure
	while true; do
		echo "";
		echo "  Deleting the init script will revert all permanent changes to the system after rebooting.";
		read -n 1 -p "  Are your sure that you want to delete the init script? [y/n]  " confirmation
  
		case $confirmation in
		[yY]*)
			echo "";
			
			# Get current ID of tnsh init script
			OIFS=$IFS
			IFS='|'
			query=$(cli -c "system init_shutdown_script query" | grep tnsh)
			IFS=$OIFS
			
			if $debug ; then
				echo "  Query returned the following entries: ";
				echo $query
			fi
			
			# Check if init script was registered. If not, return to main menu
			if [ ${#query} -eq 0 ] ; then
				echo "  Init script has not been registered with startup system in the past. Aborting."
				read -p "  Press Enter to return to main menu"
				mainMenu
			fi
			
			id=0
			j=0;
			for i in $query ; do
				if [ $j -eq 1 ] ; then
					if $debug ; then
						echo "  ID is" $i;
						echo "  Deleting entry";
					fi
					
					cli -c "system init_shutdown_script delete id=\""$i"\""
				fi
				
				if [ $j -eq 6 ] ; then
					if $debug ; then
						echo "  Path to init script is" $i"; Deleting";
					fi
					
					rm $i >> /dev/null
				fi
				((j=j+1))
			done
			
			
			read -p "  Press Enter to return to main menu"
			mainMenu
			;;
		[nN]*)
			echo "";
			read -p "  Aborting. Press Enter to return to main menu"
			mainMenu
			;;
		*)
			echo "  Invalid choice. Please try again";
		esac
	done
}


#------------------------------------------------------------------------------
# name: 
# args: none
# Main program that is called when script is launched
#------------------------------------------------------------------------------

# Check if script is running as root
if [ $(whoami) != 'root' ]; then
	echo "  This script must be run as root. Please try again as root."
	exit;
fi

# Check if running on install boot media
cmdline=$(cat /proc/cmdline | grep "vmlinuz " | grep "boot=live" | wc -l)
if [ "$cmdline" -ge 1 ] ; then
	read -n 1 -p "  Installer environment detected. Do you want to proceed in install mode? [y/n]  " confirmation
  
		case $confirmation in
		[yY]*)
			installModeMenu
			;;
		[nN]*)
			echo "  Continuing in normal mode";
			echo "";
			;;
		*)
			;;
		esac
fi

mainMenu
