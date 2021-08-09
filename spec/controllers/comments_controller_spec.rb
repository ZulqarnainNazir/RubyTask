require_relative "user_authorizer"

RSpec.describe CommentsController, type: "controller" do
  before :each do
    @comment = { "name": "anonymA", "message": "foo bar" }
    @new_comment = { "name": "anonymB", "message": "foo bar" }

    @post = FactoryBot.create(:post)
    @post_id = @post.id
    @post_comments = @post.comments
    @post_comments.create!(@comment)

    @comment_id = @post_comments.first.id
    @new_comment_params = @new_comment.merge(post_id: @post_id)
  end

  describe "GET #index" do
    it "lists all comments of a post" do
      login(:user)
      Post.find(@post_id).comments.create!(@new_comment)
      get :index, params: { post_id: @post_id }

      expect(JSON.parse(response.body).size).to be 2
    end
  end

  describe "GET #show" do
    it "shows a single comment by id of a post" do
      login(:user)
      get :show, params: { post_id: @post_id, id: @comment_id }
      body = JSON.parse(response.body)

      expect(body["name"]).to eq "anonymA"
      expect(body["message"]).to eq "foo bar"
    end
  end

  describe "POST #create" do
    context "with admin rights" do
      it "creates a new comment" do
        expect(@post_comments.find_by(name: "anonymB")).to be_nil

        login(:admin)
        post :create, params: @new_comment_params

        expect(@post_comments.find_by(name: "anonymB").message).to eq "foo bar"
      end
    end

    context "without admin rights" do
      it "does not create comment" do
        login(:user)
        post :create, params: @new_comment_params

        expect(response.message).to eq "Forbidden"
        expect(@post_comments.find_by(name: "anonymB")).to be_nil
      end
    end
  end

  describe "PUT #update" do
    context "with admin rights" do
      it "updates an existing comment by id" do
        expect(@post_comments.find_by(name: "anonymA").message).to eq "foo bar"

        login(:admin)
        put :update, params: @new_comment_params.merge(id: @comment_id)

        expect(@post_comments.find_by(name: "anonymA")).to be_nil
        expect(@post_comments.find(@comment_id).name).to eq "anonymB"
        expect(@post_comments.find(@comment_id).message).to eq "foo bar"
      end
    end

    context "without admin rights" do
      it "does not update comment" do
        login(:user)
        put :update, params: @new_comment_params.merge(id: @comment_id)

        expect(response.message).to eq "Forbidden"
        expect(@post_comments.find_by(name: "anonymA").message).to eq "foo bar"
        expect(@post_comments.find_by(name: "anonymB")).to be_nil
      end
    end
  end

  describe "DELETE #destroy" do
    context "with admin rights" do
      it "deletes an existing comment by id of a post" do
        login(:admin)
        delete :destroy, params: { post_id: @post_id, id: @comment_id }

        expect(@post_comments.find_by(name: "anonymA")).to be_nil
      end
    end

    context "without admin rights" do
      it "does not delete comment" do
        login(:user)
        delete :destroy, params: { post_id: @post_id, id: @comment_id }

        expect(response.message).to eq "Forbidden"
        expect(@post_comments.find(@comment_id)).to be_truthy
      end
    end
  end
end

private

def login(access_level)
  allow(AuthorizeApiRequest).to receive_message_chain(:call, :result){ UserAuthorizer.current_user(access_level) }
end
