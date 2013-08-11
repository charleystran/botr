module BOTR
	
	module API

		def api_protocol
			BOTR.configuration.protocol || "https"
		end

		def api_server
			BOTR.configuration.server || "api.bitsontherun.com"
		end

		def api_version
			"v1"
		end

		def api_format
			"json"
		end

		def api_key
			BOTR.configuration.api_key || BOTR::API_KEY
		end

		def api_timestamp
			Time.now.to_i
		end

		# Return an 8-digit random number.
		def api_nonce
			8.times.map { [*'0'..'9'].sample }.join
		end

		def api_secret_key
			BOTR.configuration.secret_key || BOTR::SECRET_KEY
		end

		def api_call_class
			if defined? call_class
				call_class
			elsif defined? self.class.call_class
				self.class.call_class
			elsif (defined? self.name) && (self.class.name == "Class")	# We are in a class.
				klass, subclass = self.name.scan(/([[:upper:]][[:lower:]]+)/).flatten
				subclass ? "#{klass}s/#{subclass}s".downcase : "#{klass}s".downcase
			else	# We are in an instance.
				klass, subclass = self.class.name.scan(/([[:upper:]][[:lower:]]+)/).flatten
				subclass ? "#{klass}s/#{subclass}s".downcase : "#{klass}s".downcase
			end
		end

		def upload_protocol
			@link["protocol"] || "http"
		end

		def upload_address
			@link["address"] || "upload.bitsontherun.com"
		end

		def upload_key
			@link["query"]["key"] || upload_key
		end

		def upload_token
			@link["query"]["token"] || upload_token
		end

		def api_url(api_method = "")
			"#{api_protocol}://#{api_server}/#{api_version}/#{api_call_class}/#{api_method}"
		end

		def upload_url
			"#{upload_protocol}://#{upload_address}/#{api_version}/#{api_call_class}/upload"
			# "http://httpbin.org/post"
		end

		def progress_url(callback)
			"#{upload_protocol}://#{upload_address}/progress?token=#{upload_token}&callback=#{callback}"
		end

	end

end