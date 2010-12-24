' *********************************************************************
' * libRokuDev, Test Library for rdClass.brs                          *
' *                                                                   *
' * Copyright 2010, GandK Labs.  This library is free software; see   *
' * the LICENSE file in the libRokuDev distribution for more details. *
' *********************************************************************

' ******************************************************************************
' * Main entry point for testing rdClass; currently all output goes to console *
' ******************************************************************************
sub test_rdClass()

	' Test implementation correctness
	harness = rdTAPHarness({verbose:1})
	harness.run_tests([
		test_rdClass_attributes
		test_rdClass_methods
		test_rdClass_inheritance
		test_rdClass_coersion
	])
	harness.show_summary()

	print ""
	print "Benchmarking:"
	print ""
	' Test instantiation time
	iterations = 1000
	timer = CreateObject("roTimespan")

	print "Test time to create objects"

	print "  rdClass: ";
	timer.mark()
	for i=1 to iterations
		p = make_point()
	end for
	timespan = timer.totalMilliseconds()
	print timespan;"ms"

	print "  Manual Optimized: ";
	timer.mark()
	for i=1 to iterations
		p = manual_point()
	end for
	timespan = timer.totalMilliseconds()
	print timespan;"ms"

	print "  Manual Inline: ";
	timer.mark()
	for i=1 to iterations
		p = manual_point2()
	end for
	timespan = timer.totalMilliseconds()
	print timespan;"ms"

end sub

't.plan(iPlan)
't.ok(true)
't.pass()
't.fail()
't.is(val2, val2)
't.isnt(val1, val2
't.like("this", "regex")
't.unlike("this", "regex")
't.has_ok(object, "attribute")
't.can_ok(object, "method")

' *************************
' * Test class attributes *
' *************************
sub test_rdClass_attributes(t)
	point = make_point()
	pMeta = make_pointMeta()

	''' Class attributes '''
	t.has_ok(point, "_CLASSNAME",        "Classname exists")
	t.has_ok(point, "_spec",             "Class spec exists")
	t.has_ok(point, "_data",             "Data storage exists")
	t.has_ok(point, "_prototype",        "Prototype object exists")
	t.is(point._CLASSNAME, "Point",      "Classname set")
	' x
	t.can_ok(point, "x",                 "Accessor callable (x)")
	t.is(point.x(), 123,                 "Default value set on creation (x)")
	t.ok(point.x(1),                     "Accessor write (x)")
	t.is(point.x(), 1,                   "Accessor read (x)")
	t.isa_ok(point.x(), "roInt",         "Check that x is roInt")
	t.ok(not point.x(11),                "Validator function causes fail (x)")
	t.is(point.x(), 1,                   "Validator prevented assignment (x)")
	' y
	t.is(point.getY(), invalid,          "Default value set on creation (y)")
	t.can_ok(point, "getY",              "Reader callable (y)")
	t.can_ok(point, "setY",              "Writer callable (y)")
	t.ok(point.setY(3.2),                "Writer write (y)")
	t.is(point.getY(), 3.2,              "Reader read (y)")
	t.isa_ok(point.getY(), "roFloat",    "Check that y is roFloat")
	t.ok(not point.setY(11),             "Validator function causes fail (y)")
	t.is(point.getY(), 3.2,              "Validator prevented assignment (y)")
	' z
	t.can_ok(point, "z",                 "Writer callable (z)")
	t.can_ok(point, "something",         "Reader callable (z)")
	t.is(point.something(), "foo",       "Default value set on creation (z)")
	t.ok(point.z(4),                     "Writer write (z)")
	t.is(point._data.z, 4,               "Internal data correct (z)")
	t.is(point.something(), 4,           "Passed back data correct (z)")
	t.isa_ok(point.something(), "roInt", "Check that z is roInt")
	t.ok(point.z("a"),                   "Writer write (z)")
	t.is(point._data.z, "a",             "Internal data correct (z)")
	t.is(point.something(), "a",         "Passed back data correct (z)")
	t.is(type(box(point._data.z)),       "roString", "Check that z is roString")
	' placed => p
	t.can_ok(pMeta, "p",                 "(New) Accessor callable (placed)")
	t.ok(pMeta.p(true),                  "(New) Accessor write true (placed)")
	t.is(pMeta._data.placed, true,       "(New) Internal data true (placed)")
	t.is(pMeta.p(), true,                "(New) Accessor read true (placed)")
	t.ok(pMeta.p(false),                 "(New) Accessor write false (placed)")
	t.is(pMeta._data.placed, false,      "(New) Internal data false (placed)")
	t.is(pMeta.p(), false,               "(New) Accessor read false (placed)")
	t.isa_ok(pMeta.p(), "roBoolean",     "Check that placed is roBoolean")
	' tag => tag
	t.can_ok(pMeta, "tag",               "(New) Accessor callable (tag)")
	t.ok(pMeta.tag("this is text"),      "(New) Assign to roString attribute (tag)")
	t.is(pMeta.tag(), "this is text",    "(New) Read from roString attrobute (tag)")
	t.isa_ok(pMeta.tag(), "roString",    "Check that placed is roString")
	' attribute contains class object
	t.can_ok(pMeta, "prevPoint",         "Attribute containing class type")
	t.is(pMeta.prevPoint("point"), false,"Prevents assignment of string")
	t.is(pMeta.prevPoint({}), false,     "Prevents assignment of empty hash")
	t.is(pMeta.prevPoint(pMeta), false,  "Prevents assignment of wrong class instance")
	t.is(pMeta.prevPoint(point), true,   "Allows assignment of correct class instance")

	t.done_testing()
