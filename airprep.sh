#!/bin/bash
# Prepares wireless network interface for inconspicous capture. Depends: aircrack-ng, macchanger
# Usage: airprep start: Enable monitor mode, change mac of mon0, and bring down physical interface.
#        airprep stop: Disables monitor mode and brings physical interface back up.
ROOT_UID=0
E_NOTROOT=87
airer1='Error enabling monitor mode. Check interface name'
airer2='Error bringing interface down, check mon int exists'
airer3='Error: mon0 does not exist.'
airer4='Error bringing up mon interface... check rfkill'
macer1='Could not change mac address!'
unknownER='Could not bring up $interface1 Interface possibly blacklisted by rfkill.'
logDIR="/var/log/script"

if [ "$UID" -ne "$ROOT_UID" ]; then
	echo "Must be root to run this script."
exit $E_NOTROOT
fi

if [ ! -d $logDIR ]; then
	mkdir $logDIR && touch $logDIR/airprep.log
fi





function startMON ()
{
	echo "Which interface am I using?"
	read interface1

	date >> $logDIR/airprep.log
	echo "Now attempting to enable monitor mode"
	airmon-ng check kill
	airmon-ng start $interface1 >> $logDIR/airprep.log || echo $airer1
	echo "Success. Bringing $interface1 down..."
	ifconfig $interface1 down >> $logDIR/airprep.log || echo $airer2
	echo "Success. I am now changing our mac address..."
	ifconfig mon0 down >> $logDIR/airprep.log || echo $airer3
	macchanger -a mon0 >> $logDIR/airprep.log || echo $macer1
	macchanger -r -b mon0 >> $logDIR/airprep.log || echo $macer1
	ifconfig mon0 up >> $logDIR/airprep.log || echo $airer4 && exit
	echo "Airprep completed. Inconspicous capture now possible."
	exit
}



function resetINT ()
{
	echo "Which interface am I disabling?"
	read $interface1

	echo "Reseting interface...stopping monitor mode..."
	airmon-ng stop mon0 >> $logDIR/airprep.log || echo $airer3
	echo "Success. Now bringing $interface1 up." || echo $unknownER
	ifconfig $interface1 up >> $logDIR/airprep.log && echo "Done. Station mode reenabled Log located in $logDIR." || echo $unknownER
	exit
}

if [ "$1" == "start" ]; then

	startMON

elif [ "$1" == "stop" ]; then

	resetINT


else


echo -e "
	#########################################################
	# AirPrep v1.1 # Config WNIC for inconspicious capture  #
	# Depends: aircrack-ng & macchange # Author Chev Y.     #
	# USAGE: airprep start|stop | Enable mon interface, and #
	# change mac address. | Disable mon and reset WNIC.     #
	#########################################################"

fi
