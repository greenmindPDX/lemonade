
require_relative 'photostorage'

@post_id = "7778"

redis_hash = { "recommendation" => @post_id }
      
Zaphod::PhotoStorage.add("seen_id_#{@post_id}",redis_hash)

seen = Zaphod::PhotoStorage.get("seen_id_#{@post_id}","recommendation")

puts seen