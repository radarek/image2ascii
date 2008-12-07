require "rubygems"
require "rake"
require "echoe"

Echoe.new('ascii_art', '0.0.1') do |p|
  p.description    = "Gives ability to produce some nice ASCII arts (for example from images)"
  p.url            = "http://github.com/Radarek/ascii_art"
  p.author         = "Radosław Bułat"
  p.email          = "'moc.liamg@talub.kedar'.reverse"
  p.ignore_pattern = ["tmp/*", "script/*"]
  p.development_dependencies = []
end

Dir["#{File.dirname(__FILE__)}/tasks/*.rake"].sort.each { |ext| load ext }

