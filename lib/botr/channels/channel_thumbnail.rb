module BOTR

	# The BOTR::ChannelThumbnail class contains calls that can be used to upload
	# a preview image for a channel. Channels don’t have a thumb by default.
	class ChannelThumbnail < BOTR::Object

		class << self

			attr_reader :last_status

			# Show channel thumbnails creation status.
			#
 			# @param [String] channel_key key of the channel for which to show
 			#  thumbnails creation status
 			#
 			# @return [BOTR::ChannelThumbnail] a new object with the thumbnail
 			#  properties of the channel referenced by the channel key
			def show(channel_key)
				json = get_request({:method => 'show',
								    :channel_key => channel_key})
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

		# Update a channel thumbnail by uploading an image.
		#
		# @return [BOTR::ChannelThumbnail] this object with an upload URL
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