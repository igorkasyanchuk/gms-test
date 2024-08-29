# frozen_string_literal: true

require "spec_helper"
require "open3"

RSpec.describe(Core) do
  context "when happy path" do
    before do
      FileUtils.rm_rf("wallpapers")
      allow(OptionsParser).to(receive(:parse).and_return(month: "022024", theme: "winter"))
    end

    it "can categorize and store wallpapers" do
      VCR.use_cassette("smashing_magazine_and_ai") do
        described_class.call
      end
      expect(Dir.glob("wallpapers/**/*.*")).to(eq(
        [
          "wallpapers/feb-24/national-kite-flying-day/cal/feb-24-national-kite-flying-day-cal-320x480.png",
          "wallpapers/feb-24/national-kite-flying-day/cal/feb-24-national-kite-flying-day-cal-640x480.png",
          "wallpapers/feb-24/national-kite-flying-day/nocal/feb-24-national-kite-flying-day-nocal-320x480.png",
          "wallpapers/feb-24/national-kite-flying-day/nocal/feb-24-national-kite-flying-day-nocal-640x480.png",
        ],
      ))
    end
  end
end
