# frozen_string_literal: true

require "base64"

class WallpaperMatcher
  MODEL = "claude-3-opus-20240229" # claude-3-opus-20240229, claude-3-sonnet-20240229
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
    content = wallpaper.preview
    imgbase64 = Base64.strict_encode64(content)
    response = client.messages(
      parameters: {
        model: MODEL,
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
    JSON.parse(response["content"][0]["text"])
  rescue Faraday::ServerError
    retries_count ||= 0
    retries_count += 1
    if retries_count < 3
      sleep(1 + retries_count)
      retry
    else
      raise
    end
  rescue Faraday::BadRequestError
    # something is wrong with image
    # example: https://files.smashing.media/articles/desktop-wallpaper-calendars-january-2024/jan-24-cheerful-chimes-city-preview-opt.jpg
    # image is good, is not corrupted, but the API does not like it
    # I'll skip it, but what can be done is if we try to resize it with MiniMagick and try again
    { "skip" => true }
  end

  private

  attr_reader :wallpaper, :theme

  def client
    @client ||= Anthropic::Client.new(access_token: ENV["AI_API_KEY"])
  end
end
