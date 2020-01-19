# frozen_string_literal: true

require "rails_helper"

RSpec.describe Bid, type: :model do
  describe "validations" do
    subject { build :bid, item: item, value: value }

    let(:item) { build :item, starting_price: 10 }

    context "and a value lower than the starting price" do
      let(:value) { 9 }

      it { is_expected.not_to be_valid }
    end

    context "and a value equal to the starting price" do
      let(:value) { 10 }

      it { is_expected.not_to be_valid }
    end

    context "and a value greater than the starting price" do
      let(:value) { 11 }

      it { is_expected.to be_valid }
    end
  end
end
