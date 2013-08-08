require 'mime/types'
require 'tempfile'

module BOTR	

	class Multipart

		def initialize(data_path = "", boundary = nil)
			@data_path = data_path
			@boundary = boundary

			build_stream
		end

		def close
			@stream.close! unless @stream.closed?
		end

      	def method_missing(*args)
      		@stream.send(*args)
      	end

      	def respond_to?(meth)
      		@stream.respond_to?(meth) || super(meth)
      	end


		private

			def boundary
				@boundary ||= rand(1000000).to_s
			end

			def mime_type_for(path)
				mime = MIME::Types.type_for(path).first
				mime ? mime.content_type : 'text/plain'
			end

			# Build a multipart/form-data body as per RFC 2388.
			def build_stream
				# Form input field name for the file path must be set to file.
				# Any other field name will not be picked up by the upload server.
				name = 'file'
				content_length = File.size(@data_path)
				content_type = mime_type_for(@data_path)

				@stream = Tempfile.new("BitsOnTheRun.Upload.")
				@stream.binmode
				
				write_stream_head(name, content_type, content_length)
				write_stream_body
				write_stream_tail

				@stream.seek(0)
			end

			def write_stream_head(name, content_type, content_length)
				transfer_encoding = "binary"
				content_disposition = "form-data"

				@stream.write "--#{boundary}\r\n"
				@stream.write "Content-Disposition: #{content_disposition}; name=\"#{name}\"; filename=\"#{File.basename(@data_path)}\"\r\n"
				@stream.write "Content-Length: #{content_length}\r\n"
				@stream.write "Content-Type: #{content_type}\r\n"
				@stream.write "Content-Transfer-Encoding: #{transfer_encoding}\r\n"
				@stream.write "\r\n"
			end

			def write_stream_body
				f = File.new(@data_path)
				while data = f.read(8124)
					@stream.write(data)
				end
			ensure
				f.close unless f.closed?
			end

			def write_stream_tail
				@stream.write "\r\n"
				@stream.write "--#{boundary}--\r\n"
			end

	end
end