end sub

' **********************
' * Test class methods *
' **********************
sub test_rdClass_methods(t)
	point = make_point()
	nd = make_nonDerived()

	''' Class methods '''
	' Assigned methods '
	t.can_ok(point, "isLTETen",          "Assigned method callable")
	t.is(point.isLTETen(3), true,        "Assigned method returns correct true")
	t.is(point.isLTETen(11), false,      "Assigned method returns correct false")

	t.can_ok(nd, "hoohaw",               "Assigned method callable")
	t.is(nd.hoohaw(3), true,             "Assigned method returns correct true")
	t.is(nd.hoohaw(11), false,           "Assigned method returns correct false")

	t.done_testing()
end sub

' **************************
' * Test class inheritance *
' **************************
sub test_rdClass_inheritance(t)
	pMeta = make_pointMeta()

	''' Class inheritance '''
	'' Regular inherited methods/attributes
	t.has_ok(pMeta, "_CLASSNAME",        "(Inherited) Classname exists")
	t.has_ok(pMeta, "_spec",             "(Inherited) Class spec exists")
	t.has_ok(pMeta, "_data",             "(Inherited) Data storage exists")
	t.has_ok(pMeta, "_prototype",        "(Inherited) Prototype object exists")
	t.is(pMeta._CLASSNAME, "PointMeta",  "(Inherited) Classname set")
	t.can_ok(pMeta, "x",                 "(Inherited) Accessor callable")
	t.ok(pMeta.x(1),                     "(Inherited) Accessor write")
	t.is(pMeta.x(), 1,                   "(Inherited) Accessor read")
	t.isa_ok(pMeta.x(), "roInt",         "(Inherited) Check that x is roInt")
	't.ok(not pMeta.x(11),                "(Inherited) Validator function")
	t.can_ok(pMeta, "isLTETen",          "(Inherited) Method callable")
	t.is(pMeta.isLTETen(3), true,        "(Inherited) method returns correct true")
	t.is(pMeta.isLTETen(11), false,      "(Inherited) method returns correct false")
	'' Newly defined methods/attributes
	t.can_ok(pMeta, "p",                 "New method callable")
	t.can_ok(pMeta, "tag",               "New method callable")

	'' Non-derived class doesn't inherit anything
	nd = make_nonDerived()
	t.can_ok(nd, "foo",                  "Different class has its own foo attribute accessor")
	t.can_ok(nd, "bar",                  "Different class has its own bar attribute accessor")
	t.cant_ok(nd, "x",                   "Different class has no access to x")
	t.cant_ok(nd, "getY",                "Different class has no access to getY")
	t.cant_ok(nd, "setY",                "Different class has no access to setY")
	t.cant_ok(nd, "z",                   "Different class has no access to z")
	t.cant_ok(nd, "something",           "Different class has no access to something")

	'' Multiple inheritance ''
	' Correctly inherits from multiple classes
	newPoint = rdClass("NewPoint", { giggity: { accessor: "please" } }, ["PointMeta","NonDerived"])
	t.can_ok(newPoint, "please",         "Defined attribute method exists")
	t.can_ok(newPoint, "tag",            "Inherited attribute method from class that inherits exists")
	t.can_ok(newPoint, "setY",           "Second degree inheritance methods exists")
	t.can_ok(newPoint, "foo",            "Inheritance from other class in inheritance set")
	' Left most class wins for conflicting methods/attributes
	t.can_ok(newPoint, "x",              "Inheritance conflict favored attribute accessor present")
	t.cant_ok(newPoint, "readOtherX",    "Inheritance conflict overridden attribute reader gone")
	t.cant_ok(newPoint, "writeOtherX",   "Inheritance conflict overridden attribute writer gone")
	' Correctly inherits methods
	t.can_ok(newPoint, "isLTETen",       "Inherited Point class method exists")
	t.can_ok(newPoint, "hoohaw",         "Inherited NonDerived class method exists")
	' Correctly resolves conflicts in inherited method names
	t.can_ok(newPoint, "tester",         "Inherited conflict method exists")
	t.is(newPoint.tester(), "foo",       "Inherited conflict method favors leftmost parent")

	t.done_testing()
