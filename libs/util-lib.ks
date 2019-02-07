//A utils lib

//alt in meters
//returns dv
DECLARE FUNCTION get_circ_dv {
	parameter alt.
	local mu is body:mu.
	local br is body:radius.
	// present orbit properties
	local vom is velocity:orbit:mag.
	local r is br + altitude.
	local ra is br + apoapsis.
	local v1 is sqrt( vom^2 + 2*mu*(1/ra - 1/r) ). 
	local sma1 is (periapsis + 2*br + apoapsis)/2.
	// future orbit properties
	local r2 is br + apoapsis.
	local sma2 is ((alt * 1) + 2*br + apoapsis)/2.
	local v2 is sqrt( vom^2 + (mu * (2/r2 - 2/r + 1/sma1 - 1/sma2 ) ) ).
	local dv to v2 - v1.
	return dv.

}