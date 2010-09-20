' *********************************************************************
' * libRokuDev, Bitwise Math Functions                                *
' *                                                                   *
' * Copyright 2010, GandK Labs.  This library is free software; see   *
' * the LICENSE file in the libRokuDev distribution for more details. *
' *********************************************************************

' *************************************************************************
' * Recursive stringification of data structures, doubles as JSON creator *
' *************************************************************************
function rdSerialize(v as dynamic, outformat="BRS" as string) as string
	q = chr(34)
	kq = "" ' for BRS
	if outformat = "JSON" then kq = chr(34)
	out = ""
	v = box(v)
	vType = type(v)
	if     vType = "roString"
		re = CreateObject("roRegex",q,"")
		v = re.replaceall(v, q+"+q+"+q )
		out = out + q + v + q
	elseif vType = "roInt"
		out = out + v.tostr()
	elseif vType = "roFloat"
		out = out + str(v)
	elseif vType = "roBoolean"
		out = out + rdIIf(v, "true", "false")
	elseif vType = "roList" or vType = "roArray"
		out = out + "["
		sep = ""
		for each child in v
			out = out + sep + rdSerialize(child, outformat)
			sep = ","
		end for
		out = out + "]"
	elseif vType = "roAssociativeArray"
		out = out + "{"
		sep = ""
		for each key in v
			out = out + sep + kq + key + kq + ":"
			out = out + rdSerialize(v[key], outformat)
			sep = ","
		end for
		out = out + "}"
	elseif vType = "roFunction"
		out = out + "Function of length " + v.getsub().len().tostr() + ","
	else
		out = out + q + vType + q
	end if
	return out
end function

