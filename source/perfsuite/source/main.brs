sub Main()
	' Display a testing notice, then sleep to idle the canvas
	canvas = CreateObject("roImageCanvas")
	canvas.setLayer(0, [ { Color: "#000000" }
	                     { Text: "Testing ..."
	                       TextAttrs: { Font: "Huge" } } ])
	canvas.Show()
	sleep(1000)

	' Gather all tests (to be run in order)
	tests = GetTests()

	' Time them all in sequence
	empty = 0
	t = CreateObject("roTimespan")

	print "NAME", "COUNT", "TIME (s)", "AVE (us)"
	old_group = "empty"

	for each test in tests
		if test.doesExist("setup")
			params = test.setup()
		else
			params = {}
		end if
		t.mark()
		test.func(params)
		us = t.totalMilliseconds() * 1000 - test.outer * empty

		count = test.outer * test.inner
		ave   = us / count
		if test.name = "empty" then empty = ave

		group = test.group
		if group = invalid then group = ""
		if group <> old_group
			old_group = group
			print
		end if

		print test.Name, count, Str(us / 1e6), Str(ave)
	end for

	print
	print "Testing complete."
end sub

' Learned so far:
'
' * Unrolling the test loops doesn't make much difference -- MAYBE .1% worse
'   if anything, but that may just be amortization of error in removing the
'   empty loop overhead
' * Because for loop start/end/step are evaluated only once at loop start,
'   there is no appreciable cost to using a complex expression for each when
'   iteration count is large enough
' * Length of lexical variable name doesn't seem to impact performance
' * Boolean and invalid literals can be assigned slightly faster than int and
'   float literals; this difference goes away when assigning from untyped vars
' * Doubles (in any usage) are OMG SLOW -- 15-68x slower for simple tests
'   (1-2 orders of magnitude, essentially)
' * It is more expensive to create/destroy an empty [] than an empty {}
' * A method call with no arguments on some object is a few percent slower
'   than a function call whose only argument is that same object
' * Object attribute lookup (AA lookup with constant key using dot notation)
'   is VERY slow.  It is much faster (2x at 1 arg, 4x at 10) to call a function
'   to sum N separately passed integer args than to call a function to sum the
'   N integers in an object passed as a single argument.
' * The same applies (but not as strongly) to passing empty strings.
' * Passing discrete doubles however is even slower than passing an array or
'   object of the same number of doubles.
' * Array indexing to retrieve ints is a few percent faster than object
'   attribute lookup, but still very slow compared to discrete arguments.
' * Oddly, array indexing to retrieve strings or doubles is a few percent
'   *slower* than object attribute lookup.


