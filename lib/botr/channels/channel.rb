module BOTR

	class Channel < BOTR::Object

		class << self

			attr_reader :last_status

			def show(key)
				json = get_request({:method => 'show',
								    :channel_key => key})
				res = JSON.parse(json.body)

				if json.status == 200
					params = process_show_response(res)
				else
					raise "HTTP Error #{json.status}: #{json.body}"
				end

				return new(params)
			end

			alias :find :show

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

				def process_show_response(body)
					@last_status = body["status"]
					return body["channel"]
				end

				def process_list_response(body)
					res = []

					body["channels"].each do |channel|
						res << new(channel)
					end
					
					return res
				end

		end

		attr_reader :last_status, :key, :author, :title, :description, :link,
					:type, :tags, :tags_mode, :sort_order, :videos, :views

		def initialize(params = {})
			params.each do |key, val|
				param = "@#{key.to_s}"
				next unless methods.include? key.to_sym
				instance_variable_set(param, val)
			end		
		end

		def create(type, **options)
			json = get_request(options.merge(:method => 'create',
											 :type => type))
			res = JSON.parse(json.body)

			if json.status == 200
				process_create_response(res)
			else
				raise "HTTP Error #{json.status}: #{json.body}"
			end

			return self
		end

		def update(**options)
			json = put_request(options.merge(:channel_key => @key))
			res = JSON.parse(json.body)

			if json.status == 200
				process_update_response(res, options)
			else
				raise "HTTP Error #{json.status}: #{json.body}"
			end

			return self
		end

		def delete
			json = delete_request({:channel_key => @key})
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
				@key = body["channel"]["key"]
			end

			def process_update_response(body, updated_params)
				@last_status = body["status"]
				updated_params.each do |key, val|
					param = "@#{key.to_s}"
					next unless methods.include? key
					instance_variable_set(param, val)
				end
			end

			def process_delete_response(body)
				@last_status = body["status"]
				instance_variables.each do |param|
					instance_variable_set(param, nil)
				end
			end

	end

end