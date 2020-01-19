# frozen_string_literal: true

require "rails_helper"

RSpec.describe Item, type: :model do
  describe "scopes" do
    let(:user) { create :user }
    let(:auction) { create :auction }
    let!(:available_item) { create :item, auction: auction }
    let!(:expired_item) { create :item, :won, auction: auction }
    let!(:user_active_item) { create :item, auction: auction, owner: user }
    let!(:user_expired_item) { create :item, :won, auction: auction, owner: user }
    let!(:user_won_item) { create :item, :won, auction: auction, winner: user }

    describe ".available_to_user" do
      subject { described_class.available_to_user(user.id) }

      it { is_expected.to contain_exactly(available_item) }
    end

    describe ".active_belonging_to_user" do
      subject { described_class.active_belonging_to_user(user.id) }

      it { is_expected.to contain_exactly(user_active_item) }
    end
  end

  describe "scheduling expiration" do
    around { |example| Timecop.freeze { example.run } }

    before { allow(ExpireItemWorker).to receive(:perform_at) }

    let(:item) { build :item, closes_at: 4.days.from_now }

    it "schedules an expiration job when the item saves" do
      item.save!
      expect(ExpireItemWorker).to have_received(:perform_at).once.with(4.days.from_now, item.id)
    end
  end
end