function GetTests() As Object
	Return [
		{
		name:  "empty"
		group: "empty"
		outer: 1e7
		inner: 1
		func:  Function (params) As void
			For i = 1 to m.outer
			End For
		End Function
		}
		{
		name: "ass_inv_lit"
		outer: 1e7
		inner: 1
		func:  Function (params) As void
			For i = 1 to m.outer
				j = invalid
			End For
		End Function
		}
		{
		name: "ass_bool_lit"
		outer: 1e7
		inner: 1
		func:  Function (params) As void
			For i = 1 to m.outer
				j = true
			End For
		End Function
		}
		{
		name: "ass_int_lit"
		outer: 1e7
		inner: 1
		func:  Function (params) As void
			For i = 1 to m.outer
				j = 1
			End For
		End Function
		}
		{
		name: "ass_flt_lit"
		outer: 1e7
		inner: 1
		func:  Function (params) As void
			For i = 1 to m.outer
				j = 1.0
			End For
		End Function
		}
		{
		name: "ass_dbl_lit"
		outer: 1e5
		inner: 1
		func:  Function (params) As void
			For i = 1 to m.outer
				j = 1.0#
			End For
		End Function
		}
		{
		name: "ass_str_l0_lit"
		outer: 1e7
		inner: 1
		func:  Function (params) As void
			For i = 1 to m.outer
				j = ""
			End For
		End Function
		}
		{
		name: "ass_inv_var"
		outer: 1e7
		inner: 1
		func:  Function (params) As void
			k = invalid
			For i = 1 to m.outer
				j = k
			End For
		End Function
		}
		{
		name: "ass_bool_var"
		outer: 1e7
		inner: 1
		func:  Function (params) As void
			k = true
			For i = 1 to m.outer
				j = k
			End For
		End Function
		}
		{
		name: "ass_int_var"
		outer: 1e7
		inner: 1
		func:  Function (params) As void
			k = 1
			For i = 1 to m.outer
				j = k
			End For
		End Function
		}
		{
		name: "ass_flt_var"
		outer: 1e7
		inner: 1
		func:  Function (params) As void
			k = 1.0
			For i = 1 to m.outer
				j = k
			End For
		End Function
		}
		{
		name: "ass_dbl_var"
		outer: 1e6
		inner: 1
		func:  Function (params) As void
			k = 1.0#
			For i = 1 to m.outer
				j = k
			End For
		End Function
		}
		{
		name: "ass_str_l0_var"
		outer: 1e7
		inner: 1
		func:  Function (params) As void
			k = ""
			For i = 1 to m.outer
				j = k
			End For
		End Function
		}
		{
		name: "ass_inv_aa"
		outer: 5e4
		inner: 1
		func:  Function (params) As void
			aa = {}
			k = invalid
			For i = 1 to m.outer
				aa.var = k
			End For
		End Function
		}
		{
		name: "ass_inv_aa_l100"
		outer: 5e4
		inner: 1
		setup: Function () as object
			aa = {}
			for i = 1 to 100
				aa[i.toStr()] = i
			end for
			return { aa: aa }
		End Function
		func:  Function (params) As void
			aa = params.aa
			k = invalid
			For i = 1 to m.outer
				aa.var = k
			End For
		End Function
		}
		{
		name: "ass_inv_aa_l1e4"
		outer: 5e4
		inner: 1
		setup: Function () as object
			aa = {}
			for i = 1 to 1e4
				aa[i.toStr()] = i
			end for
			return { aa: aa }
		End Function
		func:  Function (params) As void
			aa = params.aa
			k = invalid
			For i = 1 to m.outer
				aa.var = k
			End For
		End Function
		}
		{
		name: "rd_inv_var"
		outer: 5e6
		inner: 1
		func:  Function (params) As void
			v = invalid
			For i = 1 to m.outer
				k = v
			End For
		End Function
		}
		{
		name: "rd_inv_aa"
		outer: 1e5
		inner: 1
		func:  Function (params) As void
			aa = { var: invalid }
			For i = 1 to m.outer
				k = aa.var
			End For
		End Function
		}
		{
		name: "rd_inv_aa_l100"
		outer: 1e5
		inner: 1
		setup: Function () as object
			aa = { var: invalid }
			for i = 1 to 100
				aa[i.toStr()] = i
			end for
			return { aa: aa }
		End Function
		func:  Function (params) As void
			aa = params.aa
			For i = 1 to m.outer
				k = aa.var
			End For
		End Function
		}
		{
		name: "rd_inv_aa_l1e3"
		outer: 5e4
		inner: 1
		setup: Function () as object
			aa = { var: invalid }
			for i = 1 to 1e3
				aa[i.toStr()] = i
			end for
			return { aa: aa }
		End Function
		func:  Function (params) As void
			aa = params.aa
			For i = 1 to m.outer
				k = aa.var
			End For
		End Function
		}
		{
		name: "rd_inv_aa_l1e4"
		outer: 5e3
		inner: 1
		setup: Function () as object
			aa = { var: invalid }
			for i = 1 to 1e4
				aa[i.toStr()] = i
			end for
			return { aa: aa }
		End Function
		func:  Function (params) As void
			aa = params.aa
			For i = 1 to m.outer
				k = aa.var
			End For
		End Function
		}
		{
		name: "ass_inv_ar"
		outer: 1e5
		inner: 1
		func:  Function (params) As void
			ar = []
			k = invalid
			For i = 1 to m.outer
				ar[0] = k
			End For
		End Function
		}
		{
		name: "ass_inv_ar_l100"
		outer: 1e5
		inner: 1
		setup: Function () as object
			ar = []
			for i = 1 to 100
				ar[i] = i
			end for
			return { ar: ar }
		End Function
		func:  Function (params) As void
			ar = params.ar
			k = invalid
			For i = 1 to m.outer
				ar[0] = k
			End For
		End Function
		}
		{
		name: "ass_inv_ar_l1e4"
		outer: 1e5
		inner: 1
		setup: Function () as object
			ar = []
			for i = 1 to 1e4
				ar[i] = i
			end for
			return { ar: ar }
		End Function
		func:  Function (params) As void
			ar = params.ar
			k = invalid
			For i = 1 to m.outer
				ar[0] = k
			End For
		End Function
		}
		{
		name: "rd_inv_ar"
		outer: 1e5
		inner: 1
		func:  Function (params) As void
			ar = []
			ar[0] = invalid
			For i = 1 to m.outer
				k = ar[0]
			End For
		End Function
		}
		{
		name: "rd_inv_ar_l100"
		outer: 1e5
		inner: 1
		setup: Function () as object
			ar = []
			for i = 1 to 100
				ar[i] = i
			end for
			ar[0] = invalid
			return { ar: ar }
		End Function
		func:  Function (params) As void
			ar = params.ar
			For i = 1 to m.outer
				k = ar[100 -1]
			End For
		End Function
		}
		{
		name: "rd_inv_ar_l1e3"
		outer: 1e5
		inner: 1
		setup: Function () as object
			ar = []
			for i = 1 to 1e3
				ar[i] = i
			end for
			ar[0] = invalid
			return { ar: ar }
		End Function
		func:  Function (params) As void
			ar = params.ar
			For i = 1 to m.outer
				k = ar[1000 - 1]
			End For
		End Function
		}

		{
		name: "rd_inv_ar_l1e4"
		outer: 1e5
		inner: 1
		setup: Function () as object
			ar = []
			for i = 1 to 1e4
				ar[i] = i
			end for
			ar[0] = invalid
			return { ar: ar }
		End Function
		func:  Function (params) As void
			ar = params.ar
			For i = 1 to m.outer
				k = ar[10000 - 1]
			End For
		End Function
		}
		{
		name: "ass_bool_aa"
		outer: 1e5
		inner: 1
		func:  Function (params) As void
			aa = {}
			k = true
			For i = 1 to m.outer
				aa.var = k
			End For
		End Function
		}
		{
		name: "ass_int_aa"
		outer: 1e5
		inner: 1
		func:  Function (params) As void
			aa = {}
			k = 1
			For i = 1 to m.outer
				aa.var = k
			End For
		End Function
		}
		{
		name: "ass_flt_aa"
		outer: 1e5
		inner: 1
		func:  Function (params) As void
			aa = {}
			k = 1.0
			For i = 1 to m.outer
				aa.var = k
			End For
		End Function
		}
		{
		name: "ass_dbl_aa"
		outer: 1e5
		inner: 1
		func:  Function (params) As void
			aa = {}
			k = 1.0#
			For i = 1 to m.outer
				aa.var = k
			End For
		End Function
		}
		{
		name: "ass_str_l0_aa"
		outer: 1e5
		inner: 1
		func:  Function (params) As void
			aa = {}
			k = ""
			For i = 1 to m.outer
				aa.var = k
			End For
		End Function
		}
		{
		name: "accum_int"
		outer: 1e6
		inner: 1
		func:  Function (params) As void
			j = 0
			For i = 1 to m.outer
				j = j + 1
			End For
		End Function
		}
		{
		name: "accum_flt"
		outer: 1e6
		inner: 1
		func:  Function (params) As void
			j = 0.0
			For i = 1 to m.outer
				j = j + 1.0
			End For
		End Function
		}
		{
		name: "accum_dbl"
		outer: 1e5
		inner: 1
		func:  Function (params) As void
			j = 0.0#
			For i = 1 to m.outer
				j = j + 1.0#
			End For
		End Function
		}
		{
		name: "accum_str_len0"
		outer: 1e5
		inner: 1
		func:  Function (params) As void
			j = ""
			For i = 1 to m.outer
				j = j + ""
			End For
		End Function
		}
		{
		name: "sum_int"
		outer: 1e6
		inner: 1
		func:  Function (params) As void
			j = 0
			For i = 1 to m.outer
				j = j + i
			End For
		End Function
		}
		{
		name: "sum_int_flt"
		outer: 1e6
		inner: 1
		func:  Function (params) As void
			j = 0.0
			For i = 1 to m.outer
				j = j + i
			End For
		End Function
		}
		{
		name: "sum_int_dbl"
		outer: 1e5
		inner: 1
		func:  Function (params) As void
			j = 0.0#
			For i = 1 to m.outer
				j = j + i
			End For
		End Function
		}
		{
		name: "func_v_v"
		outer: 1e5
		inner: 1
		func:  Function (params) As void
			z = Function () As Void : End Function
			For i = 1 to m.outer
				z()
			End For
		End Function
		}
		{
		name: "func_v_b"
		outer: 1e5
		inner: 1
		func:  Function (params) As void
			z = Function () As Boolean : Return True : End Function
			For i = 1 to m.outer
				z()
			End For
		End Function
		}
		{
		name: "func_v_i"
		outer: 1e5
		inner: 1
		func:  Function (params) As void
			z = Function () As Integer : Return 1 : End Function
			For i = 1 to m.outer
				z()
			End For
		End Function
		}
		{
		name: "func_v_f"
		outer: 1e5
		inner: 1
		func:  Function (params) As void
			z = Function () As float : Return 1.0 : End Function
			For i = 1 to m.outer
				z()
			End For
		End Function
		}
		{
		name: "func_v_d"
		outer: 1e5
		inner: 1
		func:  Function (params) As void
			z = Function () As Double : Return 1.0# : End Function
			For i = 1 to m.outer
				z()
			End For
		End Function
		}
		{
		name: "func_v_s"
		outer: 1e5
		inner: 1
		func:  Function (params) As void
			z = Function () As String : Return "" : End Function
			For i = 1 to m.outer
				z()
			End For
		End Function
		}
		{
		name: "func_v_a"
		outer: 1e5
		inner: 1
		func:  Function (params) As void
			z = Function () As Object : Return [] : End Function
			For i = 1 to m.outer
				z()
			End For
		End Function
		}
		{
		name: "func_v_o"
		outer: 1e5
		inner: 1
		func:  Function (params) As void
			z = Function () As Object : Return {} : End Function
			For i = 1 to m.outer
				z()
			End For
		End Function
		}
		{
		name: "func_b_v"
		outer: 1e5
		inner: 1
		func:  Function (params) As void
			z = Function (a As Boolean) As Void : End Function
			For i = 1 to m.outer
				z(true)
			End For
		End Function
		}
		{
		name: "func_b_b"
		outer: 1e5
		inner: 1
		func:  Function (params) As void
			z = Function (a As boolean) As Boolean : Return True : End Function
			For i = 1 to m.outer
				z(true)
			End For
		End Function
		}
		{
		name: "func_b_i"
		outer: 1e5
		inner: 1
		func:  Function (params) As void
			z = Function (a As boolean) As Integer : Return 1 : End Function
			For i = 1 to m.outer
				z(true)
			End For
		End Function
		}
		{
		name: "func_b_f"
		outer: 1e5
		inner: 1
		func:  Function (params) As void
			z = Function (a As boolean) As float : Return 1.0 : End Function
			For i = 1 to m.outer
				z(true)
			End For
		End Function
		}
		{
		name: "func_b_d"
		outer: 1e5
		inner: 1
		func:  Function (params) As void
			z = Function (a As boolean) As Double : Return 1.0# : End Function
			For i = 1 to m.outer
				z(true)
			End For
		End Function
		}
		{
		name: "func_b_s"
		outer: 1e5
		inner: 1
		func:  Function (params) As void
			z = Function (a As boolean) As String : Return "" : End Function
			For i = 1 to m.outer
				z(true)
			End For
		End Function
		}
		{
		name: "func_b_a"
		outer: 1e5
		inner: 1
		func:  Function (params) As void
			z = Function (a As boolean) As Object : Return [] : End Function
			For i = 1 to m.outer
				z(true)
			End For
		End Function
		}
		{
		name: "func_b_o"
		outer: 1e5
		inner: 1
		func:  Function (params) As void
			z = Function (a As boolean) As Object : Return {} : End Function
			For i = 1 to m.outer
				z(true)
			End For
		End Function
		}
		{
		name: "func_i_v"
		outer: 1e5
		inner: 1
		func:  Function (params) As void
			z = Function (a As integer) As Void : End Function
			For i = 1 to m.outer
				z(1)
			End For
		End Function
		}
		{
		name: "func_i_b"
		outer: 1e5
		inner: 1
		func:  Function (params) As void
			z = Function (a As integer) As Boolean : Return True : End Function
			For i = 1 to m.outer
				z(1)
			End For
		End Function
		}
		{
		name: "func_i_i"
		outer: 1e5
		inner: 1
		func:  Function (params) As void
			z = Function (a As integer) As Integer : Return 1 : End Function
			For i = 1 to m.outer
				z(1)
			End For
		End Function
		}
		{
		name: "func_i_f"
		outer: 1e5
		inner: 1
		func:  Function (params) As void
			z = Function (a As integer) As float : Return 1.0 : End Function
			For i = 1 to m.outer
				z(1)
			End For
		End Function
		}
		{
		name: "func_i_d"
		outer: 1e5
		inner: 1
		func:  Function (params) As void
			z = Function (a As integer) As Double : Return 1.0# : End Function
			For i = 1 to m.outer
				z(1)
			End For
		End Function
		}
		{
		name: "func_i_s"
		outer: 1e5
		inner: 1
		func:  Function (params) As void
			z = Function (a As integer) As String : Return "" : End Function
			For i = 1 to m.outer
				z(1)
			End For
		End Function
		}
		{
		name: "func_i_a"
		outer: 1e5
		inner: 1
		func:  Function (params) As void
			z = Function (a As integer) As Object : Return [] : End Function
			For i = 1 to m.outer
				z(1)
			End For
		End Function
		}
		{
		name: "func_i_o"
		outer: 1e5
		inner: 1
		func:  Function (params) As void
			z = Function (a As integer) As Object : Return {} : End Function
			For i = 1 to m.outer
				z(1)
			End For
		End Function
		}
		{
		name: "func_v_v_r"
		outer: 1e5
		inner: 1
		func:  Function (params) As void
			z = Function () As Void : End Function
			For i = 1 to m.outer
				z()
			End For
		End Function
		}
		{
		name: "func_b_b_r"
		outer: 1e5
		inner: 1
		func:  Function (params) As void
			z = Function (a As boolean) As Boolean : Return a : End Function
			For i = 1 to m.outer
				z(true)
			End For
		End Function
		}
		{
		name: "func_i_i_r"
		outer: 1e5
		inner: 1
		func:  Function (params) As void
			z = Function (a As integer) As Integer : Return a : End Function
			For i = 1 to m.outer
				z(1)
			End For
		End Function
		}
		{
		name: "func_f_f_r"
		outer: 1e5
		inner: 1
		func:  Function (params) As void
			z = Function (a As float) As float : Return a : End Function
			For i = 1 to m.outer
				z(1.0)
			End For
		End Function
		}
		{
		name: "func_d_d_r"
		outer: 1e5
		inner: 1
		func:  Function (params) As void
			z = Function (a As double) As Double : Return a : End Function
			For i = 1 to m.outer
				z(1.0#)
			End For
		End Function
		}
		{
		name: "func_s_s_r"
		outer: 1e5
		inner: 1
		func:  Function (params) As void
			z = Function (a As string) As String : Return a : End Function
			For i = 1 to m.outer
				z("")
			End For
		End Function
		}
		{
		name: "func_a_a_r"
		outer: 1e5
		inner: 1
		func:  Function (params) As void
			z = Function (a As object) As Object : Return a : End Function
			For i = 1 to m.outer
				z([])
			End For
		End Function
		}
		{
		name: "func_o_o_r"
		outer: 1e5
		inner: 1
		func:  Function (params) As void
			z = Function (a As object) As Object : Return a : End Function
			For i = 1 to m.outer
				z({})
			End For
		End Function
		}
		{
		name:  "func_v_v"
		group: "call_v_v"
		outer: 1e5
		inner: 1
		func:  Function (params) As void
		        o = {}
			z = Function () As Void : End Function
			For i = 1 to m.outer
				z()
			End For
		End Function
		}
		{
		name:  "func_o_v"
		group: "call_v_v"
		outer: 1e5
		inner: 1
		func:  Function (params) As void
		        o = {}
			z = Function (a As object) As Void : End Function
			For i = 1 to m.outer
				z(o)
			End For
		End Function
		}
		{
		name:  "meth_v_v"
		group: "call_v_v"
		outer: 1e5
		inner: 1
		func:  Function (params) As void
		        o = {}
			o.z = Function () As Void : End Function
			For i = 1 to m.outer
				o.z()
			End For
		End Function
		}
		{
		name:  "func_i_v"
		group: "call_i_v"
		outer: 1e5
		inner: 1
		func:  Function (params) As void
		        o = { b : 1 }
			z = Function (a As integer) As Void : End Function
			For i = 1 to m.outer
				z(1)
			End For
		End Function
		}
		{
		name:  "func_o(i)_v"
		group: "call_i_v"
		outer: 1e5
		inner: 1
		func:  Function (params) As void
		        o = { b : 1 }
			z = Function (a As object) As Void : End Function
			For i = 1 to m.outer
				z(o)
			End For
		End Function
		}
		{
		name:  "meth_v(i)_v"
		group: "call_i_v"
		outer: 1e5
		inner: 1
		func:  Function (params) As void
		        o = { b : 1 }
			o.z = Function () As Void : End Function
			For i = 1 to m.outer
				o.z()
			End For
		End Function
		}
		{
		name:  "func_i_i"
		group: "call_i_i"
		outer: 1e5
		inner: 1
		func:  Function (params) As void
		        o = { b : 1 }
			z = Function (a As integer) As Integer : Return a : End Function
			For i = 1 to m.outer
				z(1)
			End For
		End Function
		}
		{
		name:  "func_o(i)_i"
		group: "call_i_i"
		outer: 1e5
		inner: 1
		func:  Function (params) As void
		        o = { b : 1 }
			z = Function (a As object) As Integer : Return a.b : End Function
			For i = 1 to m.outer
				z(o)
			End For
		End Function
		}
		{
		name:  "meth_v(i)_i"
		group: "call_i_i"
		outer: 1e5
		inner: 1
		func:  Function (params) As void
		        o = { b : 1 }
			o.z = Function () As Integer : Return m.b : End Function
			For i = 1 to m.outer
				o.z()
			End For
		End Function
		}
		{
		name:  "func_ii_v"
		group: "call_ii_v"
		outer: 1e5
		inner: 1
		func:  Function (params) As void
		        o = { b : 1, c : 2 }
			z = Function (a As Integer, d As Integer) As Void : End Function
			For i = 1 to m.outer
				z(1, 2)
			End For
		End Function
		}
		{
		name:  "func_o(ii)_v"
		group: "call_ii_v"
		outer: 1e5
		inner: 1
		func:  Function (params) As void
		        o = { b : 1, c : 2 }
			z = Function (a As Object) As Void : End Function
			For i = 1 to m.outer
				z(o)
			End For
		End Function
		}
		{
		name:  "meth_v(ii)_v"
		group: "call_ii_v"
		outer: 1e5
		inner: 1
		func:  Function (params) As void
		        o = { b : 1, c : 2 }
			o.z = Function () As Void : End Function
			For i = 1 to m.outer
				o.z()
			End For
		End Function
		}
		{
		name:  "func_ii_i_fk"
		group: "call_ii_i_fk"
		outer: 1e5
		inner: 1
		func:  Function (params) As void
		        o = { b : 1, c : 2 }
			z = Function (a As Integer, d As Integer) As Integer : Return 3 + 4 : End Function
			For i = 1 to m.outer
				z(1, 2)
			End For
		End Function
		}
		{
		name:  "func_o(ii)_i_fk"
		group: "call_ii_i_fk"
		outer: 1e5
		inner: 1
		func:  Function (params) As void
		        o = { b : 1, c : 2 }
			z = Function (a As Object) As Integer : Return 3 + 4 : End Function
			For i = 1 to m.outer
				z(o)
			End For
		End Function
		}
		{
		name:  "meth_v(ii)_i_fk"
		group: "call_ii_i_fk"
		outer: 1e5
		inner: 1
		func:  Function (params) As void
		        o = { b : 1, c : 2 }
			o.z = Function () As Integer : Return 3 + 4 : End Function
			For i = 1 to m.outer
				o.z()
			End For
		End Function
		}
		{
		name:  "func_ii_i"
		group: "call_ii_i"
		outer: 1e5
		inner: 1
		func:  Function (params) As void
		        o = { b : 1, c : 2 }
			z = Function (a As Integer, d As Integer) As Integer : Return a + d : End Function
			For i = 1 to m.outer
				z(1, 2)
			End For
		End Function
		}
		{
		name:  "func_a(ii)_i"
		group: "call_ii_i"
		outer: 1e5
		inner: 1
		func:  Function (params) As void
		        o = [ 1, 2 ]
			z = Function (a As Object) As Integer : Return a[0] + a[1] : End Function
			For i = 1 to m.outer
				z(o)
			End For
		End Function
		}
		{
		name:  "func_o(ii)_i"
		group: "call_ii_i"
		outer: 1e5
		inner: 1
		func:  Function (params) As void
		        o = { b : 1, c : 2 }
			z = Function (a As Object) As Integer : Return a.b + a.c : End Function
			For i = 1 to m.outer
				z(o)
			End For
		End Function
		}
		{
		name:  "meth_v(ii)_i"
		group: "call_ii_i"
		outer: 1e5
		inner: 1
		func:  Function (params) As void
		        o = { b : 1, c : 2 }
			o.z = Function () As Integer : Return m.b + m.c : End Function
			For i = 1 to m.outer
				o.z()
			End For
		End Function
		}
		{
		name:  "func_iiiiiiiiii_i_fk"
		group: "call_iiiiiiiiii_i_fk"
		outer: 1e5
		inner: 1
		func:  Function (params) As void
		        o = { a:1, b:2, c:3, d:4, e:5, f:6, g:7, h:8, i:9, j:10  }
			z = Function (a As Integer, b As Integer, c As Integer, d As Integer, e As Integer, f As Integer, g As Integer, h As Integer, i As Integer, j As Integer) As Integer : Return 1 + 2 + 3 + 4 + 5 + 6 + 7 + 8 + 9 + 10 : End Function
			For i = 1 to m.outer
				z(1, 2, 3, 4, 5, 6, 7, 8, 9, 10)
			End For
		End Function
		}
		{
		name:  "func_a(iiiiiiiiii)_i_fk"
		group: "call_iiiiiiiiii_i_fk"
		outer: 1e5
		inner: 1
		func:  Function (params) As void
		        o = [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ]
			z = Function (a As Object) As Integer : Return 1 + 2 + 3 + 4 + 5 + 6 + 7 + 8 + 9 + 10 : End Function
			For i = 1 to m.outer
				z(o)
			End For
		End Function
		}
		{
		name:  "func_o(iiiiiiiiii)_i_fk"
		group: "call_iiiiiiiiii_i_fk"
		outer: 1e5
		inner: 1
		func:  Function (params) As void
		        o = { a:1, b:2, c:3, d:4, e:5, f:6, g:7, h:8, i:9, j:10  }
			z = Function (a As Object) As Integer : Return 1 + 2 + 3 + 4 + 5 + 6 + 7 + 8 + 9 + 10 : End Function
			For i = 1 to m.outer
				z(o)
			End For
		End Function
		}
		{
		name:  "meth_v(iiiiiiiiii)_i_fk"
		group: "call_iiiiiiiiii_i_fk"
		outer: 1e5
		inner: 1
		func:  Function (params) As void
		        o = { a:1, b:2, c:3, d:4, e:5, f:6, g:7, h:8, i:9, j:10  }
			o.z = Function () As Integer : Return 1 + 2 + 3 + 4 + 5 + 6 + 7 + 8 + 9 + 10 : End Function
			For i = 1 to m.outer
				o.z()
			End For
		End Function
		}
		{
		name:  "func_iiiiiiiiii_i"
		group: "call_iiiiiiiiii_i"
		outer: 1e5
		inner: 1
		func:  Function (params) As void
		        o = { a:1, b:2, c:3, d:4, e:5, f:6, g:7, h:8, i:9, j:10  }
			z = Function (a As Integer, b As Integer, c As Integer, d As Integer, e As Integer, f As Integer, g As Integer, h As Integer, i As Integer, j As Integer) As Integer : Return a + b + c + d + e + f + g + h + i + j : End Function
			For i = 1 to m.outer
				z(1, 2, 3, 4, 5, 6, 7, 8, 9, 10)
			End For
		End Function
		}
		{
		name:  "func_a(iiiiiiiiii)_i"
		group: "call_iiiiiiiiii_i"
		outer: 1e4
		inner: 1
		func:  Function (params) As void
		        o = [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ]
			z = Function (a As Object) As Integer : Return a[0] + a[1] + a[2] + a[3] + a[4] + a[5] + a[6] + a[7] + a[8] + a[9] : End Function
			For i = 1 to m.outer
				z(o)
			End For
		End Function
		}
		{
		name:  "func_o(iiiiiiiiii)_i"
		group: "call_iiiiiiiiii_i"
		outer: 1e4
		inner: 1
		func:  Function (params) As void
		        o = { a:1, b:2, c:3, d:4, e:5, f:6, g:7, h:8, i:9, j:10  }
			z = Function (a As Object) As Integer : Return a.a + a.b + a.c + a.d + a.e + a.f + a.g + a.h + a.i + a.j : End Function
			For i = 1 to m.outer
				z(o)
			End For
		End Function
		}
		{
		name:  "meth_v(iiiiiiiiii)_i"
		group: "call_iiiiiiiiii_i"
		outer: 1e4
		inner: 1
		func:  Function (params) As void
		        o = { a:1, b:2, c:3, d:4, e:5, f:6, g:7, h:8, i:9, j:10  }
			o.z = Function () As Integer : Return m.a + m.b + m.c + m.d + m.e + m.f + m.g + m.h + m.i + m.j : End Function
			For i = 1 to m.outer
				o.z()
			End For
		End Function
		}
		{
		name:  "func_ssssssssss_s"
		group: "call_ssssssssss_s"
		outer: 1e4
		inner: 1
		func:  Function (params) As void
		        o = { a:"", b:"", c:"", d:"", e:"", f:"", g:"", h:"", i:"", j:"" }
			z = Function (a As String, b As String, c As String, d As String, e As String, f As String, g As String, h As String, i As String, j As String) As String : Return a + b + c + d + e + f + g + h + i + j : End Function
			For i = 1 to m.outer
				z("", "", "", "", "", "", "", "", "", "")
			End For
		End Function
		}
		{
		name:  "func_a(ssssssssss)_s"
		group: "call_ssssssssss_s"
		outer: 1e4
		inner: 1
		func:  Function (params) As void
			o = [ "", "", "", "", "", "", "", "", "", "" ]
			z = Function (a As Object) As String : Return a[0] + a[1] + a[2] + a[3] + a[4] + a[5] + a[6] + a[7] + a[8] + a[9] : End Function
			For i = 1 to m.outer
				z(o)
			End For
		End Function
		}
		{
		name:  "func_o(ssssssssss)_s"
		group: "call_ssssssssss_s"
		outer: 1e4
		inner: 1
		func:  Function (params) As void
		        o = { a:"", b:"", c:"", d:"", e:"", f:"", g:"", h:"", i:"", j:"" }
			z = Function (a As Object) As String : Return a.a + a.b + a.c + a.d + a.e + a.f + a.g + a.h + a.i + a.j : End Function
			For i = 1 to m.outer
				z(o)
			End For
		End Function
		}
		{
		name:  "meth_v(ssssssssss)_s"
		group: "call_ssssssssss_s"
		outer: 1e4
		inner: 1
		func:  Function (params) As void
		        o = { a:"", b:"", c:"", d:"", e:"", f:"", g:"", h:"", i:"", j:"" }
			o.z = Function () As String : Return m.a + m.b + m.c + m.d + m.e + m.f + m.g + m.h + m.i + m.j : End Function
			For i = 1 to m.outer
				o.z()
			End For
		End Function
		}
		{
		name:  "func_dddddddddd_d"
		group: "call_dddddddddd_d"
		outer: 1e4
		inner: 1
		func:  Function (params) As void
		        o = { a:1.0#, b:2.0#, c:3.0#, d:4.0#, e:5.0#, f:6.0#, g:7.0#, h:8.0#, i:9.0#, j:10.0# }
			z = Function (a As Double, b As Double, c As Double, d As Double, e As Double, f As Double, g As Double, h As Double, i As Double, j As Double) As Double : Return a + b + c + d + e + f + g + h + i + j : End Function
			For i = 1 to m.outer
				z(1, 2, 3, 4, 5, 6, 7, 8, 9, 10)
			End For
		End Function
		}
		{
		name:  "func_a(dddddddddd)_d"
		group: "call_dddddddddd_d"
		outer: 1e4
		inner: 1
		func:  Function (params) As void
		        o = [ 1.0#, 2.0#, 3.0#, 4.0#, 5.0#, 6.0#, 7.0#, 8.0#, 9.0#, 10.0# ]
			z = Function (a As Object) As Double : Return a[0] + a[1] + a[2] + a[3] + a[4] + a[5] + a[6] + a[7] + a[8] + a[9] : End Function
			For i = 1 to m.outer
				z(o)
			End For
		End Function
		}
		{
		name:  "func_o(dddddddddd)_d"
		group: "call_dddddddddd_d"
		outer: 1e4
		inner: 1
		func:  Function (params) As void
		        o = { a:1.0#, b:2.0#, c:3.0#, d:4.0#, e:5.0#, f:6.0#, g:7.0#, h:8.0#, i:9.0#, j:10.0# }
			z = Function (a As Object) As Double : Return a.a + a.b + a.c + a.d + a.e + a.f + a.g + a.h + a.i + a.j : End Function
			For i = 1 to m.outer
				z(o)
			End For
		End Function
		}
		{
		name:  "meth_v(dddddddddd)_d"
		group: "call_dddddddddd_d"
		outer: 1e4
		inner: 1
		func:  Function (params) As void
		        o = { a:1.0#, b:2.0#, c:3.0#, d:4.0#, e:5.0#, f:6.0#, g:7.0#, h:8.0#, i:9.0#, j:10.0# }
			o.z = Function () As Double : Return m.a + m.b + m.c + m.d + m.e + m.f + m.g + m.h + m.i + m.j : End Function
			For i = 1 to m.outer
				o.z()
			End For
		End Function
		}
		{
		name:  "sum_iiiiiiiiii_i_ass_fk"
		group: "call_iiiiiiiiii_i_ass"
		outer: 1e5
		inner: 1
		func:  Function (params) As void
		        o = { a:1, b:2, c:3, d:4, e:5, f:6, g:7, h:8, i:9, j:10  }
			z = Function (a As Integer, b As Integer, c As Integer, d As Integer, e As Integer, f As Integer, g As Integer, h As Integer, i As Integer, j As Integer) As Integer : Return a + b + c + d + e + f + g + h + i + j : End Function
			For i = 1 to m.outer
				y = 1 + 2 + 3 + 4 + 5 + 6 + 7 + 8 + 9 + 10
			End For
		End Function
		}
		{
		name:  "sum_iiiiiiiiii_i_ass"
		group: "call_iiiiiiiiii_i_ass"
		outer: 1e5
		inner: 1
		func:  Function (params) As void
		        o = { a:1, b:2, c:3, d:4, e:5, f:6, g:7, h:8, i:9, j:10  }
			z = Function (a As Integer, b As Integer, c As Integer, d As Integer, e As Integer, f As Integer, g As Integer, h As Integer, i As Integer, j As Integer) As Integer : Return a + b + c + d + e + f + g + h + i + j : End Function
			a=1:b=2:c=3:d=4:e=5:f=6:g=7:h=8:i=9:j=10
			For i = 1 to m.outer
				y = a + b + c + d + e + f + g + h + i + j
			End For
		End Function
		}
		{
		name:  "func_iiiiiiiiii_i_ass"
		group: "call_iiiiiiiiii_i_ass"
		outer: 1e5
		inner: 1
		func:  Function (params) As void
		        o = { a:1, b:2, c:3, d:4, e:5, f:6, g:7, h:8, i:9, j:10  }
			z = Function (a As Integer, b As Integer, c As Integer, d As Integer, e As Integer, f As Integer, g As Integer, h As Integer, i As Integer, j As Integer) As Integer : Return a + b + c + d + e + f + g + h + i + j : End Function
			For i = 1 to m.outer
				y = z(1, 2, 3, 4, 5, 6, 7, 8, 9, 10)
			End For
		End Function
		}
		{
		name:  "global_func_getglobalaa"
		group: "global_access"
		outer: 1e5
		inner: 1
		func: function (params) as void
			for i=1 to m.outer
				gaa = getglobalaa()
			end for
		end function
		}
		{
		name:  "global_manual_globalobj"
		group: "global_access"
		outer: 1e5
		inner: 1
		func: function (params) as void
			globalobj_init = function()
				if not m.doesExist("myglobal") or type(box(m.myglobal)) <> "roAssociativeArray" then m.myglobal = {}
			end function
			globalobj = function()
				return m.myglobal
			end function

			globalobj_init()
			for i=1 to m.outer
				gaa = globalobj()
			end for
		end function
		}
		{
		name:  "global_func_getglobalaa_assign"
		group: "global_access"
		outer: 1e5
		inner: 1
		func: function (params) as void
			
			g1 = getglobalaa()
			g1.test = 123
			g1.test2 = 456
			g1.test3 = 789
			g2 = getglobalaa()
			if g2.test <> 123 then stop

			for i=1 to m.outer
				gaa = getglobalaa()
				test = gaa.test+gaa.test2+gaa.test3
			end for
		end function
		}
		{
		name:  "global_manual_globalobj_assign"
		group: "global_access"
		outer: 1e5
		inner: 1
		func: function (params) as void
			globalobj_init = function()
				if not m.doesExist("myglobal") or type(box(m.myglobal)) <> "roAssociativeArray" then m.myglobal = {}
			end function
			globalobj = function()
				return m.myglobal
			end function

			globalobj_init()
			g1 = globalobj()
			g1.test = 123
			g1.test2 = 456
			g1.test3 = 789
			g2 = globalobj()
			if g2.test <> 123 then stop

			for i=1 to m.outer
				gaa = globalobj()
				test = gaa.test+gaa.test2+gaa.test3
			end for
		end function
		}
	]
End Function
