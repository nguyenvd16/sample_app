class UsersController < ApplicationController
  before_action :logged_in_user, except: %i(new show create)
  before_action :find_user, only: %i(show edit destroy)
  before_action :correct_user, only: %i(edit update)
  before_action :admin_user, only: :destroy

  def index
    @users = User.page(params[:page]).per Settings.items_per_pages
  end

  def new
    @user = User.new
  end

  def show
    @microposts = @user.microposts.page(params[:page]).per Settings.items_per_pages
  end

  def create
    @user = User.new user_params
    if @user.save
      @user.send_activation_email
      flash[:info] = t "auths.mail.notice"
      redirect_to root_url
    else
      flash[:danger] = t ".fail_message"
      render :new
    end
  end

  def edit; end

  def update
    if @user.update user_params
      flash[:success] = t ".profile_updated"
      redirect_to @user
    else
      flash[:danger] = t ".update_failed"
      render :edit
    end
  end

  def destroy
    @user.destroy
    flash[:success] = t ".user_deleted"
    redirect_to users_url
  end

  private

  def user_params
    params.require(:user).permit User::USERS_PARAMS
  end

  def correct_user
    find_user
    redirect_to root_url unless current_user? @user
  end

  def admin_user
    redirect_to root_url unless current_user.admin?
  end
end
