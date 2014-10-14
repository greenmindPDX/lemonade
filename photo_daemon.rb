# launches our photo recommendation engine
# usage bundle exec ruby photo_daemon.rb start
# tail log/poster.log to view output
require_relative 'init'
require_relative './lib/photo_poster'

log_path = File.join( File.dirname( File.absolute_path(__FILE__) ), "log/poster.log" )

Daemons.run_proc('photo') do
  begin    
    # @todo add flickr access token and secret
    cfg = {
      'flickr_access_token'  => '', 
      'flickr_access_secret' => '', 
      'flickr_key'           => ENV['FLICKR_KEY'],
      'flickr_shared_secret' => ENV['FLICKR_SHARED_SECRET'],
      'ig_access_token'      => ENV['IG_ACCESS_TOKEN'],
      'ig_client_id'         => ENV['IG_CLIENT_ID'],
    }
    log = Logger.new(log_path, "daily")
    log.level = Logger::DEBUG
    photo_poster = Zaphod::PhotoPoster.new( cfg, log )
    photo_poster.run
  rescue Exception => e
    log.fatal("help #{e}")
    log.fatal("Stack is #{e.backtrace}")
  end
end
