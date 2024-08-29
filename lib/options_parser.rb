# frozen_string_literal: true

require "optparse"

class OptionsParser
  class << self
    def parse
      # Initialize options hash
      options = {
        month: nil,
        theme: nil,
      }

      # Parse command-line options
      OptionParser.new do |opts|
        opts.banner = "Usage: smashing.rb [options]"

        opts.on("--month MONTH", "Specify the month in MMYYYY format") do |month|
          options[:month] = month
        end

        opts.on("--theme THEME", "Specify the theme") do |theme|
          options[:theme] = theme
        end
      end.parse!

      # Validate the options
      unless options[:month] && options[:theme]
        $stderr.puts "Error: Both --month and --theme options are required."
        exit(1)
      end

      # puts "Month: #{options[:month]}"
      # puts "Theme: #{options[:theme]}"

      options
    end
  end
end
