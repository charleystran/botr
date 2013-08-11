module BOTR

	# The BOTR::Video class contains calls for creating (uploading) videos,
	# searching for videos, editing video metadata (title, description,
	# tags etc.) and deleting videos.
	#
	# A video object is a metadata container that actually contains multiple
	# video files (conversions). It does _not_ reference the actual video file
	# located on the content server.
	class Video < BOTR::Object

		class << self

			attr_reader :last_status

			# Show the properties of a given video.
			#
 			# @param [String] video_key key of the video for which to show
 			#  information
 			#
 			# @return [BOTR::Video] a new object with the properties of the
 			#  video referenced by the video_key
			def show(video_key)
				json = get_request({:method => 'show', :video_key => video_key})
				res = JSON.parse(json.body)

				if json.status == 200
					params = process_show_response(res)
				else
					raise "HTTP Error #{json.status}: #{json.body}"
				end

				return new(params)
			end

			alias :find :show

			# Return a list of videos.
			#
			# @param [Hash] options search parameters
			#
			# @option options [String] tags restrict the search to videos tagged
			#  with these tags (multiple tags should be comma-separated)
			# @option options [String] tags_mode tags search mode: "all" -- a
			#  video will only be listed if it has all tags specified in the
			#  tags parameter or "any" -- a video will be listed if it has at
			#  least one tag specified in the tags parameter
			# @option options [String] search case-insensitive search in the
			#  author, description, link, md5, tags, title and video_key fields
			# @option options [String] mediatypes_filter list only videos with
			#  the specified media types: "unknown", "audio", "video"
			# @option options [String] statuses_filter list only videos with the
			#  specified statuses: "created", "processing", "ready", "updating",
			#  "failed"
			# @option options [String] order_by specifies parameters by which
			#  returned result should be ordered; ":asc" and ":desc" can be
			#  appended accordingly
			# @option options [Integer] start_date video creation date starting
			#  from which videos list should be returned as a UNIX timestamp
			# @option options [Integer] end_date video creation date until
			#  (and including) which videos list should be returned as a UNIX
			#  timestamp
			# @option options [Integer] result_limit specifies maximum number of
			#  videos to return; default is 50 and maximum result limit is 1000
			# @option options [Integer] result_offset specifies how many videos
			#  should be skipped at the beginning of the result set; default is
			#  0
			#
			# @return [Array] a list of video objects matching the search
			#  criteria
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

			# Return a list of all videos.
			#
			# @note Same as calling `list` with no arguments given.
			def all
				list({})
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

		end

		attr_reader :last_status, :key, :link, :file, :title, :tags, :md5, :size,
					:description, :author, :date, :link, :download_url, :status,
					:views, :error, :sourcetype, :duration, :mediatype

		def initialize(params = {})
			params.each do |key, val|
				param = "@#{key.to_s}"
				next unless methods.include? key.to_sym
				instance_variable_set(param, val)
			end		
		end

		# Create a new video by sending metadata and requesting an upload URL.
		#
		# @param [Hash] options video parameters
		#
		# @option options [String] title title of the video
		# @option options [String] tags tags for the video; multiple tags should
		#  be comma-separated
		# @option options [String] description description of the video
		# @option options [String] author author of the video
		# @option options [Integer] date video creation date as UNIX timestamp
		# @option options [String] link the URL of the web page where this video
		#  is published
		# @option options [String] download_url URL from where to fetch a video
		#  file; only URLs with the http protocol are supported
		# @option options [String] md5 video file MD5 message digest
		# @option options [Integer] size video file size
		#
		# @return [BOTR::Video] this video object with the parameters specified in
		#  the options hash and an upload link
		def create(**options)
			json = get_request(options.merge(:method => 'create'))
			res = JSON.parse(json.body)

			if json.status == 200
				process_create_response(res)
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

		# Update the properties of a video.
		#
		# @param [Hash] options video parameters
		#
		# @option options [String] title title of the video
		# @option options [String] tags tags for the video; multiple tags should
		#  be comma-separated
		# @option options [String] description description of the video
		# @option options [String] author author of the video
		# @option options [Integer] date video creation date as UNIX timestamp
		# @option options [String] link the URL of the web page where this video
		#  is published
		# @option options [String] download_url URL from where to fetch a video
		#  file; only URLs with the http protocol are supported
		# @option options [String] md5 video file MD5 message digest
		# @option options [Integer] size video file size
		#
		# @return [BOTR::Video] this object with the properties of the
		#  video referenced by the options hash
		def update(**options)
			json = put_request(options.merge(:video_key => @key))
			res = JSON.parse(json.body)

			if json.status == 200
				process_update_response(res, options)
			else
				raise "HTTP Error #{json.status}: #{json.body}"
			end

			return self
		end

		# Remove a video and all of its conversions from the server.
		#
		# @return [BOTR::Video] this object with null properties
		def delete
			json = delete_request({:video_key => @key})
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
				@key = body["media"]["key"]
				@link = body["link"]
			end

			def process_upload_response(body)
				@last_status = body["status"]
				@file = body["file"]
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