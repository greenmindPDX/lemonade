=begin
what do we need?
2. 60-second loop
3. integration testing
=end

require_relative 'photostorage'

module Zaphod
  class PhotoPoster
 
    def initialize(params,log)
      @params = params
    	@log = log ||= STDOUT
      # NOTE ig_access_token and flickr tokens would come from an API endpoint
      # or cache pertaining to users who had oauthed this app.
      Instagram.configure do | instagram |
        instagram.client_id = @params['ig_client_id']
        instagram.access_token = @params['ig_access_token'] if @params.has_key?('ig_access_token')
      end
      FlickRaw.api_key=@params['flickr_key']
      FlickRaw.shared_secret=@params['flickr_shared_secret']
    end

    def run
      begin
        # @todo add 30s loop with logging
        @log.debug("making a first attempt")
        client = Instagram.client(:access_token => @params['ig_access_token'])
        recent_media = client.user_recent_media
        # above returns an array of Hashies
        recent_media.each do |media|
        data = media.to_hash
        @post_id = data["id"]
          # check redis for post_id
          unless already_uploaded?
            # if has 3 likes, send package to Flickr
            like_count = data['likes']['count'].to_i
            # remove narscisists
            like_count = like_count - 1 if data['user_has_liked']
            @log.debug("Like count is : #{like_count}")
            if like_count >= 3
              set_payload(data)
              upload_to_flickr!
            end 
          end  
        end 
      rescue Exception => e
      	@log.debug("Error with PhotoPoster: #{e}")
      	@log.debug("print out backtrace: #{e.backtrace}")
      end
    end  

    # creates a payload used throughout class.
    # Returns [Hash]
    def set_payload(data)
      @payload = { 
        'caption'   => data['caption']['text'], 
        'photo_url' => data['images']['standard_resolution']['url'],
        'title'     => "#{data['user']['username']}_#{data['created_time']}"
      }
      @log.debug("Payload is #{@payload}")
    end

    # uploads saved image to Flickr
    # adds post ID to redis store
    # deletes photo from tmp/
    def upload_to_flickr!
      # download image to tmp/
      photo_path = download_from_instagram
      @log.debug("Path is #{photo_path}")
      # upload to flickr
      flickr.access_token = @params['flickr_access_token']
      flickr.access_secret = @params['flickr_access_secret']
      response = flickr.upload_photo photo_path, :title => @payload['title'], :description => @payload['caption'] 
      @log.debug("Flickr Response = #{response}")
      # push it into the Redii and delete local version.
      add_to_storage
      File.delete(photo_path)
    end

    # Checks Redis to see if post ID exists
    # Returns [bool]
    def already_uploaded?
      false
      seen_before = Zaphod::PhotoStorage.get("seen_id_#{@post_id}","recommendation")
      if seen_before && seen_before == @post_id
        @log.debug("already uploaded ID #{seen_before}... skipping")
        true
      end
    end

    # add a specific post id to a new redis key
    def add_to_storage
      redis_hash = { "recommendation" => @post_id }
      Zaphod::PhotoStorage.add("seen_id_#{@post_id}",redis_hash)
    end

    #GETs an image from a URI and writes to tmp/
    def download_from_instagram
      path = File.join(File.dirname(__FILE__),"tmp/#{@payload['title']}.jpg") 
      File.open(path, "wb") do |f| 
        f.write HTTParty.get(@payload['photo_url']).parsed_response
      end
      path
    end

  end
end