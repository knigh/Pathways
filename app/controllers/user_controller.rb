require 'digest/sha1'

class UserController < ApplicationController

   layout 'standard'
   $master = Master.find(1)

  def signin
  	flash[:signup_notice] = nil
	flash[:signin_notice] = nil
	flash.keep(:id)
  end 

  def post_signin
  	flash[:signup_notice] = nil
	flash[:signin_notice] = nil
	flash.keep(:id)

    @user = User.find_by_email(params[:user][:email])
    if (@user.nil?)
	reset_session
	logger.error("Invalid email")
	flash[:signin_notice] = "Invalid email"
	render :action => 'signin'
    else
	@hashed_password = Digest::SHA1.hexdigest(params[:password])
	if (@hashed_password != @user.hashed_password)
		logger.error("Invalid password")
		flash[:signin_notice] = "Invalid password"
      	render (:action => :signin)
	else
		session["#{$master.url}_id"] = @user[:id];
		if flash[:id]
			redirect_to("/profiles/view/#{flash[:id]}")	    	
		else
			redirect_to("/profiles/view/#{@user[:id]}")	    	
		end
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
    @user.student_interview_text = $master.student_default_qs
   
	flash[:signup_notice] = nil
	flash[:signin_notice] = nil
	flash.keep(:id)
	
	if @user.name.length < 1
		logger.error("Name can't be blank")
		flash[:signup_notice] = "Name can't be blank"
		render (:action => :signin)
		return
	elsif @user.email.length < 1
		logger.error("Email can't be blank")
		flash[:signup_notice] = "Email can't be blank"
		render (:action => :signin)
		return
	end
	match = User.find_by_email(@user.email)
	if not match.nil?
		logger.error("Email is already in use")
		flash[:signup_notice] = "Email is already in use"
		render (:action => :signin)
    elsif (@password != @password_confirmation)
		logger.error("Password confirmation must match password")
		flash[:signup_notice] = "Password confirmation must match password"
		  render (:action => :signin)
    elsif (@password.length < 6)
		logger.error("Password must contain at least six characters")
		flash[:signup_notice] = "Password must contain six or more characters"
		  render (:action => :signin)
    else
   	 	@user.hashed_password = Digest::SHA1.hexdigest(@password)
		if @user.save
			@user.author = @user.id
			@user.save
			@job = Job.new
			@job.user_id = @user[:id]
			@job.save
			@degree = Degree.new
			@degree.user_id = @user[:id]
			@degree.save

			session["#{$master.url}_id"] = @user[:id];
			if flash[:id]
				redirect_to("/profiles/view/#{flash[:id]}")	    	
			else
				redirect_to("/profiles/edit/#{@user[:id]}")	    	
			end
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