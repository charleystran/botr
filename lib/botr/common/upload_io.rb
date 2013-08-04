module BOTR	

	class UploadIO

  		def initialize(*ios)
    		@ios = ios
    		@current_idx = 0
  		end

  		def read(length = nil, outbuf = "")
  			success = false

  			while io = current_io
  				result = io.read(length)

  				if result
  					success ||= !result.nil?
  					result.force_encoding("BINARY") if result.respond_to?(:force_encoding)
  					
  					outbuf << result
  					length -= result.length if length
  					break if length == 0
  				end

  				next_io
  			end

  			(!success && length) ? nil : outbuf
  		end

  		def rewind
  			@ios.each { |io| io.rewind }
  			@current_idx = 0
  		end

  		def size
  			@ios.map { |io| io.size }.reduce(:+)
  		end

  		def close
  			@ios.each { |stream| stream.close unless stream.closed? }
  		end

  		private

  			def current_io
  				@ios[@current_idx]
  			end

  			def next_io
  				@current_idx += 1
  			end

	end

end