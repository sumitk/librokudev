' *********************************************************************
' * libRokuDev, CRC Calculations                                      *
' *                                                                   *
' * Copyright 2010, GandK Labs.  This library is free software; see   *
' * the LICENSE file in the libRokuDev distribution for more details. *
' *********************************************************************

' ############################################
' # Requires: rdBitwise.brs, rdByteArray.brs #
' ############################################

' ****************************************************************
' * Calculate the standard 32-bit CRC used by numerous standards *
' ****************************************************************
function rdCRC() as object
	this = {
		' Member vars
		CRCTABLE: [
&h00000000, &h77073096, &hee0e612c, &h990951ba,
&h076dc419, &h706af48f, &he963a535, &h9e6495a3,
&h0edb8832, &h79dcb8a4, &he0d5e91e, &h97d2d988,
&h09b64c2b, &h7eb17cbd, &he7b82d07, &h90bf1d91,
&h1db71064, &h6ab020f2, &hf3b97148, &h84be41de,
&h1adad47d, &h6ddde4eb, &hf4d4b551, &h83d385c7,
&h136c9856, &h646ba8c0, &hfd62f97a, &h8a65c9ec,
&h14015c4f, &h63066cd9, &hfa0f3d63, &h8d080df5,
&h3b6e20c8, &h4c69105e, &hd56041e4, &ha2677172,
&h3c03e4d1, &h4b04d447, &hd20d85fd, &ha50ab56b,
&h35b5a8fa, &h42b2986c, &hdbbbc9d6, &hacbcf940,
&h32d86ce3, &h45df5c75, &hdcd60dcf, &habd13d59,
&h26d930ac, &h51de003a, &hc8d75180, &hbfd06116,
&h21b4f4b5, &h56b3c423, &hcfba9599, &hb8bda50f,
&h2802b89e, &h5f058808, &hc60cd9b2, &hb10be924,
&h2f6f7c87, &h58684c11, &hc1611dab, &hb6662d3d,
&h76dc4190, &h01db7106, &h98d220bc, &hefd5102a,
&h71b18589, &h06b6b51f, &h9fbfe4a5, &he8b8d433,
&h7807c9a2, &h0f00f934, &h9609a88e, &he10e9818,
&h7f6a0dbb, &h086d3d2d, &h91646c97, &he6635c01,
&h6b6b51f4, &h1c6c6162, &h856530d8, &hf262004e,
&h6c0695ed, &h1b01a57b, &h8208f4c1, &hf50fc457,
&h65b0d9c6, &h12b7e950, &h8bbeb8ea, &hfcb9887c,
&h62dd1ddf, &h15da2d49, &h8cd37cf3, &hfbd44c65,
&h4db26158, &h3ab551ce, &ha3bc0074, &hd4bb30e2,
&h4adfa541, &h3dd895d7, &ha4d1c46d, &hd3d6f4fb,
&h4369e96a, &h346ed9fc, &had678846, &hda60b8d0,
&h44042d73, &h33031de5, &haa0a4c5f, &hdd0d7cc9,
&h5005713c, &h270241aa, &hbe0b1010, &hc90c2086,
&h5768b525, &h206f85b3, &hb966d409, &hce61e49f,
&h5edef90e, &h29d9c998, &hb0d09822, &hc7d7a8b4,
&h59b33d17, &h2eb40d81, &hb7bd5c3b, &hc0ba6cad,
&hedb88320, &h9abfb3b6, &h03b6e20c, &h74b1d29a,
&head54739, &h9dd277af, &h04db2615, &h73dc1683,
&he3630b12, &h94643b84, &h0d6d6a3e, &h7a6a5aa8,
&he40ecf0b, &h9309ff9d, &h0a00ae27, &h7d079eb1,
&hf00f9344, &h8708a3d2, &h1e01f268, &h6906c2fe,
&hf762575d, &h806567cb, &h196c3671, &h6e6b06e7,
&hfed41b76, &h89d32be0, &h10da7a5a, &h67dd4acc,
&hf9b9df6f, &h8ebeeff9, &h17b7be43, &h60b08ed5,
&hd6d6a3e8, &ha1d1937e, &h38d8c2c4, &h4fdff252,
&hd1bb67f1, &ha6bc5767, &h3fb506dd, &h48b2364b,
&hd80d2bda, &haf0a1b4c, &h36034af6, &h41047a60,
&hdf60efc3, &ha867df55, &h316e8eef, &h4669be79,
&hcb61b38c, &hbc66831a, &h256fd2a0, &h5268e236,
&hcc0c7795, &hbb0b4703, &h220216b9, &h5505262f,
&hc5ba3bbe, &hb2bd0b28, &h2bb45a92, &h5cb36a04,
&hc2d7ffa7, &hb5d0cf31, &h2cd99e8b, &h5bdeae1d,
&h9b64c2b0, &hec63f226, &h756aa39c, &h026d930a,
&h9c0906a9, &heb0e363f, &h72076785, &h05005713,
&h95bf4a82, &he2b87a14, &h7bb12bae, &h0cb61b38,
&h92d28e9b, &he5d5be0d, &h7cdcefb7, &h0bdbdf21,
&h86d3d2d4, &hf1d4e242, &h68ddb3f8, &h1fda836e,
&h81be16cd, &hf6b9265b, &h6fb077e1, &h18b74777,
&h88085ae6, &hff0f6a70, &h66063bca, &h11010b5c,
&h8f659eff, &hf862ae69, &h616bffd3, &h166ccf45,
&ha00ae278, &hd70dd2ee, &h4e048354, &h3903b3c2,
&ha7672661, &hd06016f7, &h4969474d, &h3e6e77db,
&haed16a4a, &hd9d65adc, &h40df0b66, &h37d83bf0,
&ha9bcae53, &hdebb9ec5, &h47b2cf7f, &h30b5ffe9,
&hbdbdf21c, &hcabac28a, &h53b39330, &h24b4a3a6,
&hbad03605, &hcdd70693, &h54de5729, &h23d967bf,
&hb3667a2e, &hc4614ab8, &h5d681b02, &h2a6f2b94,
&hb40bbe37, &hc30c8ea1, &h5a05df1b, &h2d02ef8d
		]

		precomputed: false

		' Methods
		' Populate the CRC lookup table.  Not used
		populateTable: function() as boolean
			m.CRCTABLE = []

			for n = 0 to 255
			'for n = 254 to 255 ' just for testing
				c = n
				for k = 0 to 7
					if (c and 1) ' c & 1
						' c1 = int(c/2) and &h7FFFFFFF
						c1 = rdRightShift(c)
						' c = ((&hEDB88320 and not c1) or (not &hEDB88320 and c1))
						c = rdXOR(&hEDB88320,c1)
					else
						' c = int(c/2) and &h7FFFFFFF
						c = rdRightShift(c)
					end if
				end for
				m.CRCTABLE[n] = c
			end for

			m.precomputed = true
		end function

		updateCRC: function(crc as integer, buf as object) as integer
			c = crc

			for n = 0 to buf.count() - 1
				index = rdXOR(c, buf[n]) and &hFF
				shiftedc = rdRightShift(c, 8)
				c = rdXOR(m.CRCTABLE[index], shiftedc)
			end for

			return c
		end function

		' Expects buf to be an roByteArray
		crc: function(buf as object, index_start = 0 as integer, index_end = -1 as integer) as integer
			if index_start <> 0 or (index_end >= 0 and index_end <> buf.count() - 1)
				buf = rdBAcopy(buf, index_start, index_end)
			end if

			return rdXOR(m.updateCRC(&hFFFFFFFF, buf), &hFFFFFFFF)
		end function

		' Expects ascii param to be a string
		crcAscii: function(ascii as string) as integer
			buf = CreateObject("roByteArray")
			buf.FromAsciiString(ascii)
			return m.CRC(buf)
		end function
	}

	return this
end function
