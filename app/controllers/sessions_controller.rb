class SessionsController < ApplicationController
  def new; end

  def create
    user = User.find_by email: params[:session][:email].downcase
    if user&.authenticate params[:session][:password]
      if user.activated?
        log_in user
        checkbox_checked user
        flash[:success] = t ".success_login"
        redirect_back_or user
      else
        flash[:warning] = t "auths.mail.account_not_activated"
        redirect_to root_url
      end
    else
      flash.now[:danger] = t ".error_login"
      render :new
    end
  end

  def destroy
    log_out if logged_in?
    redirect_to root_url
  end

  private

  def checkbox_checked user
    params[:session][:remember_me] == Settings.checkbox_checked ? remember(user) : forget(user)
  end
end
