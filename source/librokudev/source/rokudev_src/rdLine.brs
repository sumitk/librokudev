' *********************************************************************
' * libRokuDev, Line Drawing Functions                                *
' *                                                                   *
' * Copyright 2010, GandK Labs.  This library is free software; see   *
' * the LICENSE file in the libRokuDev distribution for more details. *
' *********************************************************************

' ########################################################
' # Requires: rdBitwise.brs, rdByteArray.brs, rdCRC.brs, #
' #           rdPNG.brs, rdTempFile.brs                  #
' ########################################################

' *************************************************************************
' * Create a Line object, used to draw arbitrary lines on a roImageCanvas *
' *************************************************************************
function rdLine(coords = {} as object, color = {} as object) as object
	this = {
		' Member vars
		_coords: { x1: 0, y1: 0, x2: 0, y2: 0 }
		_color:	 { r: 0, g: 0, b: 0 }
		_width:	 1
		_file:	 ""

		' Methods
		' Set line start x, y
		start: function(x as integer, y as integer) as object
			m._coords.x1 = x
			m._coords.y1 = y

			return m
		end function

		' Set line stop x, y
		stop: function(x as integer, y as integer) as object
			m._coords.x2 = x
			m._coords.y2 = y

			return m
		end function

		' Set line color AA {r: 0, g: 0, b: 0}
		color: function(color as object) as object
			if m._file <> "" and (color.r <> m._color.r or color.g <> m._color.g or color.b <> m._color.b)
				DeleteFile(m._file)
				m._file = ""
			end if

			m._color = color

			return m
		end function

		' Set line width
		width: function(width as integer) as object
			m._width = width

			return m
		end function

		' Get line length
		length: function() as integer
			x = m._coords.x2 - m._coords.x1
			y = m._coords.y2 - m._coords.y1

			return int(sqr( x ^ 2 + y ^ 2 ))
		end function

		' Get line angle
		angle: function() as float
			x = m._coords.x2 - m._coords.x1
			y = m._coords.y2 - m._coords.y1

			' Special case x = 0 so no divide by zero below
			if x = 0
				if sgn(y) = 1
					return 90.0
				else ' sgn(y) = -1 or 0
					return 270.0
				end if
			end if

			' Use atn builtin to find arctangent in radians
			' and convert to degrees
			a = atn(y / x) * 57.29578

			' Add 180 degrees if x is negative,
			' due to simple arctan function
			if x < 0 then a = a + 180

			return a
		end function

		' Creates PNG file for line, and returns its location
		makeImage: function() as string
			png = rdPNG("pkg:/rokudev_files/shapes/pixel.png")
			png.setColor(m._color)

			tmp = rdTempFile(".png")
			png.save(tmp)
			m._file = tmp

			return tmp
		end function

		' Returns canvas item for line's location
		makeCanvasItem: function() as object
			if m._file=""
				m.makeImage()
			end if

			l = {
				Url:		   m._file
				TargetRotation:	   m.angle()
				CompositionMode:   "Source"
				TargetTranslation: { x: m._coords.x1, y: m._coords.y1 }
				TargetRect:	   { x: 0, y: -int(m._width / 2), w: m.length(), h: m._width }
			}

			return l
		end function

		' Remove image and saved data
		delete: function() as boolean
			if m._file <> "" then DeleteFile(m._file)

			m._file	  = ""
			m._width  = 1
			m._coords = { x1: 0, y1: 0, x2: 0, y2: 0 }
			m._color  = { r: 0, g: 0, b: 0 }
		end function
	}

	' if passed coords, set them
	for each k in this._coords
		if coords.doesExist(k)
			this._coords[k] = coords[k]
		end if
	end for

	' if passed color, set them
	for each k in this._color
		if color.doesExist(k)
			this._color[k] = color[k]
		end if
	end for

	' Return the initialized object
	return this
end function
