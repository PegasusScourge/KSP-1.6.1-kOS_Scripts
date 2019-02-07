//This is a launch file for Kerbin, written for kOS 1.1.6.1
//KSP version 1.6.1
SET TERMINAL:WIDTH to 70.
SET TERMINAL:HEIGHT to 20.
clearscreen.
PRINT "###############################################".
PRINT "# launchScripts/KerbinLaunch_v1.ks            #".
PRINT "# github/PegasusScourge/KSP-1.6.1-kOS_Scripts #".
PRINT "# KSP_Ver: 1.6.1, kOS_Ver: 1.1.6.1            #".
PRINT "###############################################".
PRINT "".

KerbinLaunch().

DECLARE FUNCTION KerbinLaunch {
	parameter target_apoapsis to 75000.
	parameter target_inclin to 0.

	//Get our information on the craft here
	LOCAL almost_sas to "kill".
	LOCAL ship_acc to 0.
	LOCAL ship_thrust to 0.
	LOCAL ship_thrust_max to 0.
	LOCAL ship_mass to 0.
	LOCAL g to CONSTANT:G.
	
	LOCAL twr to 0.
	LOCAL ship_weight to 0.

	//Set up the craft
	PRINT "Setting up the craft. Do not touch SAS, RCS, THROTTLE etc.".
	RCS OFF.
	SAS OFF.
	LOCK THROTTLE to 1.
	LOCK STEERING to almost_sas.

	//Setup our locked variables
	LOCK ship_mass to SHIP:MASS.
	LOCK ship_thrust to SHIP:MAXTHRUSTAT(SHIP:Q) * THROTTLE.
	LOCK ship_acc to ship_thrust / ship_mass.
	LOCK ship_weight to ship_mass*g.
	
	PRINT "[ Got setup, vessel characteristics: {Mass=" + ROUND(ship_mass,2) + ", Status=" + SHIP:STATUS + "} ]".

	//Check we are landed:
	IF NOT SHIP:STATUS:CONTAINS("PRELAUNCH") {
		//Fail now: we aren't pre-launch!
		PRINT "[ Requirement: NEED TO BE PRELAUNCH! ]".
		PRINT "[ This program will now terminate    ]".
		return.
	}


	PRINT "[ Awaiting vessel launch.... ]".

	UNTIL 0{
		IF NOT SHIP:STATUS:CONTAINS("PRELAUNCH") {
			break.
		}
	}

	//We can now go to space xD
	clearscreen.

	LOCAL sub_orbital to FALSE.
	LOCAL currenttask to "Intitial ascent".
	LOCAL task to 0.
	LOCAL tgt_throttle to 1.
	
	LOCK THROTTLE to tgt_throttle.

	PRINT "##############################################################".
	PRINT "  Status:".
	PRINT "  Current task:".
	PRINT "               ".
	PRINT "  Altitude:".
	PRINT "  Apoapsis(T/C):".
	PRINT "  TWR:".
	PRINT "  Acc:".
	PRINT "               ".
	PRINT "  Thrust:".
	PRINT "##############################################################".
	
	WHEN SHIP:ALTITUDE > 300 THEN {
		LOCK STEERING to HEADING(90, 90).
	}
	
	LOCAL task_1_pitchvels to 150. //Start velocity
	LOCAL task_1_pitchvele to 850. //End velocity
	LOCAL task_1_pitchangs to 85. //Start pitch
	LOCAL task_1_pitchange to 30. //End pitch
	LOCAL task_1_pitchangd to task_1_pitchangs - task_1_pitchange.
	
	LOCAL task_2_pitchvels to 1000.
	LOCAL task_2_pitchvele to 1500.
	LOCAL task_2_pitchangs to 30.
	LOCAL task_2_pitchange to 8.
	LOCAL task_2_pitchangd to task_2_pitchangs - task_2_pitchange.
	
	//task_1_pitchprog
	WHEN SHIP:VERTICALSPEED > task_1_pitchvels THEN{
		LOCK STEERING to HEADING(90, task_1_pitchangs - (task_1_pitchangd*((SHIP:VELOCITY:ORBIT:MAG - task_1_pitchvels) / (task_1_pitchvele - task_1_pitchvels)))).
	}
	
	//task_2_pitchprog
	WHEN SHIP:VELOCITY:ORBIT:MAG  > task_2_pitchvels THEN{
		LOCK STEERING to HEADING(90, task_2_pitchangs - (task_2_pitchangd*((SHIP:VELOCITY:ORBIT:MAG - task_2_pitchvels) / (task_2_pitchvele - task_2_pitchvels)))).
	}

	UNTIL sub_orbital{
	
		WAIT 0.001.
		
		//Display our hud
		
		PRINT "                                   " AT(20,1). PRINT SHIP:STATUS AT(20,1).
		PRINT "                                   " AT(20,2). PRINT currenttask AT (20,2).
		PRINT "                                   " AT(20,4). PRINT ROUND(SHIP:ALTITUDE,0) AT(20,4).
		PRINT "                                   " AT(20,5). PRINT ROUND(target_apoapsis,0) + "/" + ROUND(SHIP:APOAPSIS,0) AT(20,5).
		PRINT "                                   " AT(20,6). PRINT ROUND(twr,2) AT(20,6).
		PRINT "                                   " AT(20,7). PRINT ROUND(ship_acc,3) + " m/s^2" AT(20,7).
		PRINT "                                   " AT(20,9). PRINT ROUND(ship_thrust) + " kN" AT(20,9).
		
		//Do updates
		IF NOT (ship_thrust <= 0.1) {
			SET twr to ship_mass / ship_thrust.
		} else {
			SET twr to 0.
		}
		
		//Figure out our next move
		IF task = 0 { //Intitial ascent
			IF SHIP:ALTITUDE > 6000 OR SHIP:VERTICALSPEED > 145 {
				SET currenttask to "Pitch program".
				SET task to 1.
				//LOCK STEERING to HEADING(90, task_1_pitchangs).
			}
		} ELSE IF task = 1 { //Pitch program
			//Pitch over in increments
			//Pitch from task_1_pitchangs deg to task_2_pitchangs deg
			//task_1_pitchprog
			
			IF SHIP:VELOCITY:ORBIT:MAG > task_1_pitchvele {
				SET currenttask to "Gaining horizontal speed".
				SET task to 2.
				LOCK STEERING to HEADING(90, task_1_pitchange).
			}
		} ELSE IF task = 2 {
			//Pitch from task_2_pitchangs deg to task_2_pitchange deg
			//task_2_pitchprog
			
			IF SHIP:VELOCITY:ORBIT:MAG > task_2_pitchvele {
				SET currenttask to "Rising apoapsis".
				SET task to 3.
				LOCK STEERING to HEADING(90, task_2_pitchange).
			}
		} ELSE IF task = 3 {
			//If we get to 90%+ of the target apoapsis, throttle down and lock to prograde
			IF (SHIP:APOAPSIS / target_apoapsis) > 0.9 {
				LOCK STEERING to SHIP:VELOCITY:ORBIT.
				SET tgt_throttle to 0.3.
				SET task to 4.
				SET currenttask to "Finalising apoapsis".
			}
		} ELSE IF task = 4 {
			IF SHIP:APOAPSIS >= (target_apoapsis + 500) {
				UNLOCK STEERING.
				SAS ON.
				LOCK THROTTLE to 0.
				SET sub_orbital to TRUE.
				SET currenttask to "Achieved target apoapsis!".
			}
		}
	}
	
	//We have an apoapsis, now create a maneuver node and call the maneuver burner to circularise.
	PRINT "Awaiting leaving atmosphere...".
	WAIT UNTIL SHIP:ALTITUDE > 70000.
	
	SET mynode to NODE(TIME:SECONDS + ETA:APOAPSIS, 0, 0, get_circ_dv(target_apoapsis)).
	ADD mynode.
}

DECLARE FUNCTION get_circ_dv {

	parameter alt.

	local mu is body:mu.
	local br is body:radius.

	// present orbit properties
	local vom is velocity:orbit:mag.               // actual velocity
	local r is br + altitude.                      // actual distance to body
	local ra is br + apoapsis.                     // radius at burn apsis
	local v1 is sqrt( vom^2 + 2*mu*(1/ra - 1/r) ). // velocity at burn apsis

	local sma1 is (periapsis + 2*br + apoapsis)/2. // semi major axis present orbit

	// future orbit properties
	local r2 is br + apoapsis.               // distance after burn at apoapsis
	local sma2 is ((alt * 1) + 2*br + apoapsis)/2. // semi major axis target orbit
	local v2 is sqrt( vom^2 + (mu * (2/r2 - 2/r + 1/sma1 - 1/sma2 ) ) ).

	// create node
	local deltav is v2 - v1.
	
	return deltav.

}
