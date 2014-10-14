=begin
what do we need?
1. Support for Flickr upload
2. 60-second loop
3. integration testing
4. delete file after uploading
=end

require_relative 'photostorage'

module Zaphod
  class PhotoPoster
 
    def initialize(params,log)
      @params = params
    	@log = log ||= STDOUT
      # this is a demonstration only, polling one user.
      # in a robust application, we'd cache or hit an endpoint
      # to fetch the user-ids and access-tokens 
      # of all the users who had oauthed our apps. 
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
   
    def set_payload(data)
      @payload = { 
        'caption'   => data['caption']['text'], 
        'photo_url' => data['images']['standard_resolution']['url'],
        'title'     => "#{data['user']['username']}_#{data['created_time']}"
      }
      @log.debug("Payload is #{@payload}")
    end
 
    def upload_to_flickr!
      # download image to tmp
      # upload to flickr
      photo_path = download_from_instagram
      @log.debug("Path is #{photo_path}")
      flickr.access_token = @params['flickr_access_token']
      flickr.access_secret = @params['flickr_access_secret']
      #flickr.upload_photo photo_path, :title => @payload['title'], :description => @payload['caption'] 
      # push it into the Redii
      add_to_storage
      File.delete(photo_path)
    end

    def already_uploaded?
      false
      seen_before = Zaphod::PhotoStorage.get("seen_id_#{@post_id}","recommendation")
      true if seen_before && seen_before == @post_id
    end

    def add_to_storage
      redis_hash = { "recommendation" => @post_id }
      Zaphod::PhotoStorage.add("seen_id_#{@post_id}",redis_hash)
    end

    def download_from_instagram
      path = File.join(File.dirname(__FILE__),"tmp/#{@payload['title']}.jpg") 
      File.open(path, "wb") do |f| 
        f.write HTTParty.get(@payload['photo_url']).parsed_response
      end
      path
    end

  end
end