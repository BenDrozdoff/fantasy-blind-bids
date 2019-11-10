# frozen_string_literal: true

class GroupmeClient
  attr_reader :text
  ENDPOINT = "https://api.groupme.com/v3/bots/post"

  def initialize(text)
    @text = text
  end

  def self.post_message(text)
    new(text).post_message
  end

  def post_message
    connection.post do |req|
      req.headers["Content-Type"] = "application/json"
      req.body = { bot_id: bot_id, text: text }.to_json
    end
  end

  def bot_id
    @_bot_id ||= ENV.fetch("GROUPME_BOT_ID")
  end

  def connection
    @_connection ||= Faraday.new(ENDPOINT)
  end
end
