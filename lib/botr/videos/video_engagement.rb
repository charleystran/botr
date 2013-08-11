module BOTR

	class VideoEngagement < BOTR::Object

		class << self

			attr_reader :last_status

			def call_class
				"videos/engagement"
			end

			def show(key)
				json = get_request({:method => 'show',
								    :video_key => key})
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

					return body["video"]
				end

		end

		attr_reader :last_status, :key, :engagements

		def initialize(params = {})
			params.each do |key, val|
				param = "@#{key.to_s}"
				next unless methods.include? key.to_sym
				instance_variable_set(param, val)
			end		
		end

	end

end