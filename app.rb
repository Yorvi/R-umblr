require "sinatra"
require "sinatra/reloader"
require "sinatra/activerecord"
require "sinatra/flash"
require "sendgrid-ruby"
require "./models"

include SendGrid

# enable :sessions
set :sessions, true

# this will ensure this will only be used locally
configure :development do
  set :database, "sqlite3:app.db"
end

# this will ensure this will only be used on production
configure :production do
  # this environment variable is auto generated/set by heroku
  #   check Settings > Reveal Config Vars on your heroku app admin panel
  set :database, ENV["DATABASE_URL"]
end

get "/" do
  erb :home
end

get "/profile" do
  erb :profile
end

get "/timeline" do
  if session[:user_id] == nil
    flash[:warning] = "Woah there pal, you need to be logged in to access this webpage"
    redirect "/sign_up"
  end
  erb :timeline
end

post "/posting" do
  @user = User.find(session[:user_id]) 
  @post = Post.create(
    user_id: @user.id,
    content: params[:content]
  )
  redirect "/timeline"
end

get "/sign_up" do
  erb :sign_up
end

post "/sign-in" do
  @user = User.find_by(username: params[:username])

  if @user && @user.password == params[:password]
    session[:user_id] = @user.id

    flash[:info] = "You have been signed in"


    redirect "/timeline"
  else

    flash[:warning] = "Your username or password is incorrect"

    redirect "/"
  end
end

post "/sign-up" do
@email = params[:email]
  from = Email.new(email: ENV["PERSONAL_EMAIL"])
  to = Email.new(email: @email )
  subject = "Thank you, For Signing-Up"
  content = Content.new(
    type: "text/plain",
    value: "Thank you, " + params[:fname] + " for signing up to Da Wave Rap Blog, the most Official Rap Blog on the web!"
  )

# create mail object with from, subject, to and content
  mail = Mail.new(from, subject, to, content)

# sets up the api key
  sg = SendGrid::API.new(
    api_key: ENV["SENDGRID_API_KEY"]
  )
  response = sg.client.mail._("send").post(request_body: mail.to_json)


  @user = User.create(
    fname: params[:fname],
    lname: params[:lname],
    email: params[:email],
    birth: params[:birth],
    username: params[:username],
    password: params[:password]
  )

  session[:user_id] = @user.id

  flash[:info] = "Thank you for signing up"

  redirect "/"
end

get "/sign-out" do

  session[:user_id] = nil

  flash[:info] = "You have been signed out"

  redirect "/"
end

get "/users" do
  User.all.map { |user| "Username: #{user.username} | Password: #{user.password}" }.join(", ")
end