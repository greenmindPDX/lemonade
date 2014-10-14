require_relative 'keystorage'

module Zaphod
  class PhotoStorage < Keystorage
    @namespace = 'instagram_seen_media'
  end
end
