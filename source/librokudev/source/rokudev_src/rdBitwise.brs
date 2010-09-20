' *********************************************************************
' * libRokuDev, Bitwise Math Functions                                *
' *                                                                   *
' * Copyright 2010, GandK Labs.  This library is free software; see   *
' * the LICENSE file in the libRokuDev distribution for more details. *
' *********************************************************************

' ********************************************
' * Right logical (non-sign-extending) shift *
' ********************************************
function rdRightShift(num as integer, count = 1 as integer) as integer
	mult    = 2 ^ count
	summand = 1
	total   = 0

	for i = count to 31
		if (num and summand * mult)
			total = total + summand
		end if
		summand = summand * 2
	end for

	return total
end function

' *******
' * XOR *
' *******
function rdXOR(a as integer, b as integer) as integer
	return ((a and not b) or (not a and b))
end function
