module BOTR

	class << self
		attr_accessor :configuration
	end

	def self.configure
		self.configuration ||= Configuration.new
		yield(configuration)
	end

	class Configuration

		attr_accessor :protocol, :server, :api_key, :secret_key

	end

end
