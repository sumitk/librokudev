' *********************************************************************
' * libRokuDev, Temp File Handling                                    *
' *                                                                   *
' * Copyright 2010, GandK Labs.  This library is free software; see   *
' * the LICENSE file in the libRokuDev distribution for more details. *
' *********************************************************************

' ***************************************************************************
' * Generate a unique filename in tmp:/ area, with an optional fixed suffix *
' ***************************************************************************
' Note: Uses global m since it's not called from an AA
function rdTempfile(suffix="" as string) as dynamic
	basedir = "tmp:/_rdTempfile"

	' Set up our own little section in the module global var
	' and do some setup if we haven't already
	if not m.DoesExist("_rdTempfile")
		m._rdTempfile = { filenum: 0, dir: "" }

		' Assign unique basedir
		dt = CreateObject("roDateTime")
		dt.mark()

		' Make sure any other calls will have a different
		' milliseconds time (in all probability never needed)
		sleep(2)

		dir = basedir + "_" + dt.asSeconds().toStr() + "." + dt.getMilliseconds().toStr()

		if not CreateDirectory(dir)
			print "Error creating basedir directory " + dir
			return false
		end if

		m._rdTempfile.dir = dir
	end if

	' Return filename for next unique file
	m._rdTempfile.filenum = m._rdTempfile.filenum + 1
	return m._rdTempfile.dir + "/" + m._rdTempfile.filenum.toStr() + suffix
end function
