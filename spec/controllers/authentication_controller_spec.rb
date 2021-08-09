require 'rails_helper'
RSpec.describe AuthenticationController, type: :controller do
  before :each do
    @test_user = FactoryBot.create(:user, :admin)
  end

  describe "POST #login" do
    context "with correct credentials" do
      it "logs in a registered user" do
        post :login, params: { email: @test_user.email, password: @test_user.password }

        expect(response.message).to eq "OK"
        expect(response.body).to include("auth_token")
      end
    end

    context "with incorrect credentials" do
      it "returns error Unauthorized" do
        post :login, params: { email: @test_user["email"], password: "falsepassword" }

        expect(response.message).to eq "Unauthorized"
      end

      it "returns error Not Found" do
        post :login, params: { email: "nouser@email.com", password: "nopassword" }

        expect(response.message).to eq "Not Found"
      end
    end
  end
end
