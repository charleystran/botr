require 'digest/sha1'

module BOTR
	
	module Authentication

		def signature(params = {})
			sorted_params = {}
			str_params = ""

			# Sort params by key (hashes maintain insertion order)
			params.keys.sort.each do |key|
				sorted_params[key] = params[key]
			end

			# URL encode params
			str_params = URI.encode_www_form(sorted_params)

			Digest::SHA1.hexdigest str_params + api_secret_key
		end

	end 

end