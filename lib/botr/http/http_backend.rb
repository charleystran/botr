require 'net/http'
require 'mime/types'

module BOTR

	class HTTPBackend

		# GET request.
		def get(path, params = {})
			uri = URI(path)
			uri.query = URI.encode_www_form(params)
			
			res = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
				http.request_get uri
			end
			respond(res)
		end

		# POST request with optional multipart/form-data.
		def post(path, params = {}, data_path = "")
			uri = URI(path)
			uri.query = URI.encode_www_form(params)

			res = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
				if data_path.empty?
					http.post_form(uri, params)
				else
					post_multipart(http, uri, data_path)
				end
			end
			respond(res)
		end		

		private

			def respond(resp)
				case resp
	            when Net::HTTPOK
	                BOTR::OKResponse.new(resp.body)
	            when Net::HTTPBadRequest
	                BOTR::BadRequestResponse.new(resp.body)
	            when Net::HTTPUnauthorized
	                BOTR::UnauthorizedResponse.new(resp.body)
	            when Net::HTTPForbidden
	                BOTR::ForbiddenResponse.new(resp.body)
	            when Net::HTTPNotFound
	                BOTR::NotFoundResponse.new(resp.body)
	            when Net::HTTPMethodNotAllowed
	                BOTR::NotAllowedResponse.new(resp.body)
	            else
	                BOTR::HTTPResponse.new(resp.code, resp.body)
	            end
			end

			def post_multipart(http, uri, data_path)
				boundary = "--BitsOnTheRunMultipartBoundary--" + rand(1000000).to_s
				
				req = Net::HTTP::Post.new(uri)
				req["Content-Type"] = "multipart/form-data, boundary=#{boundary}"
				req.body_stream = build_stream(boundary, data_path)
				req["Content-Length"] = req.body_stream.size

				http.request(req)
			end

			def build_stream(boundary, data_path)
				name = File.basename(data_path, File.extname(data_path))
				content_length = File.size(data_path)
				content_type = MIME::Types.type_for(data_path).first.content_type
				
				headIO = build_head(boundary, name, data_path, content_type, content_length)
				begin
					bodyIO = File.open(data_path)
				rescue Exception => e
					raise #{e}
				end
				tailIO = build_tail(boundary)

				BOTR::UploadIO.new(headIO, bodyIO, tailIO)
			end

			def build_head(boundary, name, data_path, content_type, content_length)
				transfer_encoding = "binary"
				content_disposition = "form-data"

				head = ""
				head << "--#{boundary}\r\n"
				head << "Content-Disposition: #{content_disposition}; name=\"#{name}\"; filename=\"#{data_path}\"\r\n"
				head << "Content-Length: #{content_length}\r\n"
				head << "Content-Type: #{content_type}\r\n"
				head << "Content-Transfer-Encoding: #{transfer_encoding}\r\n"
				head << "\r\n"

				StringIO.new(head)
			end

			def build_tail(boundary)
				tail = ""
				tail << "\r\n\r\n"
				tail << "--#{boundary}--\r\n\r\n"

				StringIO.new(tail)
			end

	end

end