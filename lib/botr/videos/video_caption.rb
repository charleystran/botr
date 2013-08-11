module BOTR

	# The BOTR::VideoCaption class contains calls for manipulating videos captions.
	class VideoCaption < BOTR::Object

		class << self

			attr_reader :last_status

			# Show video caption information.
			#
 			# @param [String] caption_key key of the caption which information
 			#  to show
 			#
 			# @return [BOTR::VideoCaption] a new object with the properties of the
 			#  caption referenced by the caption_key
			def show(video_key)
				json = get_request({:method => 'show',
								    :caption_key => video_key})
				res = JSON.parse(json.body)

				if json.status == 200
					params = process_show_response(res)
				else
					raise "HTTP Error #{json.status}: #{json.body}"
				end

				return new(params)
			end

			alias :find :show

			# Return a list of videos captions.
			#
			# @param [Hash] options search parameters
			#
			# @option options [String] video_key key of the video which captions
			#  to list
			# @option options [String] search case-insensitive search in the
			#  caption key and label fields
			# @option options [String] statuses_filter list only captions with
			#  the specified statuses: "processing", "ready", "updating",
			#  "failed", "deleted"
			# @option options [String] order_by specifies parameters by which
			#  returned result should be ordered; ":asc" and ":desc" can be
			#  appended accordingly
			# @option options [Integer] result_limit specifies maximum number of
			#  captions to return; default is 50 and maximum result limit is 1000
			# @option options [Integer] result_offset specifies how many captions
			#  should be skipped at the beginning of the result set; default is
			#  0
			#
			# @return [Array] a list of video caption objects matching the search
			#  criteria
			def list(video_key, **options)
				json = get_request(options.merge(:method => 'list',
												 :video_key => video_key))
				res = JSON.parse(json.body)
				
				if json.status == 200
					results = process_list_response(res)
				else
					raise "HTTP Error #{json.status}: #{json.body}"
				end

				return results
			end

			private

				def process_show_response(body)
					@last_status = body["status"]

					return body["caption"]
				end

				def process_list_response(body)
					res = []

					body["captions"].each do |caption|
						res << new(caption)
					end
					
					return res
				end

		end

		attr_reader :last_status, :key, :label, :format, :link, :position,
					:md5, :status, :error

		def initialize(params = {})
			params.each do |key, val|
				param = "@#{key.to_s}"
				next unless methods.include? key.to_sym
				instance_variable_set(param, val)
			end		
		end

		# Create a new video caption.
		#
		# @param [String] video_key key of the video for which caption should be
		#  created
		# @param [Hash] options caption parameters
		#
		# @option options [String] label caption label
		# @option options [Integer] position indicates where to insert the new
		# caption; default is to insert at the end of the list
		# @option options [String] md5 caption file MD5 message digest
		# @option options [Integer] size caption file size
		#
		# @return [BOTR::VideoCaption] this video caption object with the
		#  parameters specified in the options hash and an upload link
		def create(video_key, **options)
			json = get_request(options.merge(:method => 'create',
											 :video_key => video_key))
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

		# Update video caption.
		#
		# @param [Hash] options caption parameters
		#
		# @option options [String] label caption label
		# @option options [Integer] position indicates where to insert the new
		# caption; default is to insert at the end of the list
		#
		# @return [BOTR::VideoCaption] this video caption object with the
		#  parameters specified in the options hash and an optional upload link
		def update(**options)
			json = put_request(options.merge(:caption_key => @key))
			res = JSON.parse(json.body)

			if json.status == 200
				process_update_response(res, options)
			else
				raise "HTTP Error #{json.status}: #{json.body}"
			end

			return self
		end

		# Delete a video caption.
		#
		# @return [BOTR::VideoCaption] this object with null properties
		def delete
			json = delete_request({:caption_key => @key})
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