class UsersController < ApplicationController
  before_action :require_login,  only: [:show, :edit, :update]
  before_action :set_user,       only: [:show, :edit, :update, :destroy]
#doesn't allow access to other's page
  before_action :correct_user,   only: [:show, :edit, :update]
#allows access to other's page
  #before_action :require_logout, only: [:new]


  # GET /users
  # GET /users.json
  def index
    @users = User.all
  end

  # GET /users/1
  # GET /users/1.json
  def show
    @user = User.find(params[:id])
    @reviews = @user.reviews.paginate(page: params[:page])
  end

  # GET /users/new
  def new
    if logged_in?
      flash[:warning] = "You must be logged out to create a new user"
      redirect_to(root_url)
    end

    @user = User.new
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new( permitted_user_params )

    respond_to do |format|
      if @user.save
        log_in(@user)
        flash[:success] = 'User was successfully created.'
        format.html { redirect_to @user }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    @user = User.find(params[:id])
    respond_to do |format|
      if @user.update(user_params)
        flash[:success] = 'User was successfully updated.'
        format.html { redirect_to @user }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end


  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  def user_params
     params.require(:user).permit(:name, :email, :password,
                                  :password_confirmation)
   end
    # Never trust parameters from the scary internet, only allow the white list through.
    def permitted_user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    def require_login
      unless logged_in?
        flash[:danger] = "You must be logged in to access this section"
        redirect_to root_url # halts request cycle
      end
    end

    # Confirms the correct user.
    def correct_user

      @user = User.find(params[:id])

      unless current_user?(@user)
        flash[:warning] = "You are not allowed to enter other people's page"
        redirect_to(root_url)
      end
    end

    def require_logout
      if logged_in?
        flash[:warning] = "You must be logged out to create a new user"
        redirect_to(root_url)
      end
    end
    # Confirms an admin user.
    def admin_user
      redirect_to(root_url) unless current_user.admin?
    end
end
