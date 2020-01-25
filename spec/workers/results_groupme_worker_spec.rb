# frozen_string_literal: true

require "rails_helper"
RSpec.describe ResultsGroupmeWorker do
  describe "#perform" do
    subject(:perform) { described_class.new.perform(item.id) }

    before do
      allow(GroupmeClient).to receive(:post_message)
    end

    let(:item) { create :item }

    it "calls the GroupmeClient" do
      perform
      expect(GroupmeClient).to have_received(:post_message).once.with(item.bid_report)
    end
  end
end
