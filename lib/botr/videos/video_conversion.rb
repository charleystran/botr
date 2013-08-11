module BOTR

	# The BOTR::VideoConversion class calls are used to create, search for and
	# delete individual video files (conversions) inside a video object.
	#
	# A conversion is always created by applying a transcoding template to a
	# video. A template contains information for the dimensions, bitrate and
	# watermark of the resulting conversion.
	class VideoConversion < BOTR::Object

		class << self

			attr_reader :last_status

			# Show video conversion information.
			#
 			# @param [String] conversion_key key of the conversion for which to
 			#  show information
 			#
 			# @return [BOTR::VideoConversion] a new object with the properties
 			#  of the conversion referenced by the conversion_key
			def show(conversion_key)
				json = get_request({:method => 'show',
								    :conversion_key => conversion_key})
				res = JSON.parse(json.body)

				if json.status == 200
					params = process_show_response(res)
				else
					raise "HTTP Error #{json.status}: #{json.body}"
				end

				return new(params)
			end

			alias :find :show

			# List conversions for a given video.
			#
			# @param [String] video_key key of the video for which to list
			# conversions
			# @param [Hash] options result parameters
			#
			# @option options [Integer] result_limit specifies maximum number of
			#  video conversions to return; default is 50 and maximum result
			#  limit is 1000
			# @option options [Integer] result_offset specifies how many video
			#  conversions should be skipped at the beginning of the result set;
			#  default is 0
			#
			# @return [Array] a list of video conversion objects for the given
			#  video key
			def list(key, **options)
				json = get_request(options.merge(:method => 'list',
												 :video_key => key))
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

					return body["conversion"]
				end

				def process_list_response(body)
					res = []

					body["conversions"].each do |conversion|
						res << new(conversion)
					end
					
					return res
				end

		end

		attr_reader :last_status, :key, :mediatype, :status, :duration,
					:filesize, :width, :height, :template, :error, :link

		def initialize(params = {})
			params.each do |key, val|
				param = "@#{key.to_s}"
				next unless methods.include? key.to_sym
				instance_variable_set(param, val)
			end
		end

		# Create a new conversion of a video.
		#
		# @param [String] video_key key of the video for which conversion should
		#  be created
		# @param [String] template_key key of the conversion template that
		#  should be used for this conversion.
		#
		# @return [BOTR::VideoConversion] this object with the properties
		#  of the conversion referenced by the template_key
		def create(video_key, template_key)
			json = get_request({:method => 'create',
								:video_key => video_key,
								:template_key => template_key})
			res = JSON.parse(json.body)

			if json.status == 200
				process_create_response(res)
			else
				raise "HTTP Error #{json.status}: #{json.body}"
			end

			return self
		end

		# Delete a video conversion from the CDN.
		#
		# @return [BOTR::VideoConversion] this object with null properties
		def delete
			json = delete_request({:conversion_key => @key})
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
				@key = body["conversion"]["key"]
			end

			def process_delete_response(body)
				@last_status = body["status"]
				instance_variables.each do |param|
					instance_variable_set(param, nil)
				end
			end

	end

end