class AccountController < ActionController::Base
  # TODO: Add Signup, Login, Logout Routes
  def signup
    if user_params[:email].nil? or user_params[:name].nil? or user_params[:password].nil?
      render json: 'Required field', status: :bad_request
      return
    end
    user = User.new(user_params)
    if user.save
      response.headers['authorization'] = user.auth_token
      render json: user, status: :ok
    else
      render json: user.errors, status: :error
    end
  end
  
  def login
    if user_params[:email].nil? or user_params[:password].nil?
      render json: 'Required field', status: :bad_request
      return
    end
    user = User.find_by(email: user_params[:email])
    if user && user.authenticate(user_params[:password])
      response.headers['authorization'] = user.auth_token
    else
      render json: user.errors, status: :error
    end
  end
  
  def logout
    head :no_content
  end
  
  private

  def user_params
    params.require(:data).permit( :name, :email, :password )
  end
end

class AlbumsController < ActionController::Base
  before_action :set_album, only: [:show, :update, :destroy]
  before_action :set_user, only: [:create, :update, :destroy]
  
  def create
    # TODO
    @album = Album.new(album_params)
    if @album.save
      render json: @album, status: :ok
    else
      render json: @album.errors, status: :error
    end
  end
  
  def show
    # TODO
    if @album
      render json: @album, status: :ok
    else
      render json: @album.errors, status: :error 
    end
  end

  def index 
    # TODO
    @albums = Album.all
    if @albums
      render json: @albums, status: :ok
    else
      render json: @albums.errors, status: :error
    end
  end
  
  def update
    # TODO      
    if @album.update(album_params)
      render json: @album, status: :ok
    else
      render json: @album.errors, status: :error
    end
  end
  
  def destroy
    # TODO
    if @album.destroy
      head :no_content
    else
      render json: @album.errors, status: :error
    end
  end
  
  private
  
  def set_user
    user = User.find_by(auth_token: request.headers["authorization"])
    if user.nil?
      render json: 'Invalid Token', status: :unauthorized
    end
  end

  def set_album
    @album = Album.find(params[:id])
  end
  
  def album_params
    params.require(:data).permit(:title, :performer, :cost)
  end
end
  
class PurchasesController < ActionController::Base
  def create
    # TODO
    @purchase = Purchase.new(purchase_params)
    if @purchase.save
      render json: @purchase, status: :ok
    else
      render json: @purchase.errors, status: :error
    end
  end
  
  private

  def purchase_params
    params.require(:data).permit(:user_id, :album_id)
  end
end

ActiveRecord::Schema.define do
  # TODO: define schema
  create_table "albums", force: :cascade do |t|
    t.string "title"
    t.string "performer"
    t.integer "cost"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "purchases", force: :cascade do |t|
    t.integer "album_id"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["album_id"], name: "index_purchases_on_album_id"
    t.index ["user_id"], name: "index_purchases_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "password_digest"
    t.string "auth_token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["auth_token"], name: "index_users_on_auth_token", unique: true
  end
end

class Album < ActiveRecord::Base
  # TODO: define Album model
  has_many :purchases
end

class Purchase < ActiveRecord::Base
  # TODO: define Purchase model
  belongs_to :album
  belongs_to :user
end

class User < ActiveRecord::Base
  # TODO: define User model
  has_secure_password
  has_secure_token :auth_token
  has_many :purchases
end