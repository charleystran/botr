require 'net/http'

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
				req = Net::HTTP::Post.new(uri.request_uri)

				if data_path.empty?
					req.set_form_data(params)
				else
					boundary = rand(1000000).to_s
					
					req.body_stream = BOTR::Multipart.new(data_path, boundary)
					req["Content-Type"] = "multipart/form-data; boundary=#{boundary}"
					req["Content-Length"] = req.body_stream.size.to_s		
				end
				
				http.request req
			end

			respond(res)			
		end		

		private

			# Map Net::HTTPResponses to internal ones.
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
	end

end