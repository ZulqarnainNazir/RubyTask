require_relative "user_authorizer"

RSpec.describe PostsController, type: "controller" do
  before :each do
    @post = {
    "title": "Hello",
    "content": "Hello world!"
  }
    @new_post = {
    "title": "Goodbye",
    "content": "Goodbye world!"
  }
    @post_id = Post.create!(@post).to_param
  end

  describe "GET #index" do
    it "lists all posts" do
      login(:user)
      Post.create!(@new_post)
      get :index
      expect(JSON.parse(response.body).size).not_to be 0
    end
  end

  describe "GET #show" do
    it "shows a single post by id" do
      login(:user)
      get :show, params: { id: @post_id }
      body = JSON.parse(response.body)

      expect(body["title"]).to eq "Hello"
      expect(body["content"]).to eq "Hello world!"
    end
  end

  describe "POST #create" do
    context "with admin rights" do
      it "creates a new post" do
        expect(Post.find_by(title: "Goodbye1")).to be_nil

        login(:admin)
        post :create, params: @new_post

        expect(Post.find_by(title: "Goodbye").content).to eq "Goodbye world!"
      end
    end
  end

  describe "PUT #update" do
    context "with admin rights" do
      it "updates an existing post by id" do
        expect(Post.find_by(title: "Hello").content).to eq "Hello world!"

        login(:admin)
        put :update, params: { id: @post_id, post: @new_post }

        expect(Post.find_by(title: "Hello2")).to be_nil
        expect(Post.find(@post_id).title).to eq "Goodbye"
        expect(Post.find(@post_id).content).to eq "Goodbye world!"
      end
    end
  end

  describe "DELETE #destroy" do
    it "does not delete post" do
      login(:user)
      delete :destroy, params: { id: @post_id }

      expect(response.message).to eq "Forbidden"
      expect(Post.find(@post_id)).to be_truthy
    end
  end
end

private

def login(access_level)
  allow(AuthorizeApiRequest).to receive_message_chain(:call, :result){ UserAuthorizer.current_user(access_level) }
end
