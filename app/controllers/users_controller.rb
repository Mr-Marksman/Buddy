class UsersController < ApplicationController
  def update_my_posts
    current_user.update(my_posts: params[:my_posts])
    redirect_to root_path
  end
end
