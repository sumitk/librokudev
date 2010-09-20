' *********************************************************************
' * libRokuDev, Debug Functions                                       *
' *                                                                   *
' * Copyright 2010, GandK Labs.  This library is free software; see   *
' * the LICENSE file in the libRokuDev distribution for more details. *
' *********************************************************************

' *****************************************
' * Recursive printing of data structures *
' *****************************************
sub rdDebugPrint(obj as dynamic, prefix = "" as string)
	t = type(obj)

	if t = "roList" or t = "roArray"
		print "["
		for each child in obj
			rdDebugPrint(child, prefix + "	")
		end for
		print prefix; "]"
	elseif t = "roAssociativeArray"
		print "{"
		for each key in obj
			print prefix; "	 "; key; ": ";
			rdDebugPrint(obj[key], prefix + "  ")
		end for
		print prefix; "}"
	elseif t = "roFunction"
		print prefix; "Function of length "; obj.getsub().len()
	elseif t = "Function"
		print prefix; "Builtin Function"
	else
		' print t
		print obj
	end if
end sub
