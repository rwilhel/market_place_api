require 'spec_helper'

describe Api::V1::ProductsController do
  describe "GET #show" do
    before(:each) do
      @product = FactoryGirl.create :product
      get :show, id: @product.id
    end

    it "returns the info about a reporter on a hash" do
      product_response = json_response[:product]
      expect(product_response[:title]).to eq @product.title
    end

    it { should respond_with 200 }

    it "has the user as an embedded object" do
      product_response = json_response[:product]
      expect(product_response[:user][:email]).to eq @product.user.email
    end
  end

  describe "GET #index" do
    before(:each) do
      4.times { FactoryGirl.create :product }
      get :index
    end

    context "when the action does not receive any product_ids parameters" do
      before(:each) do
        get :index
      end

      it "returns 4 records from the database" do
        products_response = json_response

        expect(products_response[:products].count).to eq(4)
      end

      it { should respond_with 200 }

      it "returns the user object into each product" do
        products_response = json_response[:products]
        products_response.each do |product_response|
          expect(product_response[:user]).to be_present
        end
      end
    end

    context "when the product_ids parameter is sent" do
      before(:each) do
        @user = FactoryGirl.create :user
        3.times { FactoryGirl.create :product, user: @user }
        get :index, product_ids: @user.product_ids
      end

      it "returns just the products that belong to the user" do
        products_response = json_response[:products]
        products_response.each do |product_response|
          expect(product_response[:user][:email]).to eq @user.email
        end 
      end
    end
  end

  describe "POST #create" do
    context "when a product is successfully created" do
      before(:each) do
        user = FactoryGirl.create :user
        @product_attributes = FactoryGirl.attributes_for :product
        api_authorization_header user.auth_token
        post :create, { user_id: user.id, product: @product_attributes }
      end

      it "renders the json representation for the product record just created" do
        product_response = json_response[:product]
        expect(product_response[:title]).to eq @product_attributes[:title]
      end

      it { should respond_with 201 }
    end

    context "when a product isn't created" do
      before(:each) do
        user = FactoryGirl.create :user
        @invalid_product_attributes = { title: "Smart TV", price: "Twelve dollars" }
        api_authorization_header user.auth_token
        post :create, { user_id: user.id, product: @invalid_product_attributes }
      end

      it "renders a json error" do
        product_response = json_response
        expect(product_response).to have_key(:errors)
      end

      it "renders json errors for why the user couldn't be created" do
        product_response = json_response
        expect(product_response[:errors][:price]).to include "is not a number"
      end

      it { should respond_with 422 }
    end
  end

  describe "DELETE #destroy" do
    before(:each) do
      @user = FactoryGirl.create :user
      @product = FactoryGirl.create :product, user: @user
      api_authorization_header @user.auth_token
      delete :destroy, { user_id: @user.id, id: @product.id }
    end

    it { should respond_with 204 }
  end
end
