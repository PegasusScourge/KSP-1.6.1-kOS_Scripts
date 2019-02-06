//This is a launch file for Kerbin, written for kOS 1.1.6.1
//KSP version 1.6.1
SET TERMINAL:WIDTH to 100.
SET TERMINAL:HEIGHT to 40.
clearscreen.
PRINT "###############################################".
PRINT "# launchScripts/KerbinLaunch_v1.ks            #".
PRINT "# github/PegasusScourge/KSP-1.6.1-kOS_Scripts #".
PRINT "# KSP_Ver: 1.6.1, kOS_Ver: 1.1.6.1            #".
PRINT "###############################################".
PRINT "".

//Get our information on the craft here
DECLARE almost_sas to "kill".
DECLARE ship_vel to 0.
DECLARE ship_acc to 0.
DECLARE ship_thrust to 0.
DECLARE ship_thrust_max to 0.
DECLARE ship_mass to 0.
DECLARE g to CONSTANT:G.

//Set up the craft
PRINT "Setting up the craft. Do not touch SAS, RCS, THROTTLE etc.".
RCS OFF.
SAS OFF.
LOCK THROTTLE to 1.
LOCK STEERING to almost_sas.

//Setup our locked variables
LOCK ship_vel to SHIP:VELOCITY.
LOCK ship_mass to SHIP:MASS.
LOCK ship_thrust_max to SHIP:AVALIABLETHRUSTAT(VESSEL:Q). //Gets the current thrust of all engines that we can produce
LOCK ship_thrust to ship_thrust_max * THROTTLE. //Gets the current thrust we are producing
LOCK ship_acc to ship_thrust / ship_mass.

PRINT "[ Got setup, vessel characteristics: {Mass=" + ROUND(ship_mass,2) + ", Status=" + SHIP:STATUS + "} ]".
PRINT "[ Awaiting vessel launch.... ]".

UNTIL 0{
	IF NOT SHIP:STATUS:CONTAINS("PRELAUNCH") {
		break.
	}
}

//We can now go to space xD
PRINT "[ STAGING DETECTED: Activating launch sequence ]".
clearscreen.

DECLARE in_orbit to FALSE.

PRINT "##############################################################".
PRINT "# Status:".
PRINT "# Current task:".
PRINT "#".
PRINT "# Altitude:".
PRINT "# Apoapsis(T/C):".
PRINT "# TWR:".
PRINT "# Acc:".
PRINT "##############################################################".

UNTIL in_orbit{
	//Display our hud
}
