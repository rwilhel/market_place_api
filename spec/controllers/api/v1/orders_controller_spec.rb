require 'spec_helper'

describe Api::V1::OrdersController do

  describe "GET #index" do
    before(:each) do
      current_user = FactoryGirl.create :user
      api_authorization_header current_user.auth_token
      4.times { FactoryGirl.create :order, user: current_user }
      get :index, user_id: current_user.id
    end

    it "returns 4 order records from the user" do
      orders_response = json_response[:orders]
      expect(orders_response.count).to eq 4
    end

    it { should respond_with 200 }
  end

  describe "GET #show" do
    before (:each) do
      current_user = FactoryGirl.create :user
      api_authorization_header current_user.auth_token

      @product = FactoryGirl.create :product
      @order = FactoryGirl.create :order, user: current_user, product_ids: [@product.id]
      get :show, user_id: current_user.id, id: @order.id
    end

    it "returns the user order record matching the id" do
      order_response = json_response[:order]
      expect(order_response[:id]).to eq @order.id
    end

    it "includes the total for the order" do
      order_response = json_response[:order]
      expect(order_response[:total]).to eq @order.total.to_s
    end

    it "includes the products in the order" do
      order_response = json_response[:order]
      expect(order_response[:products].count).to eq 1
    end

    it { should respond_with 200 }
  end

  describe "POST #create" do
    before(:each) do
      current_user = FactoryGirl.create :user
      api_authorization_header current_user.auth_token

      product1 = FactoryGirl.create :product
      product2 = FactoryGirl.create :product
      order_params = { product_ids_and_quantities: [product1.id, 2], [product2.id, 3]] }
      post :create, user_id: current_user.id, order: order_params
    end

    it "returns the recent user order record" do
      order_response = json_response[:order]
      expect(order_response[:id]).to be_present
    end

    it "embeds the two product objects related to the order" do
      order_response = json_response[:order]
      expect(order_response[:products].size).to eq 2
    end

    it { should respond_with 201 }
  end
end
