module BOTR

	class VideoConversion < BOTR::Object

		class << self

			attr_reader :last_status

			def show(key)
				json = get_request({:method => 'show',
								    :conversion_key => key})
				res = JSON.parse(json.body)

				if json.status == 200
					params = process_show_response(res)
				else
					raise "HTTP Error #{json.status}: #{json.body}"
				end

				return new(params)
			end

			alias :find :show

			def list(key)
				json = get_request({:method => 'list',
									:video_key => key})
				res = JSON.parse(json.body)
				
				if json.status == 200
					results = process_list_response(res)
				else
					raise "HTTP Error #{json.status}: #{json.body}"
				end

				return results
			end

			private

				def process_show_response(body)
					@last_status = body["status"]

					return body["conversion"]
				end

				def process_list_response(body)
					res = []

					body["conversions"].each do |conversion|
						res << new(conversion)
					end
					
					return res
				end

		end

		attr_reader :last_status, :key, :mediatype, :status, :duration,
					:filesize, :width, :height, :template, :error, :link

		def initialize(params = {})
			params.each do |key, val|
				param = "@#{key.to_s}"
				next unless methods.include? key.to_sym
				instance_variable_set(param, val)
			end		
		end

		def create(video_key, template_key)
			json = get_request({:method => 'create',
								:video_key => video_key,
								:template_key => template_key})
			res = JSON.parse(json.body)

			if json.status == 200
				process_create_response(res)
			else
				raise "HTTP Error #{json.status}: #{json.body}"
			end

			return self
		end

		def delete
			json = delete_request({:conversion_key => @key})
			res = JSON.parse(json.body)

			if json.status == 200
				process_delete_response(res)
			else
				raise "HTTP Error #{json.status}: #{json.body}"
			end

			return self
		end

		private

			def process_create_response(body)
				@last_status = body["status"]
				@key = body["conversion"]["key"]
			end

			def process_delete_response(body)
				@last_status = body["status"]
				instance_variables.each do |param|
					instance_variable_set(param, nil)
				end
			end

	end

end