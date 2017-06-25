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
end
