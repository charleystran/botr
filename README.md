# botr (BitsOnTheRun) [![Gem Version](https://badge.fury.io/rb/botr.png)](http://badge.fury.io/rb/botr) [![Dependency Status](https://gemnasium.com/bertrandk/botr.png)](https://gemnasium.com/bertrandk/botr) [![Code Climate](https://codeclimate.com/github/bertrandk/botr.png)](https://codeclimate.com/github/bertrandk/botr)

## Requirements

* Ruby 2.0.0 or above
* Some videos
* An internet connection

## Install

	gem install botr

## Description

A ruby API kit that manages the authentication, serialization and sending of API  
calls to the Bits on the Run online video platform. 

## Features

The botr gem includes support for the following Bits on the Run API classes:

* videos
* channels (video playlists)
* players (based on JW Player)

## Examples

    require 'botr'

### Configuration

```ruby
BOTR.configure do |config|
  config.api_key = "<botr_api_key>"
  config.secret_key = "<botr_secret_key>"
end

# NOTE: It is recommended to set the api key and the secret key as environment  
# variables and reference them using the `ENV` hash (e.g. config.api_key = ENV["BOTR_API_KEY"]).
```

### Videos

```ruby
# create a new video metadata container
vid = BOTR::Video.new
vid.create(title: "My cat video", author: "Me")

# upload actual video file
vid.upload("/Users/Me/Movies/grumpy_kitty.mov")

# update the properties of a video
vid.update(title: "My super awesome cat video", description: "Mr. Snicker  
apparently doesn't like being filmed.")

# delete a given video and all its conversions
vid.delete

# list all videos
BOTR::Video.all # => [#<BOTR::Video>, #<BOTR::Video>, ...]

# list only certain videos
BOTR::Video.list(search: "cat", order_by: "date")

# find a certain video by video key
cat_vid = BOTR::Video.show("<video_key>") # => #<BOTR::Video @key="[video_key]">
```

### Video Conversions

```ruby
# create a new video conversion
480p_vid = BOTR::VideoConversion.new
480p_vid.create("<video_key>", "<template_key>")

# delete a given video conversion from the CDN
480p_vid.delete

# list all video conversions for a given video
BOTR::VideoConversion.list("<video_key>", result_limit: 5)

# find a given video conversion by its conversion key
aac_vid = BOTR::VideoConversion.show("<conversion_key>")
```

### Video Thumbnails

```ruby
# find a video thumbnail
thumb = BOTR::VideoThumbnail.show("<video_key>")

# update a video's thumbnail
thumb.update(position: 7.25) # updates the video's thumbnail to the image at  
7.25 seconds

# upload a new video thumbnail
thumb.upload("/Users/Me/Pictures/snicker_smiles.png")
```

### Video Captions

```ruby
# create a new video caption
espanol = BOTR::VideoCaption.new
espanol.create(label: "esp")

# upload the actual caption file
espanol.upload("/Users/Me/Documents/grunon_gata.txt")

# update the video caption
espanol.update(label: "Spanish")

# delete a video caption
espanol.delete("<caption_key>")

# list the captions for a video
BOTR::VideoCaption.list("<video_key>", order_by: "label:asc")

# get the caption information for a video
cap = BOTR::VideoCaption.show("<video_key>")
```

### Video Tags

```ruby
# list a video's tags
BOTR::VideoTag.all

# search for video tags matching a certain criteria
BOTR::VideoTag.list(search: "kitty")
```

### Video Views

```ruby	
date = Time.new(2002, 10, 31)
unix_timestamp = date.to_i

# list view statistics by video
BOTR::VideoView.list(start_date: unix_timestamp)

# list view statistics by day
BOTR::VideoView.list(list_by: "day", group_days: false)

# list view statistics, grouping by day
BOTR::VideoView.list(list_by: "day", group_days: true)

# list view statistics in aggregate
BOTR::VideoView.list(list_by: "day", aggregate: true)

# find a video's statistics
BOTR::VideoView.show("<video_key>")
```

### Video Engagements

```ruby	
# display engagement analytics for a single video
BOTR::VideoEngagement.show("<video_key>")
```

