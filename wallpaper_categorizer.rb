# frozen_string_literal: true

require "base64"

class WallpaperCategorizer
  SYSTEM_PROMPT = %{
    You are about to categorize the image, and check if it matches requested theme. Please returns what theme you think this image belongs to.
  }
  USER_PROMPT = %{
    THEME TO CHECK: %{theme}
    IMAGE DESCRIPTION: %{description}
    Example of themes: animals, flowers, nature, etc.
    Example of matched: yes/no.
    Return response as JSON object with the following format: { "themes": "theme_name1,theme_name2,...", "matched": "yes" }.
    Return only a themes that best describes the image.
    Do not return text details or any other information.
  }

  def initialize(wallpaper, theme:)
    @wallpaper = wallpaper
    @theme = theme
  end

  def call
    # content = HTTPX.get("https://www.smashingmagazine.com/files/wallpapers/mar-24/breaking-superstitions/cal/mar-24-breaking-superstitions-cal-320x480.png").to_s
    content = wallpaper.preview
    imgbase64 = Base64.strict_encode64(content)
    response = client.messages(
      parameters: {
        model: "claude-3-5-sonnet-20240620", # claude-3-opus-20240229, claude-3-sonnet-20240229
        system: SYSTEM_PROMPT,
        messages: [
          {
            "role": "user",
            "content": [
              {
                "type": "image",
                "source":
                  {
                    "type": "base64",
                    "media_type": "image/png",
                    "data": imgbase64,
                  },
              },
              {
                "type": "text",
                "text": format(USER_PROMPT, theme:, description: wallpaper.description),
              },
            ],
          },
        ],
        max_tokens: 1024,
      },
    )
    sleep(0.5) # because of Faraday::TooManyRequestsError, I think because of the rate limit of the API on the free tier
    puts response["content"][0]["text"]
  rescue Faraday::ServerError
    retries_count ||= 0
    retries_count += 1
    if retries_count < 3
      sleep(1 + retries_count)
      retry
    else
      raise
    end
  end

  private

  attr_reader :wallpaper, :theme

  def client
    @client ||= Anthropic::Client.new(access_token: ENV["AI_API_KEY"])
  end
end
