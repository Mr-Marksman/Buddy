class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_post, except: %i[edit]
  before_action :set_comment, only: %i[destroy update]

  def create
    @comment = @post.comments.build(comment_params)
    @comment.user = current_user
    if @comment.save
      redirect_to root_path, notice: 'Comment was successfully created.'
    else
      render root_path, alert: 'something went wrong'
    end
  end

  def update
    if @comment.update(comment_params)
      redirect_to root_path, notice: 'Комментарий успешно обновлен'
    else
      redirect_to root_path, alert: 'Не удалось обновить комментарий'
    end
  end

  def destroy
    if current_user_can_edit?(@comment)
      @comment.destroy
      message = { notice: I18n.t("controllers.comments.destroyed") }
    else
      message = { alert: I18n.t("controllers.comments.error") }
    end

    redirect_to root_path, message
  end

  private

  def set_post
    @post = Post.find(params[:post_id])
  end

  def set_comment
    @comment = @post.comments.find(params[:id])
  end

  def comment_params
    params.require(:comment).permit(:body)
  end
end
