class PostsController < ApplicationController
  include ActiveStorage::SetCurrent
  before_action :authenticate_user!, except:  %i[index show]
  before_action :set_post, only: %i[show edit update destroy]

  def index
    @posts = params[:my_posts] == 'true' && user_signed_in? ? current_user.posts : Post.all
    @posts = @posts.joins(:hashtags).where(hashtags: { name: params[:hashtag] }) unless params[:hashtag].nil?
    @posts = @posts.order(created_at: :desc).page(params[:page]).per(4)
  end

  def new
    @post = current_user.posts.build
  end

  def create
    @post = current_user.posts.build(post_params)
    if @post.save
      hashtags = @post.description.scan(/#\w+/).map{ |tag| tag.gsub("#", "") }
      hashtags.each do |tag|
        hashtag = Hashtag.find_or_create_by(name: tag)
        PostHashtag.create(post: @post, hashtag: hashtag)
      end
      redirect_to posts_path, notice: 'Post was successfully created.'
    else
      render :new, alert: 'Post not created'
    end
  end

  def edit
  end

  def update
    if @post.update(post_params)
      @post.post_hashtags.destroy_all
      hashtags = @post.description.scan(/#\w+/).map{ |tag| tag.gsub("#", "") }
      hashtags.each do |tag|
        hashtag = Hashtag.find_or_create_by(name: tag)
        PostHashtag.create(post: @post, hashtag: hashtag)
      end
      redirect_to root_path, notice: 'Post was successfully updated.'
    else
      render :edit, alert: 'Post not updated'
    end
  end

  def destroy
    if current_user_can_edit?(@post)
      @post.destroy
      redirect_to root_path, notice: 'Post was successfully destroyed.', turbolinks: false
    else
      redirect_to root_path, alert: 'You cant do this', turbolinks: false
    end
  end

  private

  def set_post
    @post = Post.find(params[:id])
  end

  def post_params
    params.require(:post).permit(:title, :description, :image)
  end
end
