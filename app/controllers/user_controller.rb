require 'digest/sha1'

class UserController < ApplicationController
  def signin
  end

  def post_signin
    @user = User.find_by_email(params[:user][:email])
    if (@user.nil?)
	reset_session
	logger.error("Invalid signin")
	flash[:notice] = "Invalid signin"
	redirect_to :action => 'signin'
    else
	@hashed_password = Digest::SHA1.hexdigest(params[:password])
	if (@hashed_password != @user.hashed_password)
		logger.error("Invalid password")
		flash[:notice] = "Invalid password"
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

  def register
  end

  def post_register
    @user = User.new
    @user.name = params[:user][:name]
    @user.email = params[:user][:email]
    @user.email_private = false
    @password = params[:password]
    @password_confirmation = params[:password_confirmation]
    @user.views = 0
    @user.total_views = 0
    @user.total_authored = 0;
    @user.likes = 0
    @user.summary = ""
    @user.image_file = "blank_profile_pic.jpg"
    @user.date_added = Time.new
    @user.date_modified = Time.now
    @user.interview_text =  "== Interview Form ==

Q: What's the best job you've had since graduation?
A:

Q: How did you find out about this job and why did you join?
A:

Q: What was the best part of the job?
A:

Q: What was the worst part of the job?
A:

Q: What do you wish you'd known before starting there?
A:

Q: What did you learn while there?
A:

Q: What are you most proud of during your time there?
A:

Q: Did you have any failures while there? How did you persevere?
A:

Q: What skills were most important for this job?
A:

Q: What's one story you tell about your time there?
A:

Q: If you are no longer working at this job, why did you leave?
A:
"
    flash[:notice] = nil
    if (@password != @password_confirmation)
	logger.error("Password confirmation must match password")
	flash[:notice] = "Password confirmation must match password"
      render (:action => :signin)
    elsif (@password.length < 1)
	logger.error("You must enter a password")
	flash[:notice] = "You must enter a password"
      render (:action => :signin)
    else
	match = User.find_by_email(@user.email)
	if not match.nil?
		logger.error("This user already exists")
		flash[:notice] = "This user already exists"
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
  end

  def round(term, val)
	term = (term * 10**val).to_i.to_f
	return (term / 10**val).to_s
  end

end