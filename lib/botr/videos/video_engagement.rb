module BOTR

	# The BOTR::VideoEngagement class contains calls for for displaying video
	# engagement data.
	# 
	# Engagement analytics allow you to track which sections of a video are
	# being watched by users. These analytics are useful for determining:
	# 
	# Drop off rates: Many users might drop off at a certain point in the video.
	# Editing that section might increase engagement.
	# Replay rates: Many users might replay a certain section in the video.
	# This might be a location to target ads against.
	class VideoEngagement < BOTR::Object

		class << self

			attr_reader :last_status

			def call_class
				"videos/engagement"
			end

			# Displays engagement analytics for a single video.
			#
 			# @param [String] video_key the key of the video to display
 			# engagement analytics for
 			#
 			# @return [BOTR::VideoEngagement] a new object with the engagement
 			#  analytics of the video referenced by the video key
			def show(video_key)
				json = get_request({:method => 'show',
								    :video_key => video_key})
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