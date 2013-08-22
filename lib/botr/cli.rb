require "thor"

module BOTR

	class CLI < Thor

		desc "upload VIDEO_PATH", "Uploads the video specified by VIDEO_PATH"
		long_desc <<-LONGDESC
	      Uploads the video specified by VIDEO_PATH. You must also provide an api KEY and an api SECRET.

	      With -t option, you may specify the title of the video.  

	      With -g option, you may specify tags for the video; multiple tags should be comma-separated.  

	      With -d option, you may specify a description for the video.  

	      With -a option, you may specify the author of the video.  

	      With -d option, you may specify the video creation date; the date must be in Unix timestamp format.  

	      With -l option, you may specify the URL of the web page where this video will be published.
	    LONGDESC
		option :key, :aliases => :k, :type => :string, :required => true
		option :secret, :aliases => :s, :type => :string, :required => true
		option :title, :aliases => :t, :type => :string
		option :tags, :aliases => :g, :type => :string
		option :description, :aliases => :d, :type => :string
		option :author, :aliases => :a, :type => :string
		option :date, :aliases => :d, :type => :numeric
		option :link, :aliases => :l, :type => :string
		def upload(video_path)
			_options = clean_options(options)
			set_configurations(_options[:key], _options[:secret])

			puts "\nStarting upload.\n\n"
			prepare_video_container(_options)

			puts "Uploading....\n\n"
			upload_video(video_path)
			
			puts "Upload Complete.\n\n"
		end

		private

			def clean_options(opt)
				opt.reject { |k, v| v.nil? }
			end

			def set_configurations(key, secret)
				BOTR.configure do |config|
					config.api_key = key
					config.secret_key = secret
				end
			end

			def prepare_video_container(opt)
				@video = BOTR::Video.new(opt)
				@video.create
			end

			def upload_video(video_path)
				@video.upload(video_path)
			end
	end

end