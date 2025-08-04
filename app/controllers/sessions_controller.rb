class SessionsController < ApplicationController
  skip_before_action :require_authentication, only: [ :new, :create ]

  def new
    redirect_to root_path if logged_in?
  end

  def create
    user = User.find_by(email_address: params[:email_address])

    if user && user.authenticate(params[:password])
      session[:user_id] = user.id
      respond_to do |format|
        format.html { redirect_to root_path, notice: "Signed in successfully" }
        format.json { render json: { message: "Signed in successfully" } }
      end
    else
      respond_to do |format|
        format.html {
          flash.now[:alert] = "Invalid email or password"
          render :new, status: :unprocessable_entity
        }
        format.json {
          render json: { error: "Invalid email or password" }, status: :unprocessable_entity
        }
      end
    end
  end

  def destroy
    session[:user_id] = nil
    respond_to do |format|
      format.html { redirect_to new_session_path, notice: "Signed out successfully" }
      format.json { render json: { message: "Signed out successfully" } }
    end
  end
end
