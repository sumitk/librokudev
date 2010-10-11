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
	kq = "" ' for BRS
	if outformat = "JSON" then kq = chr(34)
	out = ""
	v = box(v)
	vType = type(v)
	if     vType = "roString"
		re = CreateObject("roRegex",chr(34),"")
		v = re.replaceall(v, chr(34)+"+chr(34)+"+chr(34) )
		out = out + chr(34) + v + chr(34)
	elseif vType = "roInt"
		out = out + v.tostr()
	elseif vType = "roFloat"
		out = out + str(v)
	elseif vType = "roBoolean"
		bool = "false"
		if v then bool = "true"
		out = out + bool
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
		out = out + "(Function)"
	else
		out = out + chr(34) + vType + chr(34)
	end if
	return out
end function

