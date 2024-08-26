#!/usr/bin/env ruby
# frozen_string_literal: true

require "dotenv/load"
require "pry"
require "httpx"
require "nokogiri"
require "anthropic"

require_relative "options_parser"
require_relative "smashing_magazine_wallpapers"
require_relative "wallpaper"
require_relative "wallpaper_categorizer"

begin
  options = OptionsParser.parse
  collection = SmashingMagazineWallpapers.new(options[:month], options[:theme])
  collection.download
  collection.wallpapers.take(3).each do |wallpaper|
    # wallpaper.store
    puts wallpaper.preview_url
    WallpaperCategorizer.new(wallpaper, theme: options[:theme]).call
  end
rescue SmashingMagazineWallpapers::InvalidOptionsError => e
  puts "Error: #{e.message}"
  exit(1)
end
