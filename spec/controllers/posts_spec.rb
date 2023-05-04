require 'rails_helper'

describe PostsController, type: :controller do
  let(:user) { FactoryBot.create :user }
  let(:user_post) { FactoryBot.create :post, user: user }
  let(:other_user) { FactoryBot.create :user, email: 'test2@test.test' }
  let(:other_post) { FactoryBot.create :post, user: other_user }

  describe 'GET #index' do
    it 'returns http success' do
      get :index
      expect(response).to have_http_status(:success)
    end

    it 'renders the index template' do
      get :index
      expect(response).to render_template(:index)
    end

    it 'assigns @posts' do
      get :index
      expect(assigns(:posts)).not_to be_nil
    end

    it 'render only user posts if user ask' do
      get :index, params: { my_posts: true }
      expect(assigns(:posts)).to include(user_post)
      expect(assigns(:posts)).not_to include(other_post)
    end

    context 'when a hashtag parameter is provided' do
      before { get :index, params: { hashtag: 'ruby' } }

      it 'assigns posts with the matching hashtag to @posts' do
        expect(assigns(:posts)).to match_array([post1, post4])
      end

      it 'renders the index template' do
        expect(response).to render_template(:index)
      end
    end

    context 'when an invalid hashtag parameter is provided' do
      before { get :index, params: { hashtag: 'invalid' } }

      it 'assigns no posts to @posts' do
        expect(assigns(:posts)).to be_empty
      end

      it 'renders the index template' do
        expect(response).to render_template(:index)
      end
    end
  end

  describe 'GET #new' do
    context 'when user is signed in' do
      before { sign_in user }

      it 'returns http success' do
        get :new
        expect(response).to have_http_status(:success)
      end

      it 'renders the new template' do
        get :new
        expect(response).to render_template(:new)
      end

      it 'assigns @post' do
        get :new
        expect(assigns(:post)).not_to be_nil
      end
    end

    context 'when user is not signed in' do
      it 'redirects to the sign in page' do
        get :new
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'POST #create' do
    context 'when user signed id' do
      before { sign_in user }
      context 'with valid parameters' do
        it 'creates a new post' do
          expect {
            post :create, params: { post: { title: 'New post title', description: 'New post description' } }
          }.to change(Post, :count).by(1)
        end

        it 'redirects to the posts index page' do
          post :create, params: { post: { title: 'New post title', description: 'New post description' } }
          expect(response).to redirect_to(posts_path)
        end

        it 'sets the notice message' do
          post :create, params: { post: { title: 'New post title', description: 'New post description' } }
          expect(flash[:notice]).to eq('Post was successfully created.')
        end
      end

      context 'with invalid parameters' do
        it 'does not create a new post' do
          expect {
            post :create, params: { post: { title: '', description: '' } }
          }.not_to change(Post, :count)
        end

        it 'renders the new template' do
          post :create, params: { post: { title: '', description: '' } }
          expect(response).to render_template(:new)
        end
      end
    end

    context 'when user not signed in' do
      it 'does not create post' do
        expect {
          post :create, params: { post: { title: 'New post title', description: 'New post description' } }
        }.to change(Post, :count).by(0)
      end

      it 'redirects to the posts index page' do
        post :create, params: { post: { title: 'New post title', description: 'New post description' } }
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end