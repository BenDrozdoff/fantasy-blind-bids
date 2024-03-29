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
    let!(:user_pending_match_item) { create :item, :pending_match, auction: auction, owner: user }
    let!(:user_won_item) { create :item, :won, auction: auction, winner: user }

    describe ".available_to_user" do
      subject { described_class.available_to_user(user.id) }

      it { is_expected.to contain_exactly(available_item) }
    end

    describe ".active_belonging_to_user" do
      subject { described_class.active_belonging_to_user(user.id) }

      it { is_expected.to contain_exactly(user_active_item) }
    end

    describe ".won_by_user" do
      subject { described_class.won_by_user(user.id) }

      it { is_expected.to contain_exactly(user_won_item) }
    end

    describe ".available_to_match" do
      subject { described_class.available_to_match(user.id) }

      it { is_expected.to contain_exactly(user_pending_match_item) }
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

    around { |example| Timecop.freeze { example.run } }

    before { allow(ResultsGroupmeWorker).to receive(:perform_async) }

    context "with an item that has not closed yet" do
      let(:item) { create :item, closes_at: 3.hours.from_now, status: :active }

      it "does not change the item status" do
        expire
        item.reload
        expect(item).to be_active
        expect(item.final_price).to be_nil
        expect(item.winner).to be_nil
      end

      it "does not call the worker" do
        expire
        expect(ResultsGroupmeWorker).not_to have_received(:perform_async)
      end
    end

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

        it "sets the item to pending_match with the highest bid as the final price" do
          expire
          item.reload
          expect(item).to be_pending_match
          expect(item.final_price).to eq 30
          expect(item.closes_at).to eq(3.hours.from_now)
        end
      end

      context "with tied highest bids" do
        let!(:low_bid) { create :bid, item: item, value: 15 }
        let!(:high_bid_1) { create :bid, item: item, value: 30 }
        let!(:high_bid_2) { create :bid, item: item, value: 30 }

        it "sets the item to pending_match with the highest bid as the final price" do
          expire
          item.reload
          expect(item).to be_pending_match
          expect(item.final_price).to eq(30)
          expect(item.closes_at).to eq(3.hours.from_now)
        end
      end
    end

    context "with an item that was not matched" do
      let(:item) { create :item, status: :pending_match, closes_at: 1.second.ago, final_price: 30 }
      let!(:low_bid) { create :bid, item: item, value: 15 }
      let!(:high_bid) { create :bid, item: item, value: 30 }

      context "and the item has not closed yet" do
        let(:item) { create :item, status: :pending_match, closes_at: 1.hour.from_now, final_price: 30 }

        it "expires the item and sets the winner" do
          expire
          item.reload
          expect(item.winner).to eq(high_bid.user)
          expect(item).to be_expired
        end
      end

      context "with one high bidder" do
        it "expires the item and sets the winner" do
          expire
          item.reload
          expect(item.winner).to eq(high_bid.user)
          expect(item).to be_expired
        end
      end

      context "with multiple high bidders" do
        let!(:other_high_bid) { create :bid, item: item, value: 30 }

        it "sets the item to tied" do
          expire
          item.reload
          expect(item).to be_tied
        end
      end
    end

    context "with an already won item" do
      let(:status) { "expired" }

      it "does not call the groupme worker" do
        expire
        expect(ResultsGroupmeWorker).not_to have_received :perform_async
      end
    end

    context "with a tied item" do
      let(:status) { "tied" }

      it "does not call the groupme worker" do
        expire
        expect(ResultsGroupmeWorker).not_to have_received :perform_async
      end
    end
  end

  describe "#match!" do
    subject(:match!) { item.match! }

    before { allow(ResultsGroupmeWorker).to receive(:perform_async) }

    let(:item) { create :item, :pending_match }

    it "expires the item, sets the winner, and calls the groupme worker" do
      match!
      item.reload
      expect(item.winner).to eq(item.owner)
      expect(item).to be_expired
      expect(ResultsGroupmeWorker).to have_received(:perform_async).once.with item.id
    end

    context "with an arb2 item" do
      let(:item) { create :item, :pending_match, arb_status: :arb_2, final_price: 49 }

      it "expires the item, sets the winner, and updates the final price" do
        match!
        item.reload
        expect(item.winner).to eq(item.owner)
        expect(item).to be_expired
        expect(item.final_price).to eq(13)
        expect(ResultsGroupmeWorker).to have_received(:perform_async).once.with item.id
      end
    end

    context "with an arb3 item" do
      let(:item) { create :item, :pending_match, arb_status: :arb_3, final_price: 49 }

      it "expires the item, sets the winner, and updates the final price" do
        match!
        item.reload
        expect(item.winner).to eq(item.owner)
        expect(item).to be_expired
        expect(item.final_price).to eq(25)
        expect(ResultsGroupmeWorker).to have_received(:perform_async).once.with item.id
      end
    end
  end

  describe "#bid_report" do
    subject(:bid_report) { item.bid_report }

    let(:owner) { create :user, first_name: "joe", last_name: "sample" }

    context "for an item pending match" do
      context "and a single high bid" do
        let(:item) { create :item, :pending_match, owner: owner }

        it "includes the winner and pending match messages" do
          expect(bid_report).to include "#{item.bids.first.user.full_name} wins #{item.name} for $#{item.final_price}."
          expect(bid_report).to include "joe sample has 3 hours to match"
        end
      end

      context "and multiple high bids" do
        let(:item) { create :item, :pending_match_tied, owner: owner }

        it "describes the tie and includes the pending match message" do
          expect(bid_report).to include "tied on"
          expect(bid_report).to include "joe sample has 3 hours to match"
          expect(bid_report).to include "You've got to be bleepin kidding me!"
        end
      end
    end

    context "for an expired item" do
      context "with no bids" do
        let(:item) { create :item, owner: owner }
        let(:expected_text) do
          "You can put it on the board! No bids made for #{item.name}, remains with joe sample for $1."
        end

        it { is_expected.to eq expected_text }
      end

      context "for a matched item" do
        let(:item) { create :item, :matched, owner: owner }
        let(:expected_text) { "joe sample has matched #{item.name} for $15. Dagnabbit!" }

        it { is_expected.to eq expected_text }
      end

      context "for a won item with no match" do
        let(:item) { create :item, :won, owner: owner }
        let(:expected_text) { "foo" }

        it "indicates winner and no match" do
          expect(bid_report).to include "wins #{item.name}"
          expect(bid_report).to include "joe sample has chosen not to match"
          expect(bid_report).to include "He gone!"
        end
      end

      context "for a tied item with no match" do
        let(:item) { create :item, :tied, owner: owner }

        it "indicates tie and no match" do
          expect(bid_report).to include "tie"
          expect(bid_report).to include "joe sample has chosen not to match"
          expect(bid_report).to include "You've got to be bleepin kidding me!"
        end
      end
    end
  end
end
