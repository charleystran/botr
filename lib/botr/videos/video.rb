module BOTR

	# The BOTR::Video class contains calls for creating (uploading) videos,
	# searching for videos, editing video metadata (title, description,
	# tags etc.) and deleting videos.
	#
	# A video object is a metadata container that actually contains multiple
	# video files (conversions). It does _not_ reference the actual video file
	# located on the content server.
	#
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
			#  tags parameter or "any" -- A video will be listed if it has at
			#  least one tag specified in the tags parameter
			#
			# @return [Array] a list of video object matching the search
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
			# @note Same as calling list with no arguments given.
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