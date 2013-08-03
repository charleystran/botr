module BOTR	

	class UploadIO

		def initialize(*ios)
			@ios = ios
			@current_idx = -1
		end

		def read(length = nil, outbuf = "")
			return outbuf if length == 0

			while io = next_io
				result = io.read(length)
				unless result.empty?
					result.force_encoding("BINARY") if result.respond_to?(:force_encoding)
					outbuf << result

					length -= result.length if length
					break if length == 0
				end
			end

			close_ios
			(outbuf.empty? && length.nil?) ? nil : outbuf
		end

		private

			def next_io
				@ios[@current_idx += 1]
			end

			def close_ios
				@ios.each { |stream| stream.close unless stream.closed? }
			end
	end

end