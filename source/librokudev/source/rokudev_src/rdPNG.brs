' *********************************************************************
' * libRokuDev, PNG File Editing and Utilities                        *
' *                                                                   *
' * Copyright 2010, GandK Labs.  This library is free software; see   *
' * the LICENSE file in the libRokuDev distribution for more details. *
' *********************************************************************

' ########################################################
' # Requires: rdBitwise.brs, rdByteArray.brs, rdCRC.brs  #
' ########################################################

' *************************************************************
' * Wrap a PNG file in an object with various utility methods *
' *************************************************************
function rdPNG(file="" as string) as object
	this = {
		_data: CreateObject("roByteArray")
		_headers: {}
		isLoaded: function() as boolean
			if m._data.count() <> 0
				return true
			end if
			return false
		end function
		' Accepts in filename of PNG
		' Returns bytearray of png data
		open: function(file as string) as boolean
			m._data.readfile(file)
			return m.isLoaded()
		end function
		' Returns PLTE header start offset
		_findHeader: function(name as string) as integer
			if not m.isLoaded()
				return 0
			end if
			datasize = 1
			offset = 8 ' Magic data
			while datasize > 0
				datasize = rdBAtoINT(m._data, offset, offset+4)
				hdrname = rdBAtoStr(m._data, offset+4, offset+8)
				if hdrname = name
					return offset
				end if
				' offset += size + name + data + crc
				offset = offset + 4 + 4 + datasize + 4
			end while
			print "Error finding ";name;" header!"
			return 0
		end function
		' Writes the PLTE header + CRC to colors specified
		' Warning! Will cause corruption of PNG if more color entries are specified than exist PLTE entries
		setColor: function(color as object) as boolean
			if not m.isLoaded()
				return false
			end if
			if not m._headers.doesExist("PLTE")
				m._headers["PLTE"] = m._findHeader("PLTE")
			end if
			offset = m._headers["PLTE"]
				
			' Get header size
			datasize = rdBAtoINT(m._data, offset, offset+4)
			' Set color bits
			' Assumes two PLTE entries, first is alpha, second is color
			plte_index = offset+4+4
			for i=0 to datasize-1 step 3
				plte_index = plte_index + i
				m._data[plte_index]   = color.r
				m._data[plte_index+1] = color.g
				m._data[plte_index+2] = color.b
			end for
			' Generate CRC of NAME + DATA
			crc = rdCRC().crc(rdBAcopy(m._data, offset+4, offset+4+4+datasize))
			crcstart = offset+4+4+datasize
			m._data[crcstart]   = rdRightShift(crc,24)
			m._data[crcstart+1] = rdRightShift(crc,16)
			m._data[crcstart+2] = rdRightShift(crc,08)
			m._data[crcstart+3] = crc
			return true
		end function
		_swaptRNS: function(offset as integer, bordermode=false as boolean) as boolean
			if not m.isLoaded()
				return false
			end if
			datasize = rdBAtoINT(m._data, offset, offset+4)
			border_byte = offset+4+4 ' size + name
			inside_byte = border_byte+1
			m._data[border_byte] = 255
			m._data[inside_byte] = 0
			crc = rdCRC().crc(rdBAcopy(m._data, offset+4, offset+4+4+datasize))
			crcstart = offset+4+4+datasize
			m._data[crcstart]   = rdRightShift(crc,24)
			m._data[crcstart+1] = rdRightShift(crc,16)
			m._data[crcstart+2] = rdRightShift(crc,08)
			m._data[crcstart+3] = crc
			return true
		end function
		' Write sthe tRNS header and CRC
		save: function(location as string) as integer
			m._data.writefile(location)
		end function
	}
	if file<>""
		this.open(file)
	end if
	return this
end function