### Channels (Playlists)

```ruby	
# create a manual playlist
my_picks = BOTR::Channel.new
my_picks.create(title: "My Picks", type: "manual")

# create a dynamic playlist
top_picks = BOTR::Channel.new
top_picks.create(title: "Trending", type: "automatic")

# add videos to a dynamic playlist
top_picks.update(description: "Top 10 videos", tags: "kitty",  
sort_order: "views-desc", videos_max: 10)

# delete a channel
top_picks.delete

# get a list of all channels
BOTR::Channel.all

# get a list of all dynamic "picks" channels
BOTR::Channel.list(types_filter: "dynamic", search: "top")

# get a specific channel
my_ch = BOTR::Channel.show("<channel_key>")
```

### Channel Videos

```ruby	
# get a list of videos in a channel
BOTR::ChannelVideo.list(top_picks.key)

# get video info. from a channel
second_vid = BOTR::ChannelVideo.show(my_picks.key, position: 2)

# remove a video from a manual channel
second_vid.delete

# add a video to a manual channel
snicker_falls = BOTR::ChannelVideo.new({key: "<video_key>"})
snicker_falls.create(my_picks.key)

# move a video to a different position in a manual channel
BOTR::ChannelVideo.update(my_picks.key, position_from: 10, position_to: 2)
```

### Channel Thumbnails

```ruby
# update a channel's thumbnail
new_tumb = BOTR::ChannelThumbnail.new({key: "<channel_key>"})
new_thumb.update
new_thumb.upload("/Users/Me/Pictures/splash.png")

# get the status of a video thumbnail creation (it takes about 10 seconds  
	before a new thumbnail is ready to show)
thumb_stat = BOTR::ChannelThumbnail.show("<channel_key>")
thumb_stat.status # => "ready"
```

### Channel Views

```ruby
# get view stats by channel
BOTR::ChannelView.list(list_by: "channel")

# get channel view stats by day
BOTR::ChannelView.list(list_by: "day", group_days: false)

# get channel view stats by grouped days (i.e. in months and years)
BOTR::ChannelView.list(list_by: "day", group_days: true)

# get aggregate channel view stats
BOTR::ChannelView.list(aggregate: true)

# get view stats for a specific channel
ch_stats = BOTR::ChannelView.show("<channel_key>", group_days: false)

# get view stats for a specific channel in months and years
ch_group_stats = BOTR::ChannelView.show("<channel_key>", group_days: true)

# get aggregate view stats for a specific channel
ch_report = BOTR::ChannelView.show("<channel_key>", aggregate: true)
```

### Players

```ruby	
# create a JW Player
new_player = BOTR::Player.new
new_player.create("Awesome Player", "<sharing_player_key>", autostart: false)

# update a player's settings
new_player.update(controlbar: bottom, repeat: always)

# delete a player
new_player.delete

# get a list of all players
BOTR::Player.all

# list only certain players
BOTR::Player.list(search: "awesome")

# get a specific player
my_player = BOTR::Player.show("<player_key>")
```

### Player Views

```ruby	
# get views by player
BOTR::PlayerView.list(list_by: "player")

# get views by day
BOTR::PlayerView.list(list_by: "day", group_days: flase, include_empty_days: true)

# get views by month and year
BOTR::PlayerView.list(list_by: "day", group_days: true)

# get aggregate player view
BOTR::PlayerView.list(aggregate: true)

# get view stats for a specific player
player_stats = BOTR::PlayerView.show("<player_key>", group_days: false)

# get view stats for a specific player in months and years
player_group_stats = BOTR::PlayerView.show("<player_key>", group_days: true)

# get aggregate view stats for a specific player
player_report = BOTR::PlayerView.show("<player_key>", aggregate: true)
```

## Todo

* Add support for accounts
* Add support for resumable file uploads
* Add support for content signing
* Enhance support for custom params
* Elegantly handle errors

## Additional Resources

For more information, see: http://developer.longtailvideo.com/botr

## Copyright

Copyright (c) 2013 Bertrand Karerangabo

See {file:LICENSE.txt} for details.
