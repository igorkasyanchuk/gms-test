# frozen_string_literal: true

require "spec_helper"
require "open3"

RSpec.describe(OptionsParser) do
  let(:command) { "./smashing.rb" }

  context "with missing options" do
    it "returns an error when month is missing" do
      stdout, stderr, status = Open3.capture3("#{command} --theme animals")

      expect(status.success?).to(be(false))
      expect(stdout).to(be_empty)
      expect(stderr).to(include("Error: Both --month and --theme options are required."))
    end

    it "returns an error when theme is missing" do
      stdout, stderr, status = Open3.capture3("#{command} --month 022024")

      expect(status.success?).to(be(false))
      expect(stdout).to(be_empty)
      expect(stderr).to(include("Error: Both --month and --theme options are required."))
    end
  end
end
