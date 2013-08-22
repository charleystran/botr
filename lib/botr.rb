require 'botr/version'
require 'botr/configuration'
require 'botr/cli'

require 'botr/common/logger'

require 'botr/http/multipart'
require 'botr/http/http_response'
require 'botr/http/http_backend'
require 'botr/http/http'
require 'botr/http/uri_ext'

require 'botr/api/api'
require 'botr/api/authentication'

require 'botr/object'

require 'botr/videos/video'
require 'botr/videos/video_conversion'
require 'botr/videos/video_thumbnail'
require 'botr/videos/video_caption'
require 'botr/videos/video_tag'
require 'botr/videos/video_view'
require 'botr/videos/video_engagement'

require 'botr/channels/channel'
require 'botr/channels/channel_thumbnail'
require 'botr/channels/channel_video'
require 'botr/channels/channel_view'

require 'botr/players/player'
require 'botr/players/player_view'


ENV['SSL_CERT_FILE'] = File.expand_path('../..', __FILE__) + "/certs/cacert.pem"