end sub

' ***********************
' * Test class coersion *
' ***********************
sub test_rdClass_coersion(t)
	coerce = rdClass("Coerce", {
		int:    { type: "roInt",     accessor: "int",    coerce: true }
		float:  { type: "roFloat",   accessor: "float",  coerce: true }
		string: { type: "roString",  accessor: "string", coerce: true }
		bool:   { type: "roBoolean", accessor: "bool",   coerce: true }
	})
	nocoerce = rdClass("NoCoerce", {
		int:    { type: "roInt",     accessor: "int",    }
		float:  { type: "roFloat",   accessor: "float",  }
		string: { type: "roString",  accessor: "string", }
		bool:   { type: "roBoolean", accessor: "bool",   }
	})

	''' Class coersion '''
	t.can_ok(coerce, "int",              "roInt accessor")
	t.can_ok(coerce, "float",            "roFloat accessor")
	t.can_ok(coerce, "string",           "roString accessor")
	t.can_ok(coerce, "bool",             "roBoolean accessor")
	'' Test coersion ''
	' to roInt
	t.ok(coerce.int(1.2),                "assign float to int field")
	t.is(coerce.int(), 1,                "read assigned float from int field")
	t.isa_ok(coerce.int(), "roInt",      "read type float from int field")
	t.ok(coerce.int("1"),                "assign string to int field")
	t.is(coerce.int(), 1,                "read assigned string from int field")
	t.isa_ok(coerce.int(), "roInt",      "read type string from int field")
	t.ok(coerce.int(true),               "assign bool(true) to int field")
	t.is(coerce.int(), 1,                "read assigned bool(true) from int field")
	t.isa_ok(coerce.int(), "roInt",      "read type bool(true) from int field")
	t.ok(coerce.int(false),              "assign bool(false) to int field")
	t.is(coerce.int(), 0,                "read assigned bool(false) from int field")
	t.isa_ok(coerce.int(), "roInt",      "read type bool(false) from int field")
	' to roFloat
	t.ok(coerce.float(1),                "assign int to float field")
	t.is(coerce.float(), 1.0,            "read assigned int from float field")
	t.isa_ok(coerce.float(), "roFloat",  "read type int from float field")
	t.ok(coerce.float("1"),              "assign string to float field")
	t.is(coerce.float(), 1.0,            "read assigned string from float field")
	t.isa_ok(coerce.float(), "roFloat",  "read type string from float field")
	t.ok(coerce.float(true),             "assign bool(true) to float field")
	t.is(coerce.float(), 1.0,            "read assigned bool(true) from float field")
	t.isa_ok(coerce.float(), "roFloat",  "read type bool(true) from float field")
	t.ok(coerce.float(false),            "assign bool(false) to float field")
	t.is(coerce.float(), 0.0,            "read assigned bool(false) from float field")
	t.isa_ok(coerce.float(), "roFloat",  "read type bool(false) from float field")
	' to roString
	t.ok(coerce.string(1),               "assign int to string field")
	t.is(coerce.string(), "1",           "read assigned int from string field")
	t.isa_ok(coerce.string(), "roString","read type int from string field")
	t.ok(coerce.string(1.2),             "assign float to string field")
	t.is(coerce.string(), "1.2",         "read assigned float from string field")
	t.isa_ok(coerce.string(), "roString","read type float from string field")
	t.ok(coerce.string(true),            "assign bool(true) to string field")
	t.is(coerce.string(), "true",        "read assigned bool(true) from string field")
	t.isa_ok(coerce.string(), "roString","read type bool(true) from string field")
	t.ok(coerce.string(false),           "assign bool(false) to string field")
	t.is(coerce.string(), "false",       "read assigned bool(false) from string field")
	t.isa_ok(coerce.string(), "roString","read type bool(false) from string field")
	' to roBoolean(true)
	t.ok(coerce.bool(1),                 "assign int to bool(true) field")
	t.is(coerce.bool(), true,            "read assigned int from bool(true) field")
	t.isa_ok(coerce.bool(), "roBoolean", "read type int from bool(true) field")
	t.ok(coerce.bool(1.2),               "assign float to bool(true) field")
	t.is(coerce.bool(), true,            "read assigned float from bool(true) field")
	t.isa_ok(coerce.bool(), "roBoolean", "read type float from bool(true) field")
	t.ok(coerce.bool("anythingbutfalse"),"assign string to bool(true) field")
	t.is(coerce.bool(), true,            "read assigned string from bool(true) field")
	t.isa_ok(coerce.bool(), "roBoolean", "read type string from bool(true) field")
	' to roBoolean(false)
	t.ok(coerce.bool(0),                 "assign int to bool(false) field")
	t.is(coerce.bool(), false,           "read assigned int from bool(false) field")
	t.isa_ok(coerce.bool(), "roBoolean", "read type int from bool(false) field")
	t.ok(coerce.bool(0.0),               "assign float to bool(false) field")
	t.is(coerce.bool(), false,           "read assigned float from bool(false) field")
	t.isa_ok(coerce.bool(), "roBoolean", "read type float from bool(false) field")
	t.ok(coerce.bool("false"),           "assign string to bool(false) field")
	t.is(coerce.bool(), false,           "read assigned string from bool(false) field")
	t.isa_ok(coerce.bool(), "roBoolean", "read type string from bool(false) field")
	t.ok(coerce.bool(""),                "assign string to bool(false) field")
	t.is(coerce.bool(), false,           "read assigned string from bool(false) field")
	t.isa_ok(coerce.bool(), "roBoolean", "read type string from bool(false) field")

	'' Test non-coersion ''
	' Pre-set all the types to base values
	t.ok(nocoerce.int(99),               "Assign base int of 99 to int field")
	t.ok(nocoerce.float(12345.242),      "Assign base float of 12345.242 to float field")
	t.ok(nocoerce.string("gibberish"),   "Assign base string of gibberish to string field")
	t.ok(nocoerce.bool(false),           "Assign base float of 12345.242 to float field")
	' to roInt
	t.ok(not nocoerce.int(1.2),          "assign float to int field")
	t.is(nocoerce.int(), 99,             "read assigned float from int field")
	t.isa_ok(nocoerce.int(), "roInt",    "read type float from int field")
	t.ok(not nocoerce.int("1"),          "assign string to int field")
	t.is(nocoerce.int(), 99,             "read assigned string from int field")
	t.isa_ok(nocoerce.int(), "roInt",    "read type string from int field")
	t.ok(not nocoerce.int(true),         "assign bool(true) to int field")
	t.is(nocoerce.int(), 99,             "read assigned bool(true) from int field")
	t.isa_ok(nocoerce.int(), "roInt",    "read type bool(true) from int field")
	t.ok(not nocoerce.int(false),        "assign bool(false) to int field")
	t.is(nocoerce.int(), 99,             "read assigned bool(false) from int field")
	t.isa_ok(nocoerce.int(), "roInt",    "read type bool(false) from int field")
	' to roFloat
	t.ok(not nocoerce.float(1),          "assign int to float field")
	t.is(nocoerce.float(), 12345.242,    "read assigned int from float field")
	t.isa_ok(nocoerce.float(), "roFloat","read type int from float field")
	t.ok(not nocoerce.float("1"),        "assign string to float field")
	t.is(nocoerce.float(), 12345.242,    "read assigned string from float field")
	t.isa_ok(nocoerce.float(), "roFloat","read type string from float field")
	t.ok(not nocoerce.float(true),       "assign bool(true) to float field")
	t.is(nocoerce.float(), 12345.242,    "read assigned bool(true) from float field")
	t.isa_ok(nocoerce.float(), "roFloat","read type bool(true) from float field")
	t.ok(not nocoerce.float(false),      "assign bool(false) to float field")
	t.is(nocoerce.float(), 12345.242,    "read assigned bool(false) from float field")
	t.isa_ok(nocoerce.float(), "roFloat","read type bool(false) from float field")
	' to roString
	t.ok(not nocoerce.string(1),         "assign int to string field")
	t.is(nocoerce.string(), "gibberish", "read assigned int from string field")
	t.isa_ok(nocoerce.string(), "roString","read type int from string field")
	t.ok(not nocoerce.string(1.2),       "assign float to string field")
	t.is(nocoerce.string(), "gibberish", "read assigned float from string field")
	t.isa_ok(nocoerce.string(), "roString","read type float from string field")
	t.ok(not nocoerce.string(true),      "assign bool(true) to string field")
	t.is(nocoerce.string(), "gibberish", "read assigned bool(true) from string field")
	t.isa_ok(nocoerce.string(), "roString","read type bool(true) from string field")
	t.ok(not nocoerce.string(false),     "assign bool(false) to string field")
	t.is(nocoerce.string(), "gibberish", "read assigned bool(false) from string field")
	t.isa_ok(nocoerce.string(), "roString","read type bool(false) from string field")
	' to roBoolean(true)
	t.ok(not nocoerce.bool(1),           "assign int to bool(false) field")
	t.is(nocoerce.bool(), false,         "read assigned int from bool(false) field")
	t.isa_ok(nocoerce.bool(), "roBoolean","read type int from bool(false) field")
	t.ok(not nocoerce.bool(1.2),         "assign float to bool(false) field")
	t.is(nocoerce.bool(), false,         "read assigned float from bool(false) field")
	t.isa_ok(nocoerce.bool(), "roBoolean","read type float from bool(false) field")
	t.ok(not nocoerce.bool("anythingbutfalse"),"assign string to bool(false) field")
	t.is(nocoerce.bool(), false,         "read assigned string from bool(false) field")
	t.isa_ok(nocoerce.bool(), "roBoolean","read type string from bool(false) field")
	' to roBoolean(false)
	t.ok(nocoerce.bool(true),            "Set bool to true to test true case")
	t.ok(not nocoerce.bool(0),           "assign int to bool(true) field")
	t.is(nocoerce.bool(), true,          "read assigned int from bool(true) field")
	t.isa_ok(nocoerce.bool(), "roBoolean", "read type int from bool(true) field")
	t.ok(not nocoerce.bool(0.0),         "assign float to bool(true) field")
	t.is(nocoerce.bool(), true,          "read assigned float from bool(true) field")
	t.isa_ok(nocoerce.bool(), "roBoolean", "read type float from bool(true) field")
	t.ok(not nocoerce.bool("false"),     "assign string to bool(true) field")
	t.is(nocoerce.bool(), true,          "read assigned string from bool(true) field")
	t.isa_ok(nocoerce.bool(), "roBoolean", "read type string from bool(true) field")
	t.ok(not nocoerce.bool(""),          "assign string to bool(true) field")
	t.is(nocoerce.bool(), true,          "read assigned string from bool(true) field")
	t.isa_ok(nocoerce.bool(), "roBoolean", "read type string from bool(true) field")
	
	t.done_testing()
