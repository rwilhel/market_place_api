require 'spec_helper'

describe Product do
  let(:product) { FactoryGirl.build :product }
  subject { product }

  it { should respond_to(:title) }
  it { should respond_to(:price) }
  it { should validate_numericality_of(:price).is_greater_than_or_equal_to(0) }
  it { should respond_to(:published) }
  it { should respond_to(:user_id) }

  it { should_not be_published }
  it { should belong_to :user }

  describe '.filter_by_title' do
    before(:each) do
      @product1 = FactoryGirl.create :product, title: "A plasma TV"
      @product2 = FactoryGirl.create :product, title: "Fastest Laptop"
      @product3 = FactoryGirl.create :product, title: "CD player"
      @product4 = FactoryGirl.create :product, title: "LCD TV"
    end

    context "When a 'TV' title pattern is sent" do
      it "returns the 2 matching products" do
        expect(Product.filter_by_title("TV").count).to eq 2
      end

      it "reeturns the matching products" do
        expect(Product.filter_by_title("TV").sort).to match_array([@product1, @product4])
      end
    end
  end
end
