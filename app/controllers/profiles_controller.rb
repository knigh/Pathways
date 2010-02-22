class ProfilesController < ActionController::Base

	   layout 'standard'
	   
	     $master = Master.find(1)

 
	def edit
		id = params[:id]
		@user = User.find(id)
 
		if params[:commit] == "Author Pathway"
			@user.author = session["#{$master.url}_id"]
			@user.save
		end
 
		if !(session["#{$master.url}_id"] == @user.id || (session["#{$master.url}_id"] == @user.author && @user.editing_restricted != 1))
			redirect_to(:action => :view, :id => id)
		end
 
		@jobs = Job.find(:all, :conditions => ["user_id = ?", id])
		
		@degrees = Degree.find(:all, :conditions => ["user_id = ?", id])

		if @user.author != 0
			@author = User.find(@user.author)
		end
 
		if @user.is_alum == "1"
			@interview_text = @user.alum_interview_text
		else 
			@interview_text = @user.student_interview_text
		end
 
		if @user.total_authored > 0
			@interviewees = User.find(:all, :conditions => [ "author = ? AND id != ?", id, id])
		end
	end
 
	def post_edit
		@user = User.find(params[:id])
 
 		prev = params[:user][:image_file]
		if (prev != nil)
			image_file = @user.id.to_s() + '_' + prev.original_filename
			new = Dir.getwd + "/images/pics/" + image_file
			create(prev, new)
		else
			image_file = @user.image_file
		end
 
 		@degrees = Degree.find(:all, :conditions => ["user_id = ?", @user.id])
		@degrees.each do |degree|
			degree.update_attributes(params[:user][:existing_degree_attributes][degree.id])
			degree.save
		end
 
		@jobs = Job.find(:all, :conditions => ["user_id = ?", @user.id])
		@jobs.each do |job|
			job.update_attributes(params[:user][:existing_job_attributes][job.id])
			job.save
		end
		
		@password = params[:password]
		@password_confirmation = params[:password_confirmation]
		if @password != nil && @password != ""
			if (@password != @password_confirmation)
				logger.error("Confirmation must match password")
				flash[:notice] = "Confirmation must match password"
				  render (:action => :edit)
				  return
			elsif (@password.length < 6)
				logger.error("Password must contain at least six characters")
				flash[:notice] = "Password must contain six or more characters"
				  render (:action => :edit)
				  return
			else
				@user.hashed_password = Digest::SHA1.hexdigest(@password)
			end
		end
 
		if @user.update_attributes(params[:user]) then
			@user.image_file = image_file
			@user.save
			if params[:add_job]
				@job = Job.new
				@job.user_id = @user.id
				@job.save
				redirect_to("/profiles/edit/#{@user[:id]}")
			elsif params[:add_degree]
				@degree = Degree.new
				@degree.user_id = @user.id
				@degree.save
				redirect_to("/profiles/edit/#{@user[:id]}")
			else
				redirect_to("/profiles/view/#{@user[:id]}")
			end
		else
			render(:action => :edit)
		end
	end
	
	def signin_to_interview
		flash[:alert] = "You must sign up or sign in to author another person's pathway"
		flash[:id] = params[:id]
		redirect_to(:controller => :user, :action => :signin)
	end	
	 
	def view
		id = params[:id]
		@user = User.find(id)
		@jobs = Job.find(:all, :conditions => ["user_id = ? AND (title != ? OR company != ?)", id, "", ""])
		@degrees = Degree.find(:all, :conditions => ["user_id = ? AND (degree != ? OR major != ?)", id, "", ""])
		
		@user.views = @user.views + 1

		if @user.author != 0
			@author = User.find(@user.author)
			if @user.author != @user.id
				@author.total_views = @author.total_views + 1
			end
			if @user.total_authored > 0
				@interviewees = User.find(:all, :conditions => [ "author = ? AND id != ?", id, id])
			end
			@user.save
			@author.save
 		end

		if @user.is_alum == "1"
			@interview_text = @user.alum_interview_text
		else 
			@interview_text = @user.student_interview_text
		end
 
		@interview_text.gsub!(/Q: .*\nA:/) {|match| "<br/><br/><em>" + match[3..-3] + "</em><br/>"}
		firstQ = @interview_text.index(/<em>/)
		if (firstQ != nil)
			@interview_text = @interview_text[firstQ, @interview_text.length - firstQ]
		end
		
	end
 
	def post_like
		@user = User.find(params[:id])
		@user.likes = @user.likes + 1
		@user.views = @user.views - 1
		author = User.find(@user.author)
		author.total_views = author.total_views - 1
 
		@user.save
		author.save
 
		redirect_to("/profiles/view/#{@user[:id]}")
	end
 
	def post_question
		@user = User.find(params[:id])
		new_question = params[:new_question]
		asker = ""
		if session["#{$master.url}_id"]
			user = User.find(session["#{$master.url}_id"])
			asker = " (posted by " + user.name + ")"
		end
		@user.alum_interview_text = @user.alum_interview_text + "\nQ: " + new_question + asker + "\nA:\n"
		@user.student_interview_text = @user.student_interview_text + "\nQ: " + new_question + asker + "\nA:\n"
		@user.views = @user.views - 1
		@user.question_asked = Time.now
		author = User.find(@user.author)
		author.total_views = author.total_views - 1
 
		@user.save
		author.save
		redirect_to("/profiles/view/#{@user[:id]}")
	end
 
	def create(prev, new)
		File.open(new, "wb") { |file| file << prev.read}
	end
 
	def search
		
		# The search parameters are set in the commit variable
		if (params[:commit] && (params[:commit] != ""))
			# @searchResults = User.find(:all, :conditions => ['match(name,summary,alum_interview_text,student_interview_text,six_words) against (? with query expansion) and author != ?', params[:commit], 0], :order => 'name')
			searchResults = User.find(:all, :conditions => ['match(name,summary,alum_interview_text,student_interview_text,six_words) against (?) and author != ?', params[:commit], 0], :order => 'name')
			if searchResults == nil
				searchResults = Array.new
			end
			jobResults = Job.find(:all, :conditions => ['match(company,title,responsibilities) against (?)', params[:commit]])
			jobResults.each do |job|
				user = User.find(job.user_id)
				if (user.author != 0) 
					searchResults << user
				end
			end
			
			degreeResults = Degree.find(:all, :conditions => ['match(major,degree) against (?)', params[:commit]])
			degreeResults.each do |degree|
				user = User.find(degree.user_id)
				if (user.author != 0) 
					searchResults << user
				end
			end
			@searchResults = searchResults.uniq.sort { |a, b| a.name <=> b.name}
		else
			@searchResults = User.find(:all, :conditions => ['author != ?', 0], :order => 'views DESC', :limit => 10)
		end	
		
		numUsers = @searchResults.length

		# There has to be a better way to do this :)
		if numUsers > 0
			while true
				user1 = rand(numUsers)
				@user1 = @searchResults[user1]
				if @user1 != nil 
					break
				end
			end
		end
		if numUsers > 1
			while true
				user2 = rand(numUsers)
				if user2 != user1
					@user2 = @searchResults[user2]
					if @user2 != nil
						break
					end
				end
			end
		end
		if numUsers > 2
			while true
				user3 = rand(numUsers)
				if user3 != user1 && user3 != user2
					@user3 = @searchResults[user3]
					if @user3 != nil
						break
					end
				end
			end
		end

		@contributors = User.find(:all, :conditions => ['total_authored > ?', 0], :order => 'total_authored DESC, total_views DESC', :limit => 5)
		 
		   days = 7
		 days_ago = Time.now - (days * (60*60*24)) 
		@recent_interviews = User.find(:all, :conditions => ['author != ?', 0], :order => 'date_modified DESC', :limit => 5)
		
		@authoredPathways = User.find(:all, :conditions => [ "author != ?", 0])
		
	end

	def interview

		# The search parameters are set in the commit variable
		if (params[:commit] && (params[:commit] != ""))
			# @seeded = User.find(:all, :conditions => ['match(name,summary,alum_interview_text,student_interview_text,six_words) against (? with query expansion) and author = ?', params[:commit], 0], :order => 'name')
			@seeded = User.find(:all, :conditions => ['match(name,summary,alum_interview_text,student_interview_text,six_words) against (?) and author = ?', params[:commit], 0], :order => 'name')
		else
			@seeded = User.find(:all, :conditions => ['author = ?', 0], :order => 'name')
		end
	end

	def post_authorProfile
		@user = User.find(params[:id])
		@user.author = session["#{$master.url}_id"]
		@user.alum_interview_text = $master.alum_default_qs
		@user.student_interview_text = $master.student_default_qs

		if @user.save
			@job = Job.new
			@job.user_id = @user[:id]
			@job.save
			@degree = Degree.new
			@degree.user_id = @user[:id]
			@degree.save
			author = User.find(session["#{$master.url}_id"])
			author.total_authored = author.total_authored + 1
			author.save
			redirect_to("/profiles/edit/#{@user[:id]}")
		else
			render(:action => :interview)
		end
	end
 
	def post_newUser
	
		@user = User.find_by_email(params[:user][:email])
		if (@user.nil?)
			@user = User.new
			@user.name = params[:user][:name]
			@user.email = params[:user][:email]
		end
		@user.author = session["#{$master.url}_id"]
		@user.alum_interview_text = $master.alum_default_qs
		@user.student_interview_text = $master.student_default_qs
		@user.is_alum = "1"
		
		password = getPassword(@user.name)
		print password + "\n"
		@user.hashed_password = Digest::SHA1.hexdigest(password)

		
		flash[:notice] = nil
	
		if @user.name.length < 1
			logger.error("Name can't be blank")
			flash[:notice] = "r: Name can't be blank"
			render(:action => :interview)
			return
		elsif @user.email.length < 1
			logger.error("Email can't be blank")
			flash[:notice] = "r: Email can't be blank"
			render(:action => :interview)
			return
		end

		if @user.save
			@job = Job.new
			@job.user_id = @user[:id]
			@job.save
			@degree = Degree.new
			@degree.user_id = @user[:id]
			@degree.save
			author = User.find(session["#{$master.url}_id"])
			author.total_authored = author.total_authored + 1
			author.save
			redirect_to("/profiles/edit/#{@user[:id]}")
		else
			render(:action => :interview)
		end
	end

	def getClassYears(user)
		years = Array.new
		degrees = Degree.find(:all, :conditions => ["user_id = ?", user.id])
		
		degrees.each do |degree|
			if degree.class_year != nil && degree.class_year > 0
				years << degree.class_year
			end
		end
		
		if years.length == 0
			return ""
		end
		
		print "years contains " + years.length.to_s + "\n"
		
		years.sort!
		return "('" + years[0].to_s[2..3] + ")"

	end
	
	def getPassword(name)
		name = name.downcase.delete(" ")
		return name[0..4].gsub(/./) {|s| ((s[0] + 2).chr)} + name[5..7].gsub(/./) {|s| (s[0] % 10)}
	end
 
end
