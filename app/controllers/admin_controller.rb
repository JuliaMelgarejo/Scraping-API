class AdminController < ApplicationController
  before_action :set_user, only: [:update, :destroy]
  before_action :authenticate_user!
  before_action :authorize_admin!
  
  def index
    @users = User.all
    @user = User.new
  end

  def update
      if @user.update(user_params)
        redirect_to admin_index_path, notice: "User updated"
      else
        redirect_to admin_index_path, alert: "Unable to update User"
      end
  end

  def destroy
    if @user.destroy
    redirect_to admin_index_path, notice: "User deleted"
    else
    redirect_to admin_index_path, alert: "Unable to delete User"
    end
  end

  private

  def authorize_admin!
    redirect_to root_path, alert: 'Access Denied' unless current_user.admin?
  end

  def user_params
    params.require(:user).permit(:userName, :email, :password, :role)
  end
  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = User.find(params[:id])
  end


end
