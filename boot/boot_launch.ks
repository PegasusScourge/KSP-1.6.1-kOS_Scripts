SET TERMINAL:WIDTH to 70.
SET TERMINAL:HEIGHT to 20.

PRINT " ".
PRINT "[## BOOTFUNC ##]".

IF (CORE:CURRENTVOLUME:FREESPACE < 8000) {
	PRINT "WARN WARN [## This boot function requires min free 8k space to copy it's files! ##] WARN WARN".
}

IF HOMECONNECTION:ISCONNECTED {
	copypath("0:/boot/boot_launch.ks", "1:/boot/boot_launch.ks").
	SET CORE:BOOTFILENAME to "1:/boot/boot_launch.ks".

	//Copy the kerbin launch script
	compile "0:/KerbinLaunch.ks" to "0:/KerbinLaunch.ksm".
	copypath("0:/KerbinLaunch.ksm", "1:/KerbinLaunch.ksm").
	
	//Copy atmolaunch script
	compile "0:/launchScripts/AtmoLaunch.ks" to "0:/launchScripts/AtmoLaunch.ksm".
	copypath("0:/launchScripts/AtmoLaunch.ksm", "1:/launchScripts/AtmoLaunch.ksm").

	//Copy the maneuver script
	compile "0:/execMan.ks" to "0:/execMan.ksm".
	copypath("0:/execMan.ksm", "1:/execMan.ksm").

	//Copy the util-lib script
	compile "0:/libs/util-lib.ks" to "0:/libs/util-lib.ksm".
	copypath("0:/libs/util-lib.ksm", "1:/libs/util-lib.ksm").

	//Copy the maneuver script
	compile "0:/libs/maneuver.ks" to "0:/libs/maneuver.ksm".
	copypath("0:/libs/maneuver.ksm", "1:/libs/maneuver.ksm").

	PRINT "Copied boot files:".
	PRINT "KerbinLaunch.ks --> KerbinLaunch.ksm".
	PRINT "execMan.ks --> execMan.ksm".
	PRINT "Copied libs".
} ELSE {
	PRINT "No home connection!".
}


PRINT "[## END ##]".
PRINT " ".