end sub

function xIsLTETen(x) as boolean
	if x <= 10 then return true
	return false
end function

function xIsGTTen(x) as boolean
	if x > 10 then return true
	return false
end function

function returnFooStr() as string
	return "foo"
end function

function returnBarStr() as string
	return "bar"
end function

function make_point(init={} as object) as object
	point = rdClass("Point", {
		x: {
			type: "roInt"
			default: 123
			accessor: "x"
			validator: "xIsLTETen"
			coerce: true
		}
		y: {
			type: "roFloat"
			reader: "getY"
			writer: "setY"
			validator: "m.IsLTETen"
			coerce: true
		}
		z: {
			writer: "z"
			default: "foo"
			reader: "something"
			coerce: false ' Ignored for dynamic types anyway
		}
	})
	point._addMethod("IsLTETen", xIsLTETen)
	point._addMethod("tester", returnFooStr)
	point._initialize(init)
	return point
end function

function manual_point(options={} as object) as object
	point = {
		_CLASSNAME: "ManualPoint"
		_data: { x:123, z:"foo"}
		x: manual_x
		getY: manual_getY
		setY: manual_setY
		z: manual_z
		something: manual_something
		IsLTETen: xIsLTETen
	}
	' Apply all options
	for each o in options
		if point.doesExist("_"+o) then point["_"+o] = options[o]
	end for
	return point
