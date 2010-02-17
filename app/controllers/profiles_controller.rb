class ProfilesController < ActionController::Base

	   layout 'standard'
	   
	     $master = Master.find(1)

 
	def edit
		id = params[:id]
		@user = User.find(id)
 
		if params[:commit] == "Author Profile"
			@user.author = session[:user_id]
			@user.save
		end
 
		@jobs = Job.find(:all, :conditions => ["user_id = ?", id])
		
		@degrees = Degree.find(:all, :conditions => ["user_id = ?", id])

 
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
 
		if @user.update_attributes(params[:user]) then
			@user.image_file = image_file
			@user.save
			if params[:commit] == " + "
				@job = Job.new
				@job.user_id = @user.id
				@job.save
				redirect_to("/profiles/edit/#{@user[:id]}")
			elsif params[:commit] == "+"
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
	 
	def view
		id = params[:id]
		@user = User.find(id)
		@jobs = Job.find(:all, :conditions => ["user_id = ?", id])
		@degrees = Degree.find(:all, :conditions => ["user_id = ?", id])
		
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
		if session[:user_id]
			user = User.find(session[:user_id])
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
		
		@topViewed = User.find(:all, :conditions => ['author != ?', 0], :order => 'views DESC', :limit => 10)
	
		numUsers = @topViewed.length

		if numUsers > 0
			while true
				user1 = rand(numUsers)
				@user1 = @topViewed[user1]
				if @user1 != nil 
					break
				end
			end
		end
		if numUsers > 1
			while true
				user2 = rand(numUsers)
				if user2 != user1
					@user2 = @topViewed[user2]
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
					@user3 = @topViewed[user3]
					if @user3 != nil
						break
					end
				end
			end
		end
		
		@contributors = User.find(:all, :conditions => ['total_authored > ?', 0], :order => 'total_authored DESC, total_views DESC', :limit => 5)
		 days = 7
		 days_ago = Time.now - (days * (60*60*24)) 
		@recent_interviews = User.find(:all, :conditions => ['date_modified > ? AND author != ?', days_ago, 0], :order => 'date_modified DESC', :limit => 5)
	end
 
	def post_newUser
	
		@user = User.find_by_email(params[:user][:email])
		if (@user.nil?)
			@user = User.new
			@user.name = params[:user][:name]
			@user.email = params[:user][:email]
		end
		@user.author = session[:user_id]
		@user.alum_interview_text = $master.alum_default_qs
		@user.student_interview_text = $master.student_default_qs
		@user.is_alum = "1"
		
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
			author = User.find(session[:user_id])
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
 
end
