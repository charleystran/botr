module BOTR

	class Player < BOTR::Object

		class << self

			attr_reader :last_status

			def show(key)
				json = get_request({:method => 'show',
								    :player_key => key})
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

					return body["player"]
				end

				def process_list_response(body)
					res = []

					body["players"].each do |player|
						res << new(player)
					end
					
					return res
				end

		end

		attr_reader :last_status, :key, :name, :width, :height, :template,
					:ga_web_property_id, :controlbar, :playlist, :playlistsize,
					:related_videos, :stretching, :aspectratio, :autostart,
					:repeat, :responsive, :skin, :sharing, :sharing_player_key,
					:sitecatalyst, :captions, :ltas_channel, :version, :views,
					:watermark, :advertising

		def initialize(params = {})
			params.each do |key, val|
				param = "@#{key.to_s}"
				next unless methods.include? key.to_sym
				instance_variable_set(param, val)
			end		
		end

		def create(name, sharing_player_key, **options)
			json = get_request(options.merge(:method => 'create',
											 :name => name,
											 :sharing_player_key => sharing_player_key))
			res = JSON.parse(json.body)

			if json.status == 200
				process_create_response(res, options)
			else
				raise "HTTP Error #{json.status}: #{json.body}"
			end

			return self
		end

		def update(**options)
			json = put_request(options.merge(:player_key => @key,
											 :sharing_player_key => @sharing_player_key))
			res = JSON.parse(json.body)

			if json.status == 200
				process_update_response(res, options)
			else
				raise "HTTP Error #{json.status}: #{json.body}"
			end

			return self
		end

		def delete
			json = delete_request({:player_key => @key})
			res = JSON.parse(json.body)

			if json.status == 200
				process_delete_response(res)
			else
				raise "HTTP Error #{json.status}: #{json.body}"
			end

			return self
		end

		private

			def process_create_response(body, params)
				@last_status = body["status"]
				@key = body["media"]["key"]
				params.each do |key, val|
					param = "@#{key.to_s}"
					next unless methods.include? key
					instance_variable_set(param, val)
				end
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