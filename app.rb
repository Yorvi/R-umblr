require "sinatra"
require "sinatra/reloader"
require "sinatra/activerecord"
require "sinatra/flash"
require "sendgrid-ruby"
require "./models"

include SendGrid

enable :sessions

set :database, "sqlite3:app.db"

get "/" do
  erb :home
end

get "/timeline" do
  erb :timeline
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