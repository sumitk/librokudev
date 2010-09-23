' *********************************************************************
' * libRokuDev, Scrolling Text Console for roImageCanvas              *
' *                                                                   *
' * Copyright 2010, GandK Labs.  This library is free software; see   *
' * the LICENSE file in the libRokuDev distribution for more details. *
' *********************************************************************

' #############
' # Requires: #
' #############

' ***************************************
' * Auto-Scrolling roImageCanvas buffer *
' ***************************************
function rdConsole(init = {} as object) as object
	this = {
		' Member vars
		_canvas	     : invalid
		_buffer	     : CreateObject("roList")
		_size	     : 10
		_wrap_chars  : 999
		_line_height : 30
		_textattrs   : { Color: "#000000", HAlign: "left", VAlign: "top" }
		_secondcolor : invalid
		_backcolor   : invalid
		_location    : { x:0, y:0, w:300, h:100 }
		_layer	     : 1
		_direction   : "down"

		' Methods
		setCanvas: function(canvas as object) as object
			m._canvas = canvas
			return m
		end function

		setMaxMessages: function(size as integer) as object
			m._size = size
			return m
		end function

		setTextAttrs: function(attrs as object) as object
			m._textattrs = attrs
			return m
		end function

		setLocation: function(location as object) as object
			m._location = location
			return m
		end function

		add: function(message as string) as object
			' Add to buffer
			if m._direction = "down"
				m._buffer.addTail(message)
				if m._buffer.count() > m._size
					m._buffer.removeHead()
				end if
			else
				m._buffer.addHead(message)
				if m._buffer.count() > m._size
					m._buffer.removeTail()
				end if
			end if
			return m
		end function

		display: function() as object
			msgs = []
			cur_lines = 0

			if m._backcolor <> invalid
				msgs.push({ TargetRect: m._location, Color: m._backcolor })
			end if

			for each text in m._buffer
				' Set text color
				textattrs = {}
				for each k in m._textattrs
					textattrs[k] = m._textattrs[k]
				end for

				if cur_lines > 0 and m._secondcolor <> invalid
					textattrs.color = m._secondcolor
				end if

				' Set location
				location = {}
				for each k in m._location
					location[k] = m._location[k]
				end for

				location.y = m._location.y + m._line_height * cur_lines

				msg = {
					Text       : text,
					TextAttrs  : textattrs,
					TargetRect : location
					Mode       : "Source",
				}

				msgs.push(msg)
				cur_lines = cur_lines + 1
			end for

			m._canvas.setLayer(m._layer, msgs)
			m.show()

			return m
		end function

		print: function (message = invalid as dynamic) as object
			if message <> invalid
				m.add(message)
			end if

			m.display()

			return m
		end function

		show: function() as object
			m._canvas.show()
			sleep(50) ' XXXX: Hard-coded currently
			return m
		end function
	}
	
	' If any initializing params are passed for member vars, assign them
	for each k in init
		if this.doesExist("_" + k)
			this["_" + k] = init[k]
		end if
	end for
	
	return this
end function
