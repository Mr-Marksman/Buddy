require 'rails_helper'

describe CommentsController, type: :controller do
  let(:user) { FactoryBot.create(:user) }
  let(:user_post) { FactoryBot.create(:post, user: user) }
  let(:comment) { FactoryBot.create(:comment, user: user, post: user_post) }

  describe 'POST #create' do
    context 'when user is signed in' do
      before { sign_in user }

      it 'creates a new comment' do
        expect {
          post :create, params: { post_id: user_post.id, comment: { body: 'New comment' } }
        }.to change(Comment, :count).by(1)
      end

      it 'sets the comment user to the current user' do
        post :create, params: { post_id: user_post.id, comment: { body: 'New comment' } }
        expect(assigns(:comment).user).to eq(user)
      end

      it 'redirects to the root path' do
        post :create, params: { post_id: user_post.id, comment: { body: 'New comment' } }
        expect(response).to redirect_to(root_path)
      end

      it 'sets the notice message' do
        post :create, params: { post_id: user_post.id, comment: { body: 'New comment' } }
        expect(flash[:notice]).to eq('Comment was successfully created.')
      end
    end

    context 'when user is not signed in' do
      it 'redirects to the sign in page' do
        post :create, params: { post_id: user_post.id, comment: { body: 'New comment' } }
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'PATCH #update' do
    context 'when user is signed in' do
      context 'when user can edit the comment' do
        before { sign_in user }
        before { allow(controller).to receive(:current_user_can_edit?).and_return(true) }

        it 'updates the comment' do
          put :update, params: { id: comment.id, post_id: user_post.id, comment: { body: 'Updated comment' } }
          comment.reload
          expect(comment.body).to eq('Updated comment')
        end

        it 'redirects to the post page with a notice' do
          put :update, params: { id: comment.id, post_id: user_post.id, comment: { body: 'Updated comment' } }
          expect(response).to redirect_to(root_path)
          expect(flash[:notice]).to eq('Комментарий успешно обновлен')
        end
      end

      context 'when user cannot edit the comment' do
        before { allow(controller).to receive(:current_user_can_edit?).and_return(false) }

        it 'does not update the comment' do
          put :update, params: { id: comment.id, post_id: user_post.id, comment: { body: 'Updated comment' } }
          comment.reload
          expect(comment.body).to_not eq('Updated comment')
        end

        it 'redirects sign_in' do
          put :update, params: { id: comment.id, post_id: user_post.id, comment: { body: 'Updated comment' } }
          expect(response).to redirect_to(new_user_session_path)
        end
      end
    end

    context 'when user is not signed in' do
      it 'redirects to sign in page' do
        put :update, params: { id: comment.id, post_id: user_post.id, comment: { body: 'Updated comment' } }
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'DELETE #destroy' do
    context 'when user is signed in' do
      before { sign_in user }

      context 'when user can edit the comment' do
        before { allow(controller).to receive(:current_user_can_edit?).and_return(true) }

        it 'destroys the comment' do
          delete :destroy, params: { id: comment.id, post_id: user_post.id }
          expect { comment.reload }.to raise_error ActiveRecord::RecordNotFound
        end

        it 'redirects to root with a notice' do
          delete :destroy, params: { id: comment.id, post_id: user_post.id }
          expect(response).to redirect_to(root_path)
          expect(flash[:notice]).to eq('Комментарий удален')
        end
      end

      context 'when user cannot edit the comment' do
        before { allow(controller).to receive(:current_user_can_edit?).and_return(false) }

        it 'does not destroy the comment' do
          delete :destroy, params: { id: comment.id, post_id: user_post.id }
          expect { comment.reload }.to_not raise_error
        end

        it 'redirects to root with an alert' do
          delete :destroy, params: { id: comment.id, post_id: user_post.id }
          expect(response).to redirect_to(root_path)
          expect(flash[:alert]).to eq("Ошибка при удалении комментария")
        end
      end
    end

    context 'when user is not signed in' do
      it 'redirects to sign in page' do
        delete :destroy, params: { id: comment.id, post_id: user_post.id }
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
