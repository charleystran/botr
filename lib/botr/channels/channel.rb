module BOTR

	# The BOTR::Channel class contains calls for creating new channels, searching
	# for channels, managing the channel properties (title, description etc.) and
	# deleting channels.
	class Channel < BOTR::Object

		class << self

			attr_reader :last_status

			# Show all information about a channel.
			#
 			# @param [String] channel_key key of the channel for which to show
 			# information
 			#
 			# @return [BOTR::Channel] a new object with the properties of the
 			#  channel referenced by the channel key
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

			# Return a list of channels, including their most interesting
			# properties.
			#
 			# @param [Hash] options search parameters
 			#
 			# @option options [String] types_filter specifies channel type by
 			#  which returned result should be filtered: "manual" or "dynamic"
 			# @option options [String] search case-insensitive search in the
 			#  author, channel_key, description, link, title fields and custom
 			#  fields
 			# @option options [String] order_by specifies parameters by which
			#  returned result should be ordered; ":asc" and ":desc" can be
			#  appended accordingly
			# @option options [Integer] result_limit specifies maximum number of
			#  channels to return; default is 50 and maximum result limit is 1000
			# @option options [Integer] result_offset specifies how many channels
			#  should be skipped at the beginning of the result set; default is
			#  0
 			#
 			# @return [BOTR::Channel] a new object with the properties of the
 			#  channel referenced by the channel key
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

			def all
				list({})
			end

			private

				def process_show_response(body)
					@last_status = body["status"]
					return body["channel"]
				end

				def process_list_response(body)
					res = []

					body["channels"].each do |channel|
						res << new(channel)
					end
					
					return res
				end

		end

		attr_reader :last_status, :key, :author, :title, :description, :link,
					:type, :tags, :tags_mode, :sort_order, :videos, :views

		def initialize(params = {})
			params.each do |key, val|
				param = "@#{key.to_s}"
				next unless methods.include? key.to_sym
				instance_variable_set(param, val)
			end		
		end

		# Create a new (dynamic or manual) channel.
		#
		# @param [String] type type of the channel: "dynamic" or "manual"
		# information
		# @param [Hash] options channel parameters
		#
		# @option options [String] title title of the channel
		# @option options [String] description description of the channel
		# @option options [String] link user defined URL
		# @option options [String] author author of the channel
		#
		# @return [BOTR::Channel] this object with the properties specified in
		#  the options hash
		def create(type, **options)
			json = get_request(options.merge(:method => 'create',
											 :type => type))
			res = JSON.parse(json.body)

			if json.status == 200
				process_create_response(res)
			else
				raise "HTTP Error #{json.status}: #{json.body}"
			end

			return self
		end

		# Configure or update the properties of a channel.
		#
		# @param [Hash] options channel parameters
		#
		# @option options [String] channel_key key of the channel which should
		#  be configured or updated
		# @option options [String] title title of the channel
		# @option options [String] description description of the channel
		# @option options [String] link user defined URL
		# @option options [String] author author of the channel
		# @option options [String] tags tags of the channel; restricts the
		#  inclusion of videos to the channel to the videos tagged with the
		#  specified tags
		# @option options [String] tags_mode tags search mode for the dynamic
		#  channel: "all" -- a video will only be added if it has all tags
		#  specified in the tags parameter or "any" -- a video will be added if
		#  it has at least one tag specified in the tags parameter
		# @option options [String] sort_order specifies sorting order of the
		#  videos in a dynamic channel: "date-asc", "date-desc", "title-asc",
		#  "title-desc", "duration-asc", "duration-desc", "views-asc" or
		#  "views-desc"
		# @option options [Integer] videos_max maximum number of videos to
		#  allow in a dynamic channel; default is 10
		#
		# @return [BOTR::Channel] this object with the properties specified in
		#  the options hash
		def update(**options)
			json = put_request(options.merge(:channel_key => @key))
			res = JSON.parse(json.body)

			if json.status == 200
				process_update_response(res, options)
			else
				raise "HTTP Error #{json.status}: #{json.body}"
			end

			return self
		end

		# Delete a channel.
		#
		# @return [BOTR::Channel] this object with null properties
		def delete
			json = delete_request({:channel_key => @key})
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
				@key = body["channel"]["key"]
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