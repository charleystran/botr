require 'json'

module BOTR
	class Object

		include BOTR::HTTP
		include BOTR::API
		include BOTR::Authentication

		class << self
			
			include BOTR::HTTP
			include BOTR::API
			include BOTR::Authentication

			attr_accessor :threads
		end

	end
end