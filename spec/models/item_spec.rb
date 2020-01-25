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

  describe "#expire!" do
    subject(:expire) { item.expire! }

    let(:item) { create :item, closes_at: 1.second.ago, status: status, starting_price: 1 }

    context "with an active item" do
      let(:status) { :active }

      context "with no bids" do
        it "sets the starting price and owner as the winner and final price" do
          expire
          item.reload
          expect(item).to be_expired
          expect(item.final_price).to eq 1
          expect(item.winner).to eq(item.owner)
        end
      end

      context "with a highest bid" do
        let!(:low_bid) { create :bid, item: item, value: 15 }
        let!(:high_bid) { create :bid, item: item, value: 30 }

        it "expires the item with the highest bid as the final price" do
          expire
          item.reload
          expect(item).to be_expired
          expect(item.final_price).to eq 30
          expect(item.winner).to eq(high_bid.user)
        end
      end
    end
  end
end
