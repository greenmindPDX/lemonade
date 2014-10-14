require 'rubygems'
require 'bundler/setup'
Bundler.require(:default, :development, :test)
require 'json'


BASE_DIR = File.expand_path('../', File.dirname(__FILE__))


require_relative File.expand_path('.', 'lib/photo_poster' )


%w{lib}.each do |path|
  Dir.glob("#{BASE_DIR}/#{path}/**/*rb").each{|f| require f}
end

RSpec.configure do |config|
  #config.color_enabled = true
  config.run_all_when_everything_filtered = true
  config.warnings = false
end


# Load /lib files
#load_path = File.join(BASE_DIR, '..', 'lib')
#paths = []
#paths << File.join(load_path, '/**/*.rb')
#paths.each do |path|
#  Dir.glob(path).each do |f|
##    require(f)
#  end
#end
