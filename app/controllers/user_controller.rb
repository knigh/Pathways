require 'digest/sha1'

class UserController < ApplicationController

  $student_interview = "== Student Interview Form ==

Q: What is your favorite thing you've done so far at Stanford?
A:

Q: Why did you choose your major?
A:

Q: What are your future plans?
A:
"
  $alum_interview = "== Alum Interview Form ==

Q: What is the best job you've had since graduation?
A:

Q: How did you find out about this job and why did you join?
A:

Q: What was the best part of the job?
A:

Q: What was the worst part of the job?
A:

Q: What do you wish you had known before starting there?
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
    @password = params[:password]
    @password_confirmation = params[:password_confirmation]
    @user.alum_interview_text = $alum_interview
    @user.student_interview_text = $student_interview
   
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