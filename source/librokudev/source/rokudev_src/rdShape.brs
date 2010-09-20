' *********************************************************************
' * libRokuDev, Shape Drawing Functions                               *
' *                                                                   *
' * Copyright 2010, GandK Labs.  This library is free software; see   *
' * the LICENSE file in the libRokuDev distribution for more details. *
' *********************************************************************

' ########################################################
' # Requires: rdBitwise.brs, rdByteArray.brs, rdCRC.brs, #
' #           rdPNG.brs, rdTempFile.brs                  #
' ########################################################

' *************************************************************************
' * Create a Shape object, used to draw various shapes on a roImageCanvas *
' *************************************************************************
function rdShape(shapetype as string, placement={} as object, color={} as object) as object
	this = {
		_shape: ""
		_placement: { x:0, y:0, w:1, h:1, r:0 }
		_color: { r:0, g:0, b:0 }
		_file: ""
		' Set shape type name
		shape: function(shapetype as string) as object
			if m._file<>"" and m._shape <> shapetype
				DeleteFile(m._file)
				m._file = ""
			end if
			m._shape = shapetype
			return m
		end function
		' Set shape center x,y
		center: function(x as integer, y as integer) as object
			m._placement.x = x
			m._placement.y = y
			return m
		end function
		' Set shape size w,h
		size: function(w as integer, h as integer) as object
			m._placement.w = w
			m._placement.h = h
			return m
		end function
		' Set shape rotation
		rotation: function(r as float) as object
			m._placement.r = r
			return m
		end function
		' Set shape color AA {r:0,g:0,b:0}
		color: function(color as object) as object
			if m._file<>"" and (color.r <> m._color.r or color.g <> m._color.g or color.b <> m._color.b)
				DeleteFile(m._file)
				m._file = ""
			end if
			m._color = color
			return m
		end function
		' Create's PNG image for shape, and returns it's location
		makeImage: function() as string
			png = rdPNG("pkg:/rokudev_files/shapes/"+m._shape+".png")
			png.setColor(m._color)
			tmp = rdTempFile(".png")
			png.save(tmp)
			m._file = tmp
			return tmp
		end function
		' Returns canvas item for shape's location
		makeCanvasItem: function() as object
			if m._file=""
				m.makeImage()
			end if
			l = {
				url: m._file,
				TargetTranslation: { x:m._placement.x, y:m._placement.y },
				TargetRotation: m._placement.r,
				TargetRect: {
					x: -int(m._placement.w/2)
					y: -int(m._placement.h/2)
					w: m._placement.w
					h: m._placement.h },
			}
			return l
		end function
		' Remove image and saved data
		delete: function() as boolean
			if m._file<>"" then DeleteFile(m._file)
			m._file      = ""
			m._shape     = ""
			m._placement = { x:0, y:0, w:1, h:1, r:0 }
			m._color     = { r:0, g:0, b:0 }
		end function
	}

	' if passed placement, set them
	for each k in this._placement
		if placement.doesExist(k)
			this._placement[k] = placement[k]
		end if
	end for

	' if passed color, set them
	for each k in this._color
		if color.doesExist(k)
			this._color[k] = color[k]
		end if
	end for

	' Set the shape
	this._shape = shapetype

	return this
end function
