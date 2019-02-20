parameter prec.

execute_maneuver(prec).

runoncepath("libs/util-lib.ksm").
DECLARE FUNCTION execute_maneuver {
	parameter precision to 0.3.
	
	SET TERMINAL:WIDTH to 70.
	SET TERMINAL:HEIGHT to 20.
	
	LOCAL mynode to nextnode.
	IF precision < 0.3 {
		SET precision to 0.3.
	}
	
	//Check to see if we have thrust
	IF SHIP:MAXTHRUST = 0 {
		PRINT "ERROR: No current thrust! Did you forget to enable engines?".
		return.
	}
	
	clearscreen.
	PRINT "###################################################".
	PRINT "# libs/maneuver.ks                                #".
	PRINT "# github.com/PegasusScourge/KSP-1.6.1-kOS_Scripts #".
	PRINT "# KSP_Ver: 1.6.1, kOS_Ver: 1.1.6.1                #".
	PRINT "###################################################".
	PRINT "# Executing maneuver node                         #".
	PRINT "###################################################".
	SAS OFF.
	LOCAL throt to 0.
	LOCK STEERING to mynode:DELTAV.
	LOCK THROTTLE to throt.
	//SHIP:MASS
	//SHIP:MAXTHRUST
	LOCAL accl to (SHIP:MAXTHRUST / SHIP:MASS).
	//Calculate how long to burn the dv
	LOCAL burnT to mynode:DELTAV:MAG / accl.
	LOCAL burnhalfT to burnT/2.
	LOCAL timeBurnStart to 0. LOCK timeBurnStart to mynode:ETA - burnhalfT.
	LOCAL l_timeBurnStart to TIME:SECONDS + timeBurnStart.
	
	LOCAL gacc to 9.8.
	LOCK ship_thrust_max to SHIP:MAXTHRUSTAT(SHIP:Q).
	LOCK ship_weight to SHIP:MASS * gacc.
	LOCK twr_max to ship_thrust_max / ship_weight.
	
	PRINT "DeltaV: " + ROUND(mynode:DELTAV:MAG,2) + "m/s".
	PRINT "accl: " + ROUND(accl,2) + "m/s^2".
	PRINT "burnT: " + ROUND(burnT,1) + "s".
	
	WARPTO (l_timeBurnStart - 40).
	UNTIL TIME:SECONDS > l_timeBurnStart {
		PRINT "                                                        " AT(0,10). PRINT "Wait for " + ROUND(timeBurnStart,2) + " seconds... (Warping to)" AT(0,10).
		WAIT 0.001.
	}
	
	SET WARP to 0.
	SET throt to 1.
	UNTIL mynode:DELTAV:MAG < 30 {
		PRINT "                                   " AT(0,7). PRINT "DeltaV: " + ROUND(mynode:DELTAV:MAG,2) + "m/s" AT(0,7).
		PRINT "                                                        " AT(0,10). PRINT "Executing burn..." AT(0,10).
		WAIT 0.001.
	}
	
	SET throt to (0.5/twr_max).
	UNTIL mynode:DELTAV:MAG < precision {
		PRINT "                                   " AT(0,7). PRINT "DeltaV: " + ROUND(mynode:DELTAV:MAG,2) + "m/s" AT(0,7).
		PRINT "                                   " AT(0,10). PRINT "Finalising burn..." AT(0,10).
		WAIT 0.001.
	}
	
	SET throt to 0.
	UNLOCK STEERING.
	SAS ON.
	SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
	UNLOCK THROTTLE.
	PRINT "                                   " AT(0,10). PRINT "Burn complete!" AT(0,10).
	PRINT "###################################".
	PRINT " ".
}