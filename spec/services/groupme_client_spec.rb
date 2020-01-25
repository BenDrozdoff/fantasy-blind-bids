# frozen_string_literal: true

require "rails_helper"

RSpec.describe GroupmeClient do
  describe ".post_message" do
    subject(:post_message) { described_class.post_message("some text") }

    before do
      stub_request(:post, "https://api.groupme.com/v3/bots/post").with(
        body: { bot_id: "123456abc", text: "some text" }.to_json,
        headers: { "Content-Type" => "application/json" }
      ).to_return(status: 200, body: "", headers: {})
    end

    it "makes the right request to the groupme api" do
      post_message
    end
  end
end
