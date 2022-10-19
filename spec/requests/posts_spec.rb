require 'rails_helper'

RSpec.describe "Posts Requests", type: :request do
  describe '/posts/new' do
    it "succeeds" do
      get new_post_path
      expect(response).to have_http_status(:success)
    end
  end

  describe '/posts/create' do
    def create_post(title, body)
      post posts_path, params: {
        post: {
          title: title,
          body: body
        }
      }
    end

    context "valid params" do
      it "succesfully creates a post" do
        expect do
          create_post('title 1', 'body 1')
        end.to change { Post.count }.from(0).to(1)
        expect(response).to have_http_status(:redirect)
      end
    end

    context "invalid params" do
      it "failed at creating a post" do
        expect { create_post('', '') }.not_to change { Post.count }

        expect(Post.count).to eq(0)
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe 'posts/:id for show' do
    let(:post) { create(:post) }
    context 'passing in valid post id' do
      it 'succeeds' do
        get post_path(post)
        expect(response).to have_http_status(:success)
      end
    end

    context 'passing in invalid post id' do
      it 'fails' do
        expect { get post_path('qdsd') }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe 'edit post' do
    let(:post) { create(:post) }

    it 'succeeds' do
      get edit_post_path(post)
      expect(response).to have_http_status(:success)
    end
  end

  describe 'update post' do
    let(:post) { create(:post) }

    context 'valid update' do
      it 'success' do
        old_title = post.title
        new_title = "title updated"
        expect do
          put post_path(post), params: {
            post: {
              title: new_title
            }
          }
        end.to change { post.reload.title }.from(old_title).to(new_title)
        expect(response).to have_http_status(:redirect)
      end
    end

    context 'invalid update' do
      it 'not updated' do
        expect do
          put post_path(post), params: {
            post: {
              title: ''
            }
          }
        end.not_to change { post.reload.title }
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe 'delete post' do
    let(:post) { create(:post) }

    it 'deleted the post accordingly' do
      delete post_path(post)
      expect { Post.find(post.id) }.to raise_error(ActiveRecord::RecordNotFound)
      expect(response).to have_http_status(:redirect  )
    end
  end
end
