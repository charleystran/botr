module BOTR

	# The BOTR::VideoThumbnail class contains calls for managing the preview
	# image of a video.
	class VideoThumbnail < BOTR::Object

		class << self

			attr_reader :last_status

			# Show video thumbnails creation status.
			#
 			# @param [String] video_key key of the video for which to show
 			#  thumbnails creation status
 			#
 			# @return [BOTR::VideoThumbnail] a new object with the thumbnail status of
 			#  the video referenced by the video key
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

					return body["thumbnail"]
				end

		end

		attr_reader :last_status, :key, :status, :strip_status, :link,
					:error, :strip_error

		def initialize(params = {})
			params.each do |key, val|
				param = "@#{key.to_s}"
				next unless methods.include? key.to_sym
				instance_variable_set(param, val)
			end		
		end

		# Update a video’s thumbnail by either setting a frame from the video or
		# uploading an image.
		#
		# @param [Hash] options video parameters
		#
		# @option options [Float] position video frame position in seconds from
		#  which thumbnail should be generated; seconds can be given as a whole
		#  number (e.g: 7) or with the fractions (e.g.: 7.42)
		# @option options [String] tags tags for the video; multiple tags should
		#  be comma-separated
		# @option options [Integer] thumbnail_index index of the image in the
		#  thumbnail strip to use as a video thumbnail; thumbnail index starts
		#  from 1
		# @option options [String] md5 thumbnail file MD5 message digest
		# @option options [Integer] size thumbnail file size
		#
		# @return [BOTR::VideoThumbnail] this video thumbnail object with an
		# optional upload link
		def update(**options)
			json = put_request(options.merge(:video_key => @key))
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