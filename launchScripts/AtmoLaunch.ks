parameter tap, tin, mtwr, atlim.

//Open our libs
runoncepath("libs/util-lib.ksm").
runoncepath("libs/maneuver.ksm").

//parameter tap to 75000.
//parameter tin to 0.
//parameter mtwr to 2.2.
//parameter atlim to 70000.

AtmoLaunch(tap, tin, mtwr, atlim).

DECLARE FUNCTION AtmoLaunch {
	parameter target_apoapsis to 75000.
	parameter target_inclin to 0.
	parameter max_twr to 2.2.
	parameter atmo_lim to 70000.
	
	SET TERMINAL:WIDTH to 70.
	SET TERMINAL:HEIGHT to 20.
	clearscreen.
	PRINT "###################################################".
	PRINT "# launchScripts/AtmoLaunch.ks                     #".
	PRINT "# github.com/PegasusScourge/KSP-1.6.1-kOS_Scripts #".
	PRINT "# KSP_Ver: 1.6.1, kOS_Ver: 1.1.6.1                #".
	PRINT "###################################################".
	//PRINT "NOTICE: YOU MUST MANUALLY MANAGE STAGING!!!".

	// --- Get our information on the craft here ---
	LOCAL almost_sas to "kill".
	LOCAL ship_acc to 0.
	LOCAL ship_thrust to 0.
	LOCAL ship_thrust_max to 0.
	LOCAL ship_mass to 0.
	LOCAL gacc to 9.8.
	
	LOCAL tgt_inclin to target_inclin.
	IF target_inclin > 180 {
		SET tgt_inclin to -180 + target_inclin.
	}
	IF target_inclin < -180 {
		SET tgt_inclin to 180 - target_inclin.
	}
	LOCAL ship_heading_ang to 90 + tgt_inclin.
	
	LOCAL twr to 0.
	LOCAL twr_max to 0.
	LOCAL ship_weight to 0.

	// --- Set up the craft ---
	PRINT "Setting up the craft. Do not touch SAS, RCS, THROTTLE etc.".
	RCS OFF.
	SAS OFF.
	LOCK THROTTLE to 1.
	LOCK STEERING to almost_sas.

	// --- LOCK VARIABLES HERE ---
	LOCK ship_mass to SHIP:MASS.
	LOCK ship_thrust to SHIP:MAXTHRUSTAT(SHIP:Q) * THROTTLE.
	LOCK ship_thrust_max to SHIP:MAXTHRUSTAT(SHIP:Q).
	LOCK ship_acc to (ship_thrust / ship_mass) - gacc.
	LOCK ship_weight to ship_mass * gacc.
	LOCK twr to ship_thrust / ship_weight.
	LOCK twr_max to ship_thrust_max / ship_weight.
	
	PRINT "[ Got setup, vessel characteristics: {Mass=" + ROUND(ship_mass,2) + ", Status=" + SHIP:STATUS + ", gacc=" + gacc + "} ]".
	PRINT "[ Target inclination: " + target_inclin + " --> " + tgt_inclin + ", HDG: " + ship_heading_ang + "]".

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
	
	LOCAL enginesList to 0.
	LIST ENGINES in enginesList.
	
	LOCK THROTTLE to tgt_throttle.

	PRINT "###################################################".
	PRINT "# launchScripts/AtmoLaunch.ks                     #".
	PRINT "# github.com/PegasusScourge/KSP-1.6.1-kOS_Scripts #".
	PRINT "# KSP_Ver: 1.6.1, kOS_Ver: 1.1.6.1                #".
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
		LOCK STEERING to HEADING(ship_heading_ang, 90).
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
		LOCK STEERING to HEADING(ship_heading_ang, task_1_pitchangs - (task_1_pitchangd*((SHIP:VELOCITY:ORBIT:MAG - task_1_pitchvels) / (task_1_pitchvele - task_1_pitchvels)))).
	}
	
	//task_2_pitchprog
	WHEN SHIP:VELOCITY:ORBIT:MAG  > task_2_pitchvels THEN{
		LOCK STEERING to HEADING(ship_heading_ang, task_2_pitchangs - (task_2_pitchangd*((SHIP:VELOCITY:ORBIT:MAG - task_2_pitchvels) / (task_2_pitchvele - task_2_pitchvels)))).
	}

	UNTIL sub_orbital{
	
		WAIT 0.001.
		
		//Display our hud
		
		PRINT "                                   " AT(20,5). PRINT SHIP:STATUS AT(20,5).
		PRINT "                                   " AT(20,6). PRINT currenttask AT (20,6).
		PRINT "                                   " AT(20,8). PRINT ROUND(SHIP:ALTITUDE,0) AT(20,8).
		PRINT "                                   " AT(20,9). PRINT ROUND(target_apoapsis,0) + "/" + ROUND(SHIP:APOAPSIS,0) AT(20,9).
		PRINT "                                   " AT(20,10). PRINT ROUND(twr,2) AT(20,10).
		PRINT "                                   " AT(20,11). PRINT ROUND(ship_acc,3) + " m/s^2" AT(20,11).
		PRINT "                                   " AT(20,13). PRINT ROUND(ship_thrust) + " kN" AT(20,13).
		
		//Do updates
		
		IF task > 0 AND task < 3 {
			//Control the throttle
			IF twr > max_twr {
				IF twr_max = 0 {
					SET tgt_throttle to 1.
				} ELSE {
					SET tgt_throttle to max_twr / twr_max.
				}
			} ELSE IF tgt_throttle < 1{
				SET tgt_throttle to 1.
			}
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
				LOCK STEERING to HEADING(ship_heading_ang, task_1_pitchange).
			}
		} ELSE IF task = 2 {
			//Pitch from task_2_pitchangs deg to task_2_pitchange deg
			//task_2_pitchprog
			
			IF SHIP:VELOCITY:ORBIT:MAG > task_2_pitchvele {
				SET currenttask to "Rising apoapsis".
				SET task to 3.
				LOCK STEERING to HEADING(ship_heading_ang, task_2_pitchange).
			}
		} ELSE IF task = 3 {
			//If we get to 90%+ of the target apoapsis, throttle down and lock to prograde
			IF (SHIP:APOAPSIS / target_apoapsis) > 0.9 {
				LOCK STEERING to SHIP:VELOCITY:ORBIT.
				SET tgt_throttle to (0.5/twr_max).
				SET task to 4.
				SET currenttask to "Finalising apoapsis".
			}
		} ELSE IF task = 4 {
			IF SHIP:APOAPSIS >= (target_apoapsis + 500) {
				UNLOCK STEERING.
				SAS ON.
				SET tgt_throttle to 0.
				SET sub_orbital to TRUE.
				SET currenttask to "Achieved target apoapsis!".
			}
		}
		
		//Check for staging:
		FOR e in enginesList {
			IF e:FLAMEOUT OR SHIP:MAXTHRUSTAT(SHIP:Q) = 0{
				STAGE.
				//PRINT "Staging!".
				
				UNTIL STAGE:READY { WAIT 0. }
				
				LIST ENGINES in enginesList.
				BREAK.
			}
		}
	}
	
	//We have an apoapsis, now create a maneuver node and call the maneuver burner to circularise.
	SET currenttask to "Waiting until out of atmo".
	PRINT "                                   " AT(20,5). PRINT SHIP:STATUS AT(20,5).
	PRINT "                                   " AT(20,6). PRINT currenttask AT (20,6).
	WAIT UNTIL SHIP:ALTITUDE > atmo_lim.
	
	SET WARP to 0.
	
	SET currenttask to "Handing control to maneuver node func".
	PRINT "                                   " AT(20,5). PRINT SHIP:STATUS AT(20,5).
	PRINT "                                   " AT(20,6). PRINT currenttask AT (20,6).
	SET mynode to NODE(TIME:SECONDS + ETA:APOAPSIS, 0, 0, get_circ_dv(target_apoapsis)).
	ADD mynode.
	WAIT 2.
	
	UNLOCK STEERING.
	SAS ON.
	SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
	UNLOCK THROTTLE.
	
	execute_maneuver().
}
