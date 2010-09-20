' *********************************************************************
' * libRokuDev, Function Programming Operations                       *
' *                                                                   *
' * Copyright 2010, GandK Labs.  This library is free software; see   *
' * the LICENSE file in the libRokuDev distribution for more details. *
' *********************************************************************

' *************************************************************
' * Apply a function to each element in an array, collecting  *
' * the function's return values as a new array.  Applied to  *
' * an associative array, passes and expects key/value pairs. *
' * Normally tries to return same data structure (array or    *
' * associative array) given as input, but can be forced to   *
' * return only a normal array using force_array.             *
' *************************************************************
Function rdMap(f as Object, in_array as Object, force_array = false) as Object
	if GetInterface(in_array, "ifAssociativeArray") <> invalid
		if force_array
			out_array = []

			for each k in in_array
				out_array.push(f(k, in_array[k]))
			end for
		else 
			out_array = {}

			for each k in in_array
				result = f(k, in_array[k])
				out_array[result[0]] = result[1]
			end for
		end if
	else
		out_array = []

		for each v in in_array
			out_array.push(f(v))
		end for
	end if

	return out_array
End Function

' *********************************************************************
' * Call a function needing discrete arguments with an array instead. *
' *********************************************************************
Function rdApply(f as Object, args as Object) as Dynamic
	arity = args.count()

	if m.doesExist("_rdFunctional") and m._rdFunctional.doesExist("_apply_helpers")
		helper  = m._rdFunctional._apply_helpers[arity]
	else
		m._rdFunctional = { _apply_helpers: [] }
		helper  = invalid
	end if

	if  helper = invalid
		helper = _rdMakeApplyHelper(arity)
		m._rdFunctional._apply_helpers[arity] = helper
	end if

	return helper(f, args)
End Function

Function _rdMakeApplyHelper(arity as Integer) as Object
	code = "helper = Function (f as Object, args as Object) as Dynamic : return f("
	for i = 0 to arity - 1
		code = code + "args[" + i.toStr() + "]"
		if i <> arity - 1
			code = code + ", "
		end if
	end for
	code = code + ") : End Function"

	' print "apply helper for arity"; arity ": " code
	eval(code)

	return helper
End Function