end function

function manual_x(x="__NOTPASSED__" as integer)
	if x = "__NOTPASSED__" then return m._data.x
	m._data.x = x
	return false
end function

function manual_getY() as float
	return m._data.y
end function

function manual_setY(y as float) as boolean
	m._data.y = y
	return true
end function

function manual_z(z) as boolean
	m._data.z = z
	return true
end function

function manual_something()
	return m._data.z
end function

function manual_point2(options={} as object) as object
	point = {
		_CLASSNAME: "ManualPoint2"
		_data: { x:123, z:"foo"}
		x: function (x="__NOTPASSED__" as integer)
			if x = "__NOTPASSED__" then return m._data.x
			m._data.x = x
			return false
		end function
		getY: function() as float
			return m._data.y
		end function
		setY: function(y as float) as boolean
			m._data.y = y
			return true
		end function
		z: function(z)
			m._data.z = z
		end function
		something: function()
			return m._data.z
		end function
		IsLTETen: xIsLTETen
	}
	' Apply all options
	for each o in options
		if point.doesExist("_"+o) then point["_"+o] = options[o]
	end for
	return point
end function

function make_pointMeta()
	pMeta = rdClass("PointMeta", {
		placed: {
			type: "roBoolean"
			accessor: "p"
			coerce: true
		}
		tag: {
			type: "roString"
			accessor: "tag"
			coerce: true
		}
		unreachable: {
			type: "roString"
		}
		prevPoint: {
			type: "Point"
			accessor: "prevPoint"
		}
	}, ["Point"])
	return pMeta
end function

function make_nonDerived()
	nonDerived = rdClass("NonDerived", {
		foo: { type: "roString", accessor: "foo", coerce: true }
		bar: { accessor: "bar" }
		x: { reader: "readOtherX", writer: "writeOtherX" }
	})
	nonDerived._addMethods({hoohaw: xIsLTETen})
	nonDerived._addMethod("tester", returnBarStr)
	return nonDerived
end function


