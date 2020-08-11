class FollowingsController < ApplicationController
  before_action :logged_in_user, :find_user, only: :index

  def index
    @title = t "static_pages.home.following"
    @users = @user.following.page params[:page]
    render "users/show_follow"
  end
end
