module BOTR

	class ChannelThumbnail < BOTR::Object

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

			private

				def process_show_response(body)
					@last_status = body["status"]

					return body["thumbnail"]
				end

		end

		attr_reader :last_status, :key, :status, :error

		def initialize(params = {})
			params.each do |key, val|
				param = "@#{key.to_s}"
				next unless methods.include? key.to_sym
				instance_variable_set(param, val)
			end
			
			raise ArgumentError, "You must specify a channel key." if @key.nil?
		end

		def update
			json = put_request({:channel_key => @key})
			res = JSON.parse(json.body)

			if json.status == 200
				process_update_response(res)
			else
				raise "HTTP Error #{json.status}: #{json.body}"
			end
			
			return self
		end

		def upload(data_path, **options)
			json = post_request(options, data_path)
			res = JSON.parse(json.body)

			if json.status == 200
				process_upload_response(res)
			else
				raise "HTTP Error #{json.status}: #{json.body}"
			end

			return self
		end

		private

			def process_update_response(body)
				@last_status = body["status"]
				@key = body["media"]["key"]
				@link = body["link"]
			end

			def process_upload_response(body)
				@last_status = body["status"]
				@file = body["file"]
			end

	end

end