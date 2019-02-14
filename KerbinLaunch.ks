//This is a launch file for Kerbin, written for kOS 1.1.6.1
//KSP version 1.6.1

runpath("launchScripts/AtmoLaunch.ksm", 75000, 0, 2.2, 70000). //Launch for Kerbin

//We can now remove the launch script from the disk
PRINT "### AtmoLaunch ###".
PRINT "Removing launch scripts and setting new boot file".
deletepath("1:/boot/boot_launch.ks").
deletepath("1:/KerbinLaunch.ksm").
deletepath("1:/launchScripts/AtmoLaunch.ksm").
copypath("0:/boot/boot_space.ks", "1:/boot/boot_space.ks").
SET CORE:BOOTFILENAME to "1:/boot/boot_space.ks".
PRINT CORE:BOOTFILENAME.
PRINT "###".

