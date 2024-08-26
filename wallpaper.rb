# frozen_string_literal: true

require "fileutils"

class Wallpaper
  attr_reader :title, :description, :preview_url, :with_calendar_urls, :without_calendar_urls

  def initialize(html)
    @html = html
    @with_calendar_urls = []
    @without_calendar_urls = []

    parse!
  end

  def preview
    puts "Fetching preview image: #{preview_url}"
    HTTPX.with(timeout: { request_timeout: 15 }).get(preview_url).to_s
  end

  # example of link
  # https://www.smashingmagazine.com/files/wallpapers/feb-24/love-myself/nocal/feb-24-love-myself-nocal-1600x1200.jpg
  def store
    links = with_calendar_urls.take(2) + without_calendar_urls.take(2)
    links.each do |link|
      puts "  -> Downloading: #{link}"
      content = HTTPX.get(link).to_s
      folder = link.split("/").last(5)
      FileUtils.mkdir_p(folder[0..3].join("/"))
      File.write("#{folder.join("/")}.png", content)
    end
  end

  private

  attr_reader :html

  def parse!
    doc = Nokogiri::HTML(html)

    @title = doc.css("h2").text.strip
    @description = doc.css("p").text.strip
    @preview_url = doc.css("img").first["src"]

    lis = doc.css("ul li")
    li = lis.detect { _1.text.include?("with calendar") }
    @with_calendar_urls = li.css("a").map { |link| link["href"] } if li

    li = lis.detect { _1.text.include?("without calendar") }
    @without_calendar_urls = li.css("a").map { |link| link["href"] } if li
  end
end
