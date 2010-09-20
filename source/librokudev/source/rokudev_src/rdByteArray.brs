' *********************************************************************
' * libRokuDev, roByteArray Functions                                 *
' *                                                                   *
' * Copyright 2010, GandK Labs.  This library is free software; see   *
' * the LICENSE file in the libRokuDev distribution for more details. *
' *********************************************************************

' ###########################
' # Requires: rdBitwise.brs #
' ###########################

' ***************************************************************************
' * Create a new roByteArray from a sequence of bytes within a larger array * 
' ***************************************************************************
function rdBAcopy(source as object, index_start = 0 as integer, index_end = 0 as integer) as object
	if index_end = 0
		index_end = buf.count() - 1
	end if

	dest = CreateObject("roByteArray")
	dest.setresize(index_end - index_start, true)

	for i = index_start to index_end - 1
		dest[i - index_start] = source[i]
	end for

	return dest
end function

' **************************************************************************
' * Convert a sequence of up to 4 bytes from a roByteArray into an integer *
' **************************************************************************
function rdBAtoINT(source as object, index_start = 0 as integer, index_end = 0 as integer) as integer
	if index_end = 0 or index_end - index_start > 4
		index_end = index_start + 4
	end if

	if index_end > source.count() or source[index_start] = invalid
		print "rdBAtoInt ending index invalid! ("; index_end; ">"; source.count(); ")"
		return 0
	end if

	num = 0
	for i = index_start to index_end - 1
		num = num + source[i] * 2 ^ ((index_end - 1 - i) * 8)
	end for

	return num
end function

' ************************************************
' * Convert an integer to a (4 byte) roByteArray *
' ************************************************
function rdINTtoBA(num as integer) as object
	ba = CreateObject("roByteArray")
	ba.setresize(4, false)

	ba[0] = rdRightShift(num,24)
	ba[1] = rdRightShift(num,16)
	ba[2] = rdRightShift(num,8)
	ba[3] = num ' truncates

	return ba
end function

' **************************************
' * Convert an integer to a hex string *
' **************************************
function rdINTtoHEX(num as integer) as string
	return rdINTtoBA(num).toHexString()
end function

' ****************************************************************
' * Convert a sequence of bytes within a roByteArray to a string *
' ****************************************************************
function rdBAtoSTR(source as object, index_start = 0 as integer, index_end = 0 as integer) as string
	if index_end = 0
		index_end = source.count() - 1
	end if

	if source.count() <= index_end or source[index_start] = invalid
		return 0
	end if

	ascii = ""
	for i = index_start to index_end - 1
		ascii = ascii + CHR(source[i])
	end for

	return ascii
end function
