SET TERMINAL:WIDTH to 70.
SET TERMINAL:HEIGHT to 20.

PRINT " ".
PRINT "[## BOOTFUNC ##]".

IF (CORE:CURRENTVOLUME:FREESPACE < 5000) {
	PRINT "WARN WARN [## This boot function requires min 5k free space to copy it's files! ##] WARN WARN".
}

IF HOMECONNECTION:ISCONNECTED {
	copypath("0:/boot/boot_space.ks", "1:/boot/boot_space.ks").
	SET CORE:BOOTFILENAME to "1:/boot/boot_space.ks".

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
	PRINT "execMan.ks --> execMan.ksm: execute_maneuver([precision=0.3])".
	PRINT "Copied libs".
} ELSE {
	PRINT "No home connection!".
}

PRINT "[## END ##]".
PRINT " ".
