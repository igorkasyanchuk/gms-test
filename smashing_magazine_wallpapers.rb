# frozen_string_literal: true

require "date"

class SmashingMagazineWallpapers
  class InvalidOptionsError < StandardError; end
  class CannotDownloadError < StandardError; end

  attr_reader :wallpapers

  def initialize(dateinfo, theme)
    @month = dateinfo.chars[0..1].join.to_i
    @year = dateinfo.chars[2..5].join.to_i
    @theme = theme
    @wallpapers = []
  end

  # example
  # https://www.smashingmagazine.com/2024/07/desktop-wallpaper-calendars-august-2024/
  def download
    puts "Downloading wallpapers from: #{source_url}"

    response = HTTPX.get(source_url)
    if response.status == 200
      collect_wallpapers(response.to_s)
    else
      # fallback to the previous month (if wallpapers were published in the previous month)
      puts "Downloading wallpapers from: #{fallback_source_url} [FALLBACK]"
      response = HTTPX.get(fallback_source_url)
      if response.status == 200
        collect_wallpapers(response.to_s)
      end
    end

    if response.status != 200
      raise CannotDownloadError,
        "Unable to download wallpapers for #{month} with the theme: #{theme}, statys: #{response.status}"
    end
  end

  def collect_wallpapers(html)
    # "#article__content + (h2, p, figure, ul)" in the loop
    doc = Nokogiri::HTML(html)
    doc.css("#article__content h2").each do |h2|
      description_html = h2.next_element
      figure_html = description_html.next_element
      links_html = figure_html.next_element
      @wallpapers << Wallpaper.new(h2.to_s + description_html.to_s + figure_html.to_s + links_html.to_s)
    end
  end

  private

  attr_reader :month, :year, :theme

  def validate_options
    if month < 1 || month > 12
      raise InvalidOptionsError, "Invalid month: #{month}"
    end

    if year < 2000 || year > Date.today.year
      raise InvalidOptionsError, "Invalid year: #{year}"
    end
  end

  # https://www.smashingmagazine.com/2024/07/desktop-wallpaper-calendars-august-2024/
  def source_url
    base_source_url
  end

  # for example (published in January 2024, but for February 202)
  # https://www.smashingmagazine.com/2024/01/desktop-wallpaper-calendars-february-2024/
  def fallback_source_url
    previous_month = month - 1
    previous_year = year
    if previous_month == 0
      previous_month = 12
      previous_year -= 1
    end
    base_source_url(previous_month, previous_year)
  end

  def base_source_url(source_month = month, source_year = year)
    "https://www.smashingmagazine.com/#{source_year}/#{source_month.to_s.rjust(
      2,
      "0",
    )}/desktop-wallpaper-calendars-#{Date::MONTHNAMES[month].downcase}-#{year}/"
  end
end
