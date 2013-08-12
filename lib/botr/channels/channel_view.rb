module BOTR

	# The BOTR::ChannelView class contains calls for requesting channel views
	# statistics.
	#
	# A channel view is counted every time:
	#
	# The RSS feed of that channel is requested from the content server.
	# A player from our content server containing a channel is embedded in a
	# webpage.
	class ChannelView < BOTR::Object

		class << self

			attr_reader :last_status
			
			# Shows views statistics for a channel.
			#
 			# @param [String] channel_key key of the channel for which to show
 			# information
 			# @param [Hash] options channel views parameters
 			#
 			# @option options [Integer] start_date Unix timestamp of date
 			#  from which channel views statistics should be start
 			# @option options [Integer] end_date Unix timestamp of date
 			#  on which channel views statistics should be end
 			# @option options [String] aggregate specifies if returned channel
 			#  views statistics should be aggregate: true or false
 			# @option options [String] group_days specifies if returned channel
 			#  views statistics should be grouped by year and month
 			# @option options [String] include_empty_days specifies if channel
 			#  views statistics should include days for which there is no
 			#  statistics available: true or false
 			#
 			# @return [BOTR::ChannelView] a new object with the view statistics
 			#  of the channel referenced by the channel key
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

			# List channel views statistics per channel or per day.
			#
 			# @params [Hash] options stats parameters
 			#
 			# @option options [Integer] start_date Unix timestamp of date
 			#  from which channel views statistics should be start
 			# @option options [Integer] end_date Unix timestamp of date
 			#  on which channel views statistics should be end
 			# @option options [String] list_by specifies channel views statistics
 			#  listing type: "channel" or "day"
 			# @option options [String] order_by specifies parameters by which
 			#  returned result should be ordered; ":asc" and ":desc" can be
			#  appended accordingly
			# @option options [Integer] result_limit specifies maximum number
			#  of channels to return: default is 50 and maximum result limit is
			#  1000
			# @option options [Integer] result_offset specifies how many channels
			#  should be skipped at the beginning of the result set
 			# @option options [String] aggregate specifies if returned channel
 			#  views statistics should be aggregate: true or false
 			# @option options [String] group_days specifies if returned channel
 			#  views statistics should be grouped by year and month
 			# @option options [String] include_empty_days specifies if channel
 			#  views statistics should include days for which there is no
 			#  statistics available: true or false
 			#
 			# @return [Array] a list of objects with the statistics of the
 			#  all channels matching the given criteria
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
					@last_status = body["status"]
					res = []

					if body["channels"]
						body["channels"].each do |channel|
							res << new(channel)
						end
					elsif body["days"]
						body["days"].each do |day|
							res << new(day)
						end
					elsif body["years"]
						body["years"].each do |year|
							res << new(year)
						end
					else
						res << new(body)
					end

					return res
				end

		end

		attr_reader :last_status, :key, :days, :years, :views, :title, :date,
					:timestamp, :number, :year, :number, :total

		def initialize(params = {})
			params.each do |key, val|
				param = "@#{key.to_s}"
				next unless methods.include? key.to_sym
				instance_variable_set(param, val)
			end		
		end

	end

end