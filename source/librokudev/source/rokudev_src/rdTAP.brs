' *********************************************************************
' * libRokuDev, TAP Testing Library and Harness                       *
' *                                                                   *
' * Copyright 2010, GandK Labs.  This library is free software; see   *
' * the LICENSE file in the libRokuDev distribution for more details. *
' *********************************************************************

' **************************************************************************
' * Harness: Run several test groups, summarizing the TAP output from each *
' **************************************************************************
function rdTAPHarness (options = {} as object) as object
	this = {
		' Private attributes
		_raw_results  : []
		_summaries    : []
		_full_summary : {}
		_options      : options


		' Regex cache
		_regex : {
							   '	1    2		3	      4	     5
			plan	 : CreateObject("roRegex", "^1..(\d+)((?:\s+#\s+(skip|todo)\S*((?:\s+(.*))))?)$", "i")
							   '	1	       2      3	      4	     5	       6	  7		8      9
			test	 : CreateObject("roRegex", "^\s*((?:not\s+)?)ok((?:\s+(\d+))?)((?:\s+([^#]+))?)((?:\s*#\s*(skip|todo)\S*((?:\s+(.*))))?)$", "i")
							   '		1      2
			bail_out : CreateObject("roRegex", "^\s*Bail out((?:\W+(.*))?)", "i")
							   '	 1	2
			comment	 : CreateObject("roRegex", "^\s*#((?:\s*(.*))?)", "i")
		}


		' Accessors
		get_options : function () as object
			return m._options
		end function

		set_options : function (options as object)
			for each option in options
				m._options[option] = options[option]
			end for
		end function


		' Testing methods
		run_tests : function (tests = [] as object)
			for each test in tests
				tap = rdTapTests()
				tap.set_output_method("array")
				if m._options.doesExist("extra_test_args")
					test(tap, m._options.extra_test_args)
				else
					test(tap)
				end if
				output = tap.output_array()
				m._raw_results.push(output)
				m._summaries.push(m._summarize(output))
			end for
		end function


		' Summarizing functions
		_summarize : function (output as object)
			summary = {
				planned : 0
				ran	: 0
				passed	: 0
				failed	: 0
				dubious : 0
			}
			plan_seen = false

			for each tap_line in output
				if     m._regex.plan.IsMatch(tap_line)
					match = m._regex.plan.Match(tap_line)
					if plan_seen
						summary.dubious = summary.dubious + 1
					else
						summary.planned = match[1].toInt()
						plan_seen	= true
					end if
				elseif m._regex.test.IsMatch(tap_line)
					match = m._regex.test.Match(tap_line)

					summary.ran = summary.ran + 1
					if match[2] <> invalid and len(match[2]) > 0 and match[3].toInt() <> summary.ran
						summary.dubious = summary.dubious + 1
					end if

					if match[1] <> invalid and len(match[1]) > 0
						summary.failed = summary.failed + 1
					else
						summary.passed = summary.passed + 1
					end if
				else
					summary.dubious = summary.dubious + 1
				end if
			end for

			if summary.planned <> summary.ran
				summary.dubious = summary.dubious + 1
			end if

			return summary
		end function

		_summarize_summaries : function ()
			full_summary = {
				groups	: m._summaries.count()
				planned : 0
				ran	: 0
				passed	: 0
				failed	: 0
				dubious : 0
			}

			for each summary in m._summaries
				for each subtotal in summary
					full_summary[subtotal] = full_summary[subtotal] + summary[subtotal]
				end for
			end for

			return full_summary
		end function

		show_summary : function ()
			m._full_summary = m._summarize_summaries()

			for i = 1 to m._summaries.count()
				summary = m._summaries[i - 1]
				print "Test Group " + i.toStr() + ":"

				if m._options.doesExist("verbose") and m._options.verbose
					raw = m._raw_results[i - 1]
					for each tap_line in raw
						print "	   " + tap_line
					end for
					print "----"
				end if

				for each total in summary
					print "	   " + total + ": " + summary[total].toStr()
				end for

				print ""
			end for

			print "TOTAL:"
			for each total in m._full_summary
				print "	   " + total + ": " + m._full_summary[total].toStr()
			end for
		end function
	}

	return this
end function


