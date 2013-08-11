module BOTR

	class PlayerView < BOTR::Object

		class << self

			attr_reader :last_status

			def show(key, **options)
				json = get_request(options.merge(:method => 'show',
								    			 :player_key => key))
				res = JSON.parse(json.body)

				if json.status == 200
					params = process_show_response(res)
				else
					raise "HTTP Error #{json.status}: #{json.body}"
				end

				return new(params)
			end

			alias :find :show

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

					return body["player"]
				end

				def process_list_response(body)
					@last_status = body["status"]
					res = []

					if body["players"]
						body["players"].each do |player|
							res << new(player)
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

		attr_reader :last_status, :key, :name, :views, :date, :timestamp, :number,
					:months, :years

		def initialize(params = {})
			params.each do |key, val|
				param = "@#{key.to_s}"
				next unless methods.include? key.to_sym
				instance_variable_set(param, val)
			end		
		end

	end

end