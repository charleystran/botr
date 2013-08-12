module BOTR

	# The BOTR::ChannelVideo class contains calls for requesting channel videos
	# in the dynamic playlist. For manual channels, these calls can also be used
	# to add, change video position or remove video from the playlist.
	class ChannelVideo < BOTR::Object

		class << self

			attr_reader :last_status

			# Show information for a video from the channel.
			#
 			# @param [String] channel_key key of the channel to which the video
 			#  belongs
 			# @params [Hash] options channel video parameters
 			#
 			# @option options [String] video_key key of the video which
 			#  information to show
 			# @option options [Integer] position position of the video in the
 			#  channel for which to show information
 			#
 			# @return [BOTR::ChannelVideo] a new object with the properties of
 			#  the video referenced by the video key or the position
			def show(channel_key, **options)
				json = get_request(options.merge(:method => 'show',
								    			 :channel_key => channel_key))
				res = JSON.parse(json.body)

				if json.status == 200
					params = process_show_response(res)
				else
					raise "HTTP Error #{json.status}: #{json.body}"
				end

				return new(params)
			end

			alias :find :show

			# Return list of videos in the channel.
			#
 			# @param [String] channel_key key of the channel for which videos
 			#  should be listed
 			# @params [Hash] options channel video parameters
 			#
 			# @option options [Integer] result_limit specifies maximum number of
 			#  videos to return; default is 50 and maximum result limit is 1000.
 			# @option options [Integer] result_offset specifies how many videos
 			#  should be skipped at the beginning of the result set
 			#
 			# @return [Array] a list of video objects in the channel specified
 			#  by the channel key
			def list(channel_key, **options)
				json = get_request(options.merge(:method => 'list',
												 :channel_key => channel_key))
				res = JSON.parse(json.body)
				
				if json.status == 200
					results = process_list_response(res)
				else
					raise "HTTP Error #{json.status}: #{json.body}"
				end

				return results
			end

			# Move a video to a different position in a manual channel.
			#
 			# @param [String] channel_key key of the channel which should be
 			#  updated
 			# @params [Hash] options channel video parameters
 			#
 			# @option options [String] position_from position in the channel
 			#  of the video which should be moved
 			# @option options [Integer] position_to position in the channel
 			#  of where the video which should be moved
 			#
 			# @return [BOTR::ChannelVideo] this object with the status of the
 			# 	move operation
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

		# Add a video to the playlist of a manual channel.
		#
		# @param [String] channel_key key of the channel to which the video
		#  belongs
		# @params [Hash] options channel video parameters
		#
		# @option options [String] video_key key of the video that should be
		#  added to the channel
		# @option options [Integer] position indicates where to insert the new
		#  video; defaults to insertion at the end
		#
		# @return [BOTR::ChannelVideo] this object with the status of the add
		#  operation
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

		# Delete a video from the playlist of a manual channel.
		#
		# @param [String] channel_key key of the channel from which video should
		#  be deleted
		# @params [Hash] options channel video parameters
		#
		# @option options [String] video_key key of the video; all videos with
		#  this key will be deleted from the channel
		# @option options [Integer] position_to video position in the channel;
		#  only video at this position will be deleted from the channel
		#
		# @return [BOTR::ChannelVideo] this object with the status of the delete
		#  operation and all other parameters nulled
		def delete(channel_key, **options)
			json = delete_request(options.merge(:channel_key => channel_key)
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