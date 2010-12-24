function rdClass(classname as string, spec as object, ancestors=[]) as object
	if not m.doesExist("class") then m.class = {}
	if not m.class.doesExist(classname)

		' If the isubclass is a string, replace with stored class data (if there is any), or attempt to create class to make that info
		ancestorObjs = []
		for i=0 to ancestors.count()-1
			if type(box(ancestors[i])) = "roString"
				' If the class isn't stored (yet), attempt to make one
				' Assumes creation function name is same as class name
				if not m.class.doesExist(ancestors[i])
					eval(ancestors[i]+"()")
				end if

				' If it does exist not, replace name with instance of class
				if m.class.doesExist(ancestors[i])
					ancestorObjs[i] = m.class[ancestors[i]]
				else
					print "Failed making class ";ancestors[i]
				end if
			end if
		end for

		' Create skeletan class
		this = {
			_CLASSNAME: classname
			_spec:      spec
			_data:      {}
			_generated_methods: {}
			_defined_methods: {}
			initialize: _rdObject_initialize
		}
		' Add inherited attributes and methods, left most wins on conflicts
		for each ancestor in ancestorObjs
			for each attr_name in ancestor._spec
				if not spec.doesExist(attr_name) then spec[attr_name] = ancestor._spec[attr_name]
			end for
			' We add defined methods, but leave the spec to handle generated methods
			methods = this._defined_methods
			for each method_name in ancestor._defined_methods
				if not methods.doesExist(method_name) then methods[method_name] = ancestor._defined_methods[method_name]
			end for
		end for

		DQ = CHR(34)
		NL = CHR(10)

		for each attr_name in spec
			attribute = spec[attr_name]

			if attribute.doesExist("type") and type(box(attribute.type)) = "roString"
				attr_type = attribute.type
			else
				attr_type = invalid
			end if

			' Generate type checking code if we have a type
			typeCode = ""
			if attr_type <> invalid
				typeCode = "if not _rdObject_checkType("+DQ+attr_type+DQ+", value) then return false"
			end if

			' Generate coersion code if requested
			coerceCode = ""
			if attr_type <> invalid and attribute.doesExist("coerce") and attribute.coerce
				coerceCode = "if not _rdObject_checkType("+DQ+attr_type+DQ+", value)"+NL+"value = _rdObject_coerceType("+DQ+attr_type+DQ+", value)"+NL+"if value = invalid then return false"+NL+"end if"
			end if

			' Generatte validation code if required
			validationCode = ""
			if attribute.doesExist("validator") and type(box(attribute.validator)) = "roString"
				validationCode = "if not "+attribute.validator+"(value) then return false"
			end if

			' Create fast reader if defined
			if attribute.doesExist("reader") and type(box(attribute.reader)) = "roString"
				readerCode = "this[attribute.reader] = function()"+NL+"return m._data."+attr_name+NL+"end function"
				eval(readerCode)
				this._generated_methods[attribute.reader] = this[attribute.reader]
			end if

			' Create fast writer if defined
			if attribute.doesExist("writer") and type(box(attribute.writer)) = "roString"
				writerCode = "this[attribute.writer] = function(value as Dynamic) as boolean"+NL+coerceCode+NL+typeCode+NL+validationCode+NL+"m._data."+attr_name+" = value"+NL+"return true"+NL+"end function"
				eval(writerCode)
				this._generated_methods[attribute.writer] = this[attribute.writer]
			end if

			' Generate accessor if defined
			if attribute.doesExist("accessor") and type(box(attribute.accessor)) = "roString"
				accessorCode = "this[attribute.accessor] = function(value="+DQ+"__NOTPASSED__"+DQ+" as Dynamic)"+NL+"if type(box(value)) = "+DQ+"roString"+DQ+" and value = "+DQ+"__NOTPASSED__"+DQ+" then return m._data."+attr_name+NL+coerceCode+NL+typeCode+NL+validationCode+NL+"m._data."+attr_name+" = value"+NL+"return true"+NL+"end function"
				eval(accessorCode)
				this._generated_methods[attribute.accessor] = this[attribute.accessor]
			end if

		end for

		' Assign newly generated class to class object store
		m.class[classname] = this
	end if

	''' This code runs on ever instantiation, so nothing slow here '''
	prototype = m.class[classname]
	objCopy = {
		_CLASSNAME: classname
		_prototype: prototype
		_spec:      prototype._spec
		_data:      {}
		_addMethod: _rdObject_addMethod
		_addMethods: _rdObject_addMethods
		_initialize: _rdObject_initialize
	}
	' Set generated methods
	gmethods = prototype._generated_methods
	for each method in gmethods
		objCopy[method] = gmethods[method]
	end for
	' Set defined methods
	dmethods = prototype._defined_methods
	for each method in dmethods
		objCopy[method] = dmethods[method]
	end for

	return objCopy
end function

function _rdObject_initialize(initdata as object) as object
	' Pull spec and data into their own vars for ease and speed
	spec = m._spec
	data = m._data

	for each attr_name in spec
		' If data passed, use it
		if initdata.doesExist(attr_name)
			data[attr_name] = initdata[attr_name]
		' Otherwise fall back on default
		elseif spec[attr_name].doesExist("default")
			data[attr_name] = spec[attr_name].default
		end if
	end for

	return m
end function

function _rdObject_checkType(objType as string, value as dynamic) as boolean
	if objType = "" or objType = "roDynamic" then return true
	valType = type(box(value))

	' Exact type match
	if     valType = objType
		return true
	' rdClass object with same classname
	elseif valType = "roAssociativeArray" and value.doesExist("_CLASSNAME") and value._CLASSNAME = objType
		return true
	end if

	return false
end function

function _rdObject_coerceType(targetType, value) as dynamic
	' If the value is already the right type, just return it
	valType = type(box(value))
	if targetType = valType then return value

	' Start the coersion
	if     targetType = "roInt"
		if valType = "roString" then return value.toInt()
		if valType = "roFloat"	then return int(value)
		if valType = "roBoolean"
			if value = true then return 1 else return 0
		end if
	elseif targetType = "roString"
		if valType = "roInt" then return value.toStr()
		if valType = "roFloat" then return STR(value).trim()
		if valType = "roBoolean"
			if value = true then return "true" else return "false"
		end if
	elseif targetType = "roFloat"
		if valType = "roInt" then return value / 1
		if valType = "roString" then return value.toFloat()
		if valType = "roBoolean"
			if value = true then return 1.0 else return 0.0
		end if
	elseif targetType = "roBoolean"
		if valType = "roInt" or valType = "roFloat"
			if value <> 0 then return true else return false
		end if
		if valType = "roString"
			if value = "" or UCASE(value) = "FALSE" then return false else return true
		end if
	end if

	' Couldn't find a coersion; fail out
	return invalid
end function

function _rdObject_addMethod(name as string, code) as boolean
	if m._prototype._defined_methods.doesExist(name) then return false
	if type(box(code)) <> "roFunction" then return false
	m[name] = code
	m._prototype._defined_methods[name] = code
	return true
end function

function _rdObject_addMethods(methods as object, label="__COMPLETELABEL__" as string) as boolean
	for each name in methods
		if not m._prototype._defined_methods.doesExist(name)
			code = methods[name]
			if type(box(code)) = "roFunction"
				m[name] = code
				m._prototype._defined_methods[name] = code
			end if
		end if
	end for
	return true
end function