' *****************************************************************************
' * Run a single group of individual tests, with choice of TAP output methods *
' *****************************************************************************
function rdTAPTests (num_tests = invalid) as object
	this = {
		' Private attributes
		_num_tests     : 0
		_cur_test      : 0
		_plan_output   : false
		_output_array  : []
		_output_buffer : ""


		' Output methods
		' m._via_*() are assigned to m._output() using
		' m.set_output_method().  Default is m._via_print().
		_via_print  : function (l as string) : print l				       : end function
		_via_array  : function (l as string) : m._output_array.push(l)		       : end function
		_via_buffer : function (l as string) : m._output_buffer = m._output_buffer + l : end function

		set_output_method : function (output_method)
			method_type = type(box(output_method))
			if     method_type = "roFunction"
				m._output = output_method
			elseif method_type = "roString"
				if     output_method = "print"
					m._output = m._via_print
				elseif output_method = "array"
					m._output = m._via_array
				elseif output_method = "buffer"
					m._output = m._via_buffer
				else
					m.ok(false, "set_output_method() called with invalid method '" + output_method + "'")
				end if
			else
				m.ok(false, "set_output_method() called with invalid method type '" + method_type + "'; must be function or string")
			end if
		end function

		' Accessors for output array/buffer
		output_array : function (new_array = invalid as dynamic) as object
			old_array = m._output_array
			if new_array <> invalid m._output_array = new_array
			return old_array
		end function

		output_buffer : function (new_buffer = invalid as dynamic) as string
			old_buffer = m._output_buffer
			if new_buffer <> invalid m._output_buffer = new_buffer
			return old_buffer
		end function


		' Planning methods
		_output_plan : function ()
			if not	m._plan_output
				m._plan_output = true
				m._output("1.." + m._num_tests.toStr())
			end if
		end function

		plan : function (tests as integer)
			if m._num_tests <> 0
				m.ok(false, "plan() called when test plan already set")
			else
				m._num_tests = tests
			end if

			m._output_plan()
		end function

		done_testing : function (tests = invalid)
			if tests = invalid then tests = m._cur_test

			if m._num_tests <> 0 and m._num_tests <> tests
				m.ok(false, "test count mismatch: planned to run " + m._num_tests.toStr() + ", but done_testing() expects " + tests.toStr())
			else
				m._num_tests = tests
			end if

			m._output_plan()
		end function


		' Test methods
		ok : function (is_ok as boolean, reason = "" as string)
			if is_ok line_to_output = "" else line_to_output = "not "

			m._cur_test = m._cur_test + 1
			line_to_output = line_to_output + "ok " + m._cur_test.toStr()

			if len(reason) > 0 line_to_output = line_to_output + " - " + reason

			m._output(line_to_output)
		end function

		pass : function (reason = "" as string)
			m.ok(true, reason)
		end function

		fail : function (reason = "" as string)
			m.ok(false, reason)
		end function

		is : function (got as dynamic, expected as dynamic, reason = "" as string)
			is_ok = type(box(got)) = type(box(expected)) and got = expected

			m.ok(is_ok, reason)
		end function

		isnt : function (got as dynamic, expected as dynamic, reason = "" as string)
			is_ok = type(box(got)) <> type(box(expected)) or got <> expected

			m.ok(is_ok, reason)
		end function

		like : function (got as string, expected as dynamic, reason = "" as string)
			if type(expected) <> "roRegex" then expected = CreateObject("roRegex", expected, "")

			is_ok = expected.IsMatch(got)

			m.ok(is_ok, reason)
		end function

		unlike : function (got as string, expected as dynamic, reason = "" as string)
			if type(expected) <> "roRegex" then expected = CreateObject("roRegex", expected, "")

			is_ok = not expected.IsMatch(got)

			m.ok(is_ok, reason)
		end function

		cmp_ok : function (got as dynamic, op as string, expected as dynamic, reason = "" as string)
			eval("is_ok = got " + op + " expected")

			m.ok(is_ok, reason)
		end function

		isa_ok : function (thing as dynamic, expected_type as string, reason = "" as string)
			is_ok = type(thing) = expected_type or type(box(thing)) = expected_type

			m.ok(is_ok, reason)
		end function

		nota_ok : function (thing as dynamic, expected_type as string, reason = "" as string)
			is_ok = not(type(thing) = expected_type or type(box(thing)) = expected_type)

			m.ok(is_ok, reason)
		end function

		can_ok : function (object as object, method as string, reason = "" as string)
			is_ok = object.doesExist(method) and type(object[method]) = "roFunction"

			m.ok(is_ok, reason)
		end function

		cant_ok : function (object as object, method as string, reason = "" as string)
			is_ok = not(object.doesExist(method) and type(object[method]) = "roFunction")

			m.ok(is_ok, reason)
		end function

		has_ok : function (object as object, attribute as string, reason = "" as string)
			is_ok = object.doesExist(attribute) and type(object[attribute]) <> "roFunction"

			m.ok(is_ok, reason)
		end function

		hasnt_ok : function (object as object, attribute as string, reason = "" as string)
			is_ok = not(object.doesExist(attribute) and type(object[attribute]) <> "roFunction")

			m.ok(is_ok, reason)
		end function
	}


	' Dynamic init
	this.set_output_method("print")

	if num_tests <> invalid this.plan(num_tests)

	return this
end function
