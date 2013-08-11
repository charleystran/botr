module BOTR

	# The BOTR::VideoTag class contains calls for manipulating video tags.
	#
	# Tags are essentially labels that can be used for the classification of
	# videos.
	class VideoTag < BOTR::Object

		class << self

			attr_reader :last_status

			# Return a list of video tags.
			#
			# @param [Hash] options search parameters
			#
			# @option options [String] search case-insensitive search in the
			#  name tag field
			# @option options [String] order_by specifies parameters by which
			#  returned result should be ordered; ":asc" and ":desc" can be
			#  appended accordingly
			# @option options [Integer] result_limit specifies maximum number of
			#  tags to return; default is 50 and maximum result limit is 1000
			# @option options [Integer] result_offset specifies how many tags
			#  should be skipped at the beginning of the result set; default is
			#  0
			#
			# @return [Array] a list of tag objects matching the search
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

			def all
				list({})
			end

			private

				def process_list_response(body)
					res = []

					body["tags"].each do |tag|
						res << new(tag)
					end
					
					return res
				end

		end

		attr_reader :name ,:videos

		def initialize(params = {})
			params.each do |key, val|
				param = "@#{key.to_s}"
				next unless methods.include? key.to_sym
				instance_variable_set(param, val)
			end		
		end

	end

end