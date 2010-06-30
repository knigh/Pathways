require 'digest/sha1'

class UserController < ApplicationController
	
	layout 'standard'
	$master = Master.find(1)
	
	def signin
		createNewLogEntry(request.request_uri)
		flash[:signup_notice] = nil
		flash[:signin_notice] = nil
		flash.keep(:url)
		
		@email_authentication = false
		if $master.admin_email != ""
			@email_authentication = true
			if (flash[:alert] == "" or not flash[:alert])
				flash[:alert] = "Sign up is only available for Stanford students and alumni.<br/>If you have a Stanford or Stanford Alumni email account, use it.<br/>Otherwise, your email will have to be verified by the " + $master.formal_name + " administrators."
			end
		end
	end
	
	def post_signin
		flash[:signup_notice] = nil
		flash[:signin_notice] = nil
		flash.keep(:url)
		
		@email_authentication = false
		if $master.admin_email != ""
			@email_authentication = true
			if (flash[:alert] == "" or not flash[:alert])
				flash[:alert] = "Sign up is only available for Stanford students and alumni.<br/>If you have a Stanford or Stanford Alumni email account, use it.<br/>Otherwise, your email will have to be verified by the " + $master.formal_name + " administrators."
			end
		end
		
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
				render(:action => :signin)
			else
				session["#{$master.url}_id"] = @user[:id];
				session["#{$master.url}_user_type"] = @user[:user_type];
				if flash[:url]
					redirect_to(flash[:url])	    	
				else
					redirect_to("/profiles/view/#{@user[:id]}")	    	
				end
			end
		end
	end
	
	def post_publish
        flash[:signup_notice] = nil
        flash[:signin_notice] = nil
        flash.keep(:url)
		
		@user = User.find_by_email(params[:user][:email])
		if (@user.nil?)
			reset_session
			logger.error("Invalid email")
			flash[:signin_notice] = "Invalid email"
			render :action => 'signin'
		else
			@hashed_password = params[:temp]
			if (@hashed_password != @user.hashed_password)
                logger.error("Invalid password")
                flash[:signin_notice] = "Invalid password"
				render(:action => :signin)
			else
                session["#{$master.url}_id"] = @user[:id];
				session["#{$master.url}_user_type"] = @user[:user_type];
                if flash[:url]
					redirect_to(flash[:url])
				else
					redirect_to("/profiles/view/#{@user[:id]}")
				end
			end
		end
	end
	
	def post_signup
        flash[:signup_notice] = nil
        flash[:signin_notice] = nil
        flash.keep(:url)
		
		@user = User.find_by_email(params[:user][:email])
		if (@user.nil?)
			reset_session
			logger.error("Invalid email")
			flash[:signin_notice] = "Invalid email"
			render :action => 'signin'
		else
			@hashed_password = params[:temp]
			if (@hashed_password != @user.hashed_password)
                logger.error("Invalid password")
                flash[:signin_notice] = "Invalid password"
				render(:action => :signin)
			else
                session["#{$master.url}_id"] = @user[:id];
				session["#{$master.url}_user_type"] = @user[:user_type];
                if flash[:url]
					redirect_to(flash[:url])
				else
					redirect_to("/profiles/edit/#{@user[:id]}")
				end
			end
		end
	end
	
	
	def logout
		createNewLogEntry(request.request_uri)
		reset_session
		redirect_to(:controller => :profiles, :action => :search)
	end
	
	def post_register
	
		if $master.admin_email != ""
			post_register_email
			return
		end
	
		@user = User.new
		@user.name = params[:user][:name]
		@user.email = params[:user][:email]
		@password = params[:password]
		@password_confirmation = params[:password_confirmation]
		@user.alum_interview_text = $master.alum_default_qs
		@user.student_interview_text = $master.student_default_qs
		@user.date_added = Time.now
		@user.date_modified = Time.now
		@user.interview_date = Time.now
		@user.question_asked = DateTime.new(Time.now.year - 1, 1, 1)
		
		@user.approved = 1;
		
		flash[:signup_notice] = nil
		flash[:signin_notice] = nil
		flash.keep(:url)
		
		if @user.name.length < 1
			logger.error("Name can't be blank")
			flash[:signup_notice] = "Name can't be blank"
			render(:action => :signin)
			return
		elsif @user.email.length < 1
			logger.error("Email can't be blank")
			flash[:signup_notice] = "Email can't be blank"
			render(:action => :signin)
			return
		end
		match = User.find_by_email(@user.email)
		if not match.nil?
			logger.error("Email is already in use")
			flash[:signup_notice] = "Email is already in use"
			render(:action => :signin)
		elsif (@password != @password_confirmation)
			logger.error("Confirmation must match password")
			flash[:signup_notice] = "Confirmation must match password"
			render(:action => :signin)
		elsif (@password.length < 6)
			logger.error("Password must contain at least six characters")
			flash[:signup_notice] = "Password must contain six or more characters"
			render(:action => :signin)
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
				session["#{$master.url}_user_type"] = @user[:user_type];
				if flash[:url]
					redirect_to(flash[:url])	    	
				else
					redirect_to("/profiles/edit/#{@user[:id]}")	    	
				end
			else
				render(:action => :signin)
			end
		end
		
	end
	
	def post_register_email
	
		# start creating a user
		@user = User.new
		@user.name = params[:user][:name]
		@user.email = params[:user][:email]
		
		# create a temporary password
		@password = getPassword(@user.name)
		
		@user.alum_interview_text = $master.alum_default_qs
		@user.student_interview_text = $master.student_default_qs
		@user.date_added = Time.now
		@user.date_modified = Time.now
		@user.interview_date = Time.now
		@user.question_asked = DateTime.new(Time.now.year - 1, 1, 1)
		@user.approved = 1;
		
		flash[:signup_notice] = nil
		flash[:signin_notice] = nil
		flash.keep(:url)
		
		if @user.name.length < 1
			logger.error("Name can't be blank")
			flash[:signup_notice] = "Name can't be blank"
			render(:action => :signin)
			return
		elsif @user.email.length < 1
			logger.error("Email can't be blank")
			flash[:signup_notice] = "Email can't be blank"
			render(:action => :signin)
			return
		end
		match = User.find_by_email(@user.email)
		if not match.nil?
			logger.error("Email is already in use")
			flash[:signup_notice] = "Email is already in use"
			render(:action => :signin)
		else
			@user.hashed_password = Digest::SHA1.hexdigest(@password)
			
			# determine if the email address is either stanford[alumni] or other
			regex1 = Regexp.new(/\w+@stanford\.edu/i)
			regex2 = Regexp.new(/\w+@stanfordalumni\.org/i)
		
			if (regex1.match(@user.email) or regex2.match(@user.email))
				@user.save
				@user.author = @user.id
				@user.save
				@job = Job.new
				@job.user_id = @user[:id]
				@job.save
				@degree = Degree.new
				@degree.user_id = @user[:id]
				@degree.save
			
				subject = "Your Pathway has been created"
				encoded_url = $master.url + "/user/post_signup?user[email]=#{@user[:email]}&temp=#{@user[:hashed_password]}"
				Emailer.deliver_signup_notification(@user.email, @user.name, subject, subject, $master.formal_name, $master.informal_name, $master.admin_email, encoded_url)
				flash[:alert] = "Thank you for signing up.<br/>A confirmation email, with instructions for accessing your Pathway, has been sent to your account."
				redirect_to(:controller => :user, :action => :signin)			
			else
				subject = "Your Pathway will be created, pending confirmation"
				Emailer.deliver_signup_pending(@user.email, @user.name, subject, subject, $master.formal_name, $master.informal_name, $master.admin_email)
				flash[:alert] = "Thank you for signing up.  A confirmation email has been sent to your account."
				redirect_to(:controller => :user, :action => :signin)
			end
			
		end
	
	end
	
	def getPassword(name)
		name = name + name + name + name + name + name + name + name + name + name
		name = name.downcase.delete(" ")
		return name[0..4].gsub(/./) {|s| ((s[0] + 2).chr)} + name[5..7].gsub(/./) {|s| (s[0] % 10)}
	end
	
	def round(term, val)
		term = (term * 10**val).to_i.to_f
		return (term / 10**val).to_s
	end
	
	def createNewLogEntry(url)

		if (session["#{$master.url}_temp_id"] == nil)
			session["#{$master.url}_temp_id"] = getTempId(8)
		end

		#print	"\n" + session["#{$master.url}_temp_id"] + "\n"

		entry = Log.new
		if (session["#{$master.url}_id"] != nil)
			entry.user_id = session["#{$master.url}_id"]
		else
			entry.user_id = 0
		end

		entry.temp_id = session["#{$master.url}_temp_id"]

		if (session["#{$master.url}_ab_assignment"] != nil)
			entry.ab_assignment = session["#{$master.url}_ab_assignment"]
		else
			entry.ab_assignment = ""
		end
		entry.url_visited = url
		entry.time_visited = Time.now
		entry.save
	end

	def getTempId(size)
		charset = Array['a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z','A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z','0','1','2','3','4','5','6','7','8','9']
		return (0..size).map {charset[rand(charset.size)]}.join
	end



end
