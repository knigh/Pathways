require 'digest/sha1'

class UserController < ApplicationController

   layout 'standard'
   
     $master = Master.find(1)def signin
	flash[:notice] = nil
end 

  def post_signin
  	flash[:notice] = nil
    @user = User.find_by_email(params[:user][:email])
    if (@user.nil?)
	reset_session
	logger.error("Invalid email")
	flash[:notice] = "s: Invalid email"
	render :action => 'signin'
    else
	@hashed_password = Digest::SHA1.hexdigest(params[:password])
	if (@hashed_password != @user.hashed_password)
		logger.error("Invalid password")
		flash[:notice] = "s: Invalid password"
      	render (:action => :signin)
	else
		session[:user_id] = @user[:id];
		redirect_to("/profiles/view/#{@user[:id]}")
	end
    end
  end

  def logout
	reset_session
	redirect_to (:controller => :profiles, :action => :search)
  end


  def post_register
    @user = User.new
    @user.name = params[:user][:name]
    @user.email = params[:user][:email]
    @password = params[:password]
    @password_confirmation = params[:password_confirmation]
    @user.alum_interview_text = $master.alum_default_qs
    @user.student_interview_text = $master.student_defailt_qs
   
	flash[:notice] = nil
	
	if @user.name.length < 1
		logger.error("Name can't be blank")
		flash[:notice] = "r: Name can't be blank"
		render (:action => :signin)
		return
	elsif @user.email.length < 1
		logger.error("Email can't be blank")
		flash[:notice] = "r: Email can't be blank"
		render (:action => :signin)
		return
	end
	match = User.find_by_email(@user.email)
	if not match.nil?
		logger.error("Email is already in use")
		flash[:notice] = "r: Email is already in use"
		render (:action => :signin)
    elsif (@password != @password_confirmation)
		logger.error("Password confirmation must match password")
		flash[:notice] = "r: Password confirmation must match password"
		  render (:action => :signin)
    elsif (@password.length < 6)
		logger.error("Password must contain at least six characters")
		flash[:notice] = "r: Password must contain six or more characters"
		  render (:action => :signin)
    else
   	 	@user.hashed_password = Digest::SHA1.hexdigest(@password)
		if @user.save
			@user.author = @user.id
			@user.save
			@job = Job.new
			@job.user_id = @user[:id]
			@job.save

			session[:user_id] = @user[:id];
			redirect_to("/profiles/edit/#{@user[:id]}")	    	
		else
			render (:action => :signin)
		end
	end

  end

  def round(term, val)
	term = (term * 10**val).to_i.to_f
	return (term / 10**val).to_s
  end

end