# frozen_string_literal: true

require_relative "options_parser"
require_relative "wallpapers"
require_relative "wallpaper"
require_relative "wallpaper_matcher"

class Core
  class << self
    def call
      options = OptionsParser.parse
      collection = Wallpapers.new(options[:month], options[:theme])
      collection.download
      puts "..."
      collection.wallpapers.take(5).each do |wallpaper|
        response = WallpaperMatcher.new(wallpaper, theme: options[:theme]).call
        if response["skip"]
          puts "  -> SKIP (bad image)"
          puts
          next
        end
        puts "  -> AI recognized themes: #{response["themes"]}"
        puts "  -> AI matched: #{response["matched"]}"
        if response["matched"] == "yes"
          wallpaper.store
        else
          puts "  -> SKIP"
        end
        puts
      end
    rescue Wallpapers::InvalidOptionsError => e
      puts "Error: #{e.message}"
      exit(1)
    end
  end
end
