module URI

	# FIX: For some reason, the Bits on the Run API doesn't support the encoding
	#      of spaces to "+". As such, (ASCII space) will encode to "%20".
	TBLENCWWWCOMP__ = TBLENCWWWCOMP_.dup
	TBLENCWWWCOMP__[' '] = '%20'
	TBLENCWWWCOMP__.freeze

	def self.encode_www_form_component(str, enc=nil)
		str = str.to_s.dup

		if str.encoding != Encoding::ASCII_8BIT
	  		if enc && enc != Encoding::ASCII_8BIT
				str.encode!(Encoding::UTF_8, invalid: :replace, undef: :replace)
				str.encode!(enc, fallback: ->(x){"&#{x.ord};"})
	  		end
	  		str.force_encoding(Encoding::ASCII_8BIT)
		end
		str.gsub!(/[^*\-.0-9A-Z_a-z]/, TBLENCWWWCOMP__)
		str.force_encoding(Encoding::US_ASCII)
  	end

  	def self.decode_www_form_component(str, enc=Encoding::UTF_8)
		raise ArgumentError, "invalid %-encoding (#{str})" unless /\A[^%]*(?:%\h\h[^%]*)*\z/ =~ str
		str.b.gsub(/\+|%\h\h/, TBLENCWWWCOMP__).force_encoding(enc)
  	end

end
