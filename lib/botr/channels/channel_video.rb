module BOTR

	class ChannelVideo < BOTR::Object

		class << self

			attr_reader :last_status

			def show(key, **options)
				json = get_request(options.merge(:method => 'show',
								    			 :channel_key => key))
				res = JSON.parse(json.body)

				if json.status == 200
					params = process_show_response(res)
				else
					raise "HTTP Error #{json.status}: #{json.body}"
				end

				return new(params)
			end

			alias :find :show

			def list(key, **options)
				json = get_request(options.merge(:method => 'list',
												 :channel_key => key))
				res = JSON.parse(json.body)
				
				if json.status == 200
					results = process_list_response(res)
				else
					raise "HTTP Error #{json.status}: #{json.body}"
				end

				return results
			end

			def update(channel_key, **options)
				json = put_request(options.merge(:channel_key => channel_key))
				res = JSON.parse(json.body)

				if json.status == 200
					process_update_response(res)
				else
					raise "HTTP Error #{json.status}: #{json.body}"
				end

				return self
			end

			private

				def process_show_response(body)
					@last_status = body["status"]
					return body["video"]
				end

				def process_list_response(body)
					res = []

					body["videos"].each do |video|
						res << new(video)
					end
					
					return res
				end

				def process_update_response(body)
					@last_status = body["status"]
				end

		end

		attr_reader :last_status, :key, :author, :date, :description, :duration,
					:link, :md5, :mediatype, :tags, :title, :views

		def initialize(params = {})
			params.each do |key, val|
				param = "@#{key.to_s}"
				next unless methods.include? key.to_sym
				instance_variable_set(param, val)
			end
			raise ArgumentError, "You must specify a video key." if @key.nil?
		end

		def create(channel_key, **options)
			json = get_request(options.merge(:method => 'create',
											 :channel_key => channel_key,
											 :video_key => @key))
			res = JSON.parse(json.body)

			if json.status == 200
				process_create_response(res)
			else
				raise "HTTP Error #{json.status}: #{json.body}"
			end

			return self
		end

		def delete(channel_key)
			json = delete_request({:channel_key => channel_key})
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
			end

			def process_delete_response(body)
				@last_status = body["status"]
				instance_variables.each do |param|
					instance_variable_set(param, nil)
				end
			end

	end

end