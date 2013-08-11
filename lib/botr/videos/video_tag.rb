module BOTR

	class VideoTag < BOTR::Object

		class << self

			attr_reader :last_status

			def list(**options)
				json = get_request(options.merge(:method => 'list'))
				res = JSON.parse(json.body)
				
				if json.status == 200
					results = process_list_response(res)
				else
					raise "HTTP Error #{json.status}: #{json.body}"
				end

				return results
			end

			def all
				list({})
			end

			private

				def process_list_response(body)
					res = []

					body["tags"].each do |tag|
						res << new(tag)
					end
					
					return res
				end

		end

		attr_reader :name ,:videos

		def initialize(params = {})
			params.each do |key, val|
				param = "@#{key.to_s}"
				next unless methods.include? key.to_sym
				instance_variable_set(param, val)
			end		
		end

	end

end