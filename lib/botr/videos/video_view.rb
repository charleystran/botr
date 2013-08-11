module BOTR

	# The BOTR::VideoView class contains calls for requesting video views
	# statistics.
	#
	# A video view is counted every time:
	# 
	# The video starts playing in one of your players.
	# The video starts downloading from our content server.
	# When a user scrubs through the video in a player or restarts the video, no
	# additional view is counted.
	class VideoView < BOTR::Object

		class << self

			attr_reader :last_status

			# Shows views statistics for a video.
			#
 			# @param [String] video_key key of the video for which to show views
 			#  statistics
 			# @params [Hash] options stats parameters
 			#
 			# @option options [Integer] start_date Unix timestamp of date
 			#  from which videos views statistics should be start
 			# @option options [Integer] end_date Unix timestamp of date
 			#  on which videos views statistics should be end
 			# @option options [String] aggregate specifies if returned video
 			#  views statistics should be aggregate: true or false
 			# @option options [String] group_days specifies if returned video
 			#  views statistics should be grouped by year and month
 			# @option options [String] include_empty_days specifies if video
 			#  views statistics should include days for which there is no
 			#  statistics available: true or false
 			#
 			# @return [BOTR::VideoView] a new object with the statistics for the
 			#  video referenced by the video_key
			def show(video_key, **options)
				json = get_request(options.merge(:method => 'show',
								    			 :video_key => video_key))
				res = JSON.parse(json.body)

				if json.status == 200
					params = process_show_response(res)
				else
					raise "HTTP Error #{json.status}: #{json.body}"
				end

				return new(params)
			end

			alias :find :show

			# List views statistics for a video.
			#
 			# @params [Hash] options stats parameters
 			#
 			# @option options [Integer] start_date Unix timestamp of date
 			#  from which videos views statistics should be start
 			# @option options [Integer] end_date Unix timestamp of date
 			#  on which videos views statistics should be end
 			# @option options [String] list_by specifies videos views statistics
 			#  listing type: "video" or "day"
 			# @option options [String] order_by specifies parameters by which
 			#  returned result should be ordered; ":asc" and ":desc" can be
			#  appended accordingly
			# @option options [String] search case-insensitive search in the
			#  author, description, link, md5, tags, title, video_key fields and
			#  custom fields
			# @option options [Integer] result_limit specifies maximum number
			#  of videos to return: default is 50 and maximum result limit is 1000.
			# @option options [Integer] result_offset specifies how many videos
			#  should be skipped at the beginning of the result set
 			# @option options [String] aggregate specifies if returned video
 			#  views statistics should be aggregate: true or false
 			# @option options [String] group_days specifies if returned video
 			#  views statistics should be grouped by year and month
 			# @option options [String] include_empty_days specifies if video
 			#  views statistics should include days for which there is no
 			#  statistics available: true or false
 			# @option options [String] statuses_filter list only videos with the
 			#  specified statuses: "active", "deleted"
 			#
 			# @return [Array] a list of objects with the statistics of the
 			#  all videos matching the search criteria
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

					return body["video"]
				end

				def process_list_response(body)
					@last_status = body["status"]
					res = []

					if body["videos"]
						body["videos"].each do |video|
							res << new(video)
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

		attr_reader :last_status, :key, :streams, :downloads, :views, :pageviews,
					:viewed, :title, :status, :date, :timestamp, :number, :total,
					:months, :days, :year

		def initialize(params = {})
			params.each do |key, val|
				param = "@#{key.to_s}"
				next unless methods.include? key.to_sym
				instance_variable_set(param, val)
			end		
		end

	end

end