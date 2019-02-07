PRINT " ".
PRINT "[## BOOTFUNC ##]".

IF (CORE:CURRENTVOLUME:FREESPACE < 9000) {
	PRINT " WARN WARN [## This boot function requires min free 9k space to copy it's files! ##] WARN WARN".
}

//Copy the kerbin launch script
compile "0:/launchScripts/KerbinLaunch_v1.ks" to "0:/launchScripts/KerbinLaunch_v1.ksm".
copypath("0:/launchScripts/KerbinLaunch_v1.ksm", "1:/launch.ksm").

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
PRINT "KerbinLaunch_v1.ks --> launch.ksm: KerbinLaunch([alituide=75000])".
PRINT "execMan.ks --> execMan.ksm: execute_maneuver([precision=0.3])".
PRINT "Copied libs".

PRINT "[## END ##]".
PRINT " ".