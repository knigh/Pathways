class ProfilesController < ActionController::Base
	
	layout 'standard', :except => :rss

	$master = Master.find(1)

	def edit
		createNewLogEntry(request.request_uri)
		begin
			id = params[:id]
			@user = User.find(id)
		rescue
			redirect_to "/404.html"
			else
			if params[:commit] == "Author Pathway"
				@user.author = session["#{$master.url}_id"]
				@user.save
			end
			
			if !(session["#{$master.url}_user_type"] == "2" || session["#{$master.url}_id"] == @user.id || (session["#{$master.url}_id"] == @user.author && @user.editing_allowed == "1"))
				redirect_to(:action => :view, :id => id)
			elsif ((session["#{$master.url}_user_type"] != "2") && (@user.author != 0 && @user.id != @user.author && session["#{$master.url}_id"] == @user.id && @user.approved == 0))
				redirect_to(:action => :view, :id => id)
			end
			
			
			@jobs = Job.find(:all, :conditions => ["user_id = ?", id])
			
			@degrees = Degree.find(:all, :conditions => ["user_id = ?", id])
			
			if @user.author != 0
				@author = User.find(@user.author)
			end
			
			if @user.user_type == "1"
				@interview_text = @user.alum_interview_text
			else 
				@interview_text = @user.student_interview_text
			end
			
			@questions = Question.find(:all, :conditions => ["user_id = ?", id])
			
			@max_title_word_count = 6
			@max_summary_length = 250
		end
	end
	
	def post_edit
		
		createNewLogEntry(request.request_uri)
		
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
				render(:action => :edit)
				return
			elsif (@password.length < 6)
				logger.error("Password must contain at least six characters")
				flash[:notice] = "Password must contain six or more characters"
				render(:action => :edit)
				return
			else
			@user.hashed_password = Digest::SHA1.hexdigest(@password)
			end
		end
		
		if @user.update_attributes(params[:user]) then
			@user.image_file = image_file
			@user.date_modified = Time.now
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
		if (params[:id])
			#print "url goes to view\n"
			flash[:url] = "/profiles/view/#{params[:id]}"
		else 
			#print "url goes to interview\n"
			flash[:url] = "/profiles/interview"
		end
		redirect_to(:controller => :user, :action => :signin)
	end	
	
	def view
		createNewLogEntry(request.request_uri)
		begin
			id = params[:id]
			@user = User.find(id)
		rescue
			redirect_to "/404.html"
		else
			@jobs = Job.find(:all, :conditions => ["user_id = ? AND (title != ? OR company != ?)", id, "", ""])
			@degrees = Degree.find(:all, :conditions => ["user_id = ? AND (degree != ? OR major != ?)", id, "", ""])
			
			if (session[:user_id] != @user.id && session[:user_id] != @user.author)
				@user.views = @user.views + 1
			end
			
			if @user.author != 0
				@author = User.find(@user.author)
				if @user.author != @user.id && session[:user_id] != @user.id && session[:user_id] != @user.author
					@author.total_views = @author.total_views + 1
				end
				
				@interviewees_approved = User.find(:all, :conditions => [ "author = ? AND id != ? AND approved = '1'", id, id])
				@interviewees_pending = User.find(:all, :conditions => [ "author = ? AND id != ? AND approved != '1'", id, id])
				@user.save
				@author.save
			end
			
			# get all interviews I like
			@interviewsILike = Array.new
			interviewIdsILike = Like.find(:all, :conditions => ["liked_by_id = ?", id])
			interviewIdsILike.each do |interviewId|
				interview = User.find(:all, :conditions => ["id = ?", interviewId.liked_id])
				if (interview != nil && (interview.length > 0))
					@interviewsILike << interview[0]
				end
			end
			
			# get all likers
			likeResults = Like.find(:all, :conditions => ["liked_id = ?", id])
			if (likeResults == nil)
				likeResults = Array.new
			end
			likeResults = likeResults.uniq.sort {|a, b| a.liked_by_id <=> b.liked_by_id}
			@numLikers = likeResults.length
			@numRemainingLikers = @numLikers;
			
			# set @likerUser if the user is one of the likers
			userLikerResults = Like.find(:all, :conditions => ["liked_id = ? and liked_by_id = ?", id, session["#{$master.url}_id"]])
			if (userLikerResults != nil && userLikerResults.length > 0)
				userLikerResults = User.find(:all, :conditions => ["id = ?", session["#{$master.url}_id"]])
				if (userLikerResults != nil && userLikerResults.length > 0)
					@likerUser = userLikerResults[0]
				end
			end
			
			if @numLikers > 0
				if @likerUser != nil
					@liker1 = @likerUser
					@numRemainingLikers = @numRemainingLikers - 1
				else
					while true
						like1 = likeResults[rand(@numLikers)]
						liker1Results = User.find(:all, :conditions => ["id = ?", like1.liked_by_id])
						if (liker1Results != nil && liker1Results.length > 0)
							@liker1 = liker1Results[0]
							@numRemainingLikers = @numRemainingLikers - 1
							break
						end
					end
				end
			end
			if @numLikers > 1
				while true
					like2 = likeResults[rand(@numLikers)]
					liker2Results = User.find(:all, :conditions => ["id = ?", like2.liked_by_id])
					if (liker2Results != nil && liker2Results.length > 0)
						@liker2 = liker2Results[0]
						if (@liker2 != nil && (@liker2.id != @liker1.id))
							@numRemainingLikers = @numRemainingLikers - 1
							break
						end
					end
				end
			end
			if @numLikers > 2
				while true
					like3 = likeResults[rand(@numLikers)]
					liker3Results = User.find(:all, :conditions => ["id = ?", like3.liked_by_id])
					if (liker3Results != nil && liker3Results.length > 0)
						@liker3 = liker3Results[0]
						if (@liker3 != nil && (@liker3.id != @liker2.id) && (@liker3.id != @liker1.id))
							@numRemainingLikers = @numRemainingLikers - 1
							break
						end
					end
				end
			end
			
			if @user.user_type == "1"
				@interview_text = @user.alum_interview_text
			else
				@interview_text = @user.student_interview_text
			end
			
			# add all questions to the viewable text
			new_questions = Question.find(:all, :conditions => ["user_id =?", id])
			if ((new_questions != nil) && (new_questions.length > 0))
				
				if (@interview_text[(@interview_text.length-1)..(@interview_text.length-1)] != "\n")
					@interview_text = @interview_text + "\n"
				end
				
				new_questions.each do |question|
					# get the user who asked the question
					asker = User.find(question.asker_id)
					@interview_text = @interview_text + "\n" + '[[' + question.question + ' (posted by <' + asker.name + '|/profiles/view/' + question.asker_id.to_s + '>)' + ']]' + "\n"
				end
			end
			
			@interview_text.gsub!(/<.*\|.*>/) {|match| '<a href="' + match[(match.index('|') + 1)..(match.length - 2)] + '">' + match[1..match.index('|') - 1] + '</a>'}
			@interview_text.gsub!(/\[\[.*\]\]/) {|match| '<span class="question">' + match[2..(match.length - 3)] + '</span>'}

			@interview_text.gsub!(/\n/) {|match| '<br/>'}
			
			@interview_text.gsub!(/Q: .*\nA:/) {|match| '<br/><br/><span class="question">' + match[3..-3] + '</span><br/>'}
			
			if (@interview_text.index("<br/><br/>") == 0) 
				@interview_text = @interview_text[10..@interview_text.length - 1]
			end
		end
	end
	
	def post_like
		createNewLogEntry(request.request_uri)
		@user = User.find(params[:id])
		
		if (session[:user_id] != @user.id && session[:user_id] != @user.author)
			@user.views = @user.views - 1
			author = User.find(@user.author)
			author.total_views = author.total_views - 1
			author.save
		end
		
		@like = Like.new
		@like.liked_id = @user.id
		@like.liked_by_id = session["#{$master.url}_id"]
		
		@like.save
		@user.save
		
		redirect_to("/profiles/view/#{@user[:id]}")	
	end
	
	def post_question
		createNewLogEntry(request.request_uri)

		@user = User.find(params[:id])
		new_question = params[:new_question]
		
		if (session[:user_id] != @user.id && session[:user_id] != @user.author)
			@user.views = @user.views - 1
			author = User.find(@user.author)
			author.total_views = author.total_views - 1
			author.save
		end
		
		@question = Question.new
		@question.user_id = @user.id
		@question.asker_id = session["#{$master.url}_id"]
		@question.question = new_question
		@question.date_added = Time.now
		
		@question.save
		@user.save
		
		redirect_to("/profiles/view/#{@user[:id]}")
	end
	
	def create(prev, new)
		File.open(new, "wb") { |file| file << prev.read}
	end
	
	def search
		
		potential_interviewees = User.find(:all, :conditions => ["author = ?", 0])
		if (potential_interviewees != nil && potential_interviewees.length > 0)
			@random_interviewee = potential_interviewees[rand(potential_interviewees.length)]
		end

		@numSeeded = potential_interviewees.length
		
		createNewLogEntry(request.request_uri)
		
		
		# The search parameters are set in the commit variable
		if (params[:commit] && (params[:commit] != ""))
			# @searchResults = User.find(:all, :conditions => ['match(name,summary,alum_interview_text,student_interview_text,six_words) against (? with query expansion) and author != ?', params[:commit], 0], :order => 'name')
			searchResults = User.find(:all, :conditions => ['match(name,summary,alum_interview_text,student_interview_text,six_words) against (?) and author != ? and approved > ?', params[:commit], 0, 0], :order => 'name')
			if searchResults == nil
				searchResults = Array.new
			end
			jobResults = Job.find(:all, :conditions => ['match(company,title,responsibilities) against (?)', params[:commit]])
			jobResults.each do |job|
				user = User.find(job.user_id)
				if (user.author != 0 && user.approved > 0) 
					searchResults << user
				end
			end
			
			degreeResults = Degree.find(:all, :conditions => ['match(major,degree) against (?)', params[:commit]])
			degreeResults.each do |degree|
				user = User.find(degree.user_id)
				if (user.author != 0 && user.approved > 0) 
					searchResults << user
				end
			end
			@searchResults = searchResults.uniq.sort { |a, b| a.name <=> b.name}
		else
			@searchResults = User.find(:all, :conditions => ['author != ? and approved > ? and summary != ?', 0, 0, ""], :order => 'views DESC', :limit => 10)
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
		
		allUsers = User.find(:all);
		allUsers.sort! {|x,y| 
			x_approved_interviews = User.find(:all, :conditions => [ "author = ? AND id != ? AND approved = '1'", x.id, x.id])
			y_approved_interviews = User.find(:all, :conditions => [ "author = ? AND id != ? AND approved = '1'", y.id, y.id])
			if y_approved_interviews.size == x_approved_interviews.size 
				y.total_views <=> x.total_views
			end
			y_approved_interviews.size <=> x_approved_interviews.size
		}
		
		if (session["#{$master.url}_id"] != nil)
			@user = User.find(session["#{$master.url}_id"])
			degrees = Degree.find(:all, :conditions => ["user_id = ?", @user.id])
			matchingEducation = Array.new
			degrees.each do |degree|
				if (degree.class_year != 0 && degree.major != "")
					matchingEducation += Degree.find(:all, :conditions => ["(class_year = ? OR major = ?) AND user_id != ?", degree.class_year, degree.major, @user.id])
				end
			end
			recommended = Array.new
			matchingEducation.each do |degree|
				user = User.find(degree.user_id)
				print "\nuser: " + user.name + ", " + user.approved.to_s + ", " + user.author.to_s + "\n" 
				if ((@user.user_type == "1" || @numSeeded == 0) && user.approved == 1)   # show alums approved profiles for viewing
					recommended << user
				elsif ((@user.user_type == "0" && @numSeeded > 0) && user.author == 0)   # show students seeded profiles
					recommended << user
				end
			end

			jobs = Job.find(:all, :conditions => ["user_id = ?", @user.id])
			matchingJob = Array.new
			jobs.each do |job|
				if (job.company != "" && job.title != "")
					matchingJob += Job.find(:all, :conditions => ["(company = ? OR title = ?) AND user_id != ?", job.company, job.title, @user.id])
				end
			end
			matchingJob.each do |job|
				user = User.find(job.user_id)
				if ((@user.user_type == "1" || @numSeeded == 0) && user.approved == 1)   # show alums approved profiles for viewing
					recommended << user
				elsif ((@user.user_type == "0" && @numSeeded > 0) && user.author == 0)   # show students seeded profiles
					recommended << user
				end
			end
			recommended.uniq!

			if (recommended.length > 0)
				@recommended = recommended[rand(recommended.length)]
				
 				recommendedDegrees = Degree.find(:all, :conditions => ["user_id = ?", @recommended.id])
				recommendedDegrees.sort! {|x,y| (rand(3) - 1)}
				degrees.sort! {|x,y| (rand(3) - 1)}
				recommendedDegrees.each do |recDegree|
					degrees.each do |degree|
						if (recDegree.major == degree.major)
							@recommendedText = "You both studied " + degree.major
						elsif (recDegree.class_year == degree.class_year)
							@recommendedText = "You both got degrees in " + degree.class_year.to_s
						end
					end
				end

				recommendedJobs = Job.find(:all, :conditions => ["user_id = ?", @recommended.id])
				recommendedJobs.sort! {|x,y| (rand(3) - 1)}
				jobs.sort! {|x,y| (rand(3) - 1)}
				recommendedJobs.each do |recJob|
					jobs.each do |job|
						if (recJob.company == job.company)
							@recommendedText = "You both worked at " + job.company
						elsif (recJob.title == job.title)
							@recommendedText = "You both had the job title of " + job.title
						end
					end
				end

			else
				if (@user.user_type == "1" || @numSeeded == 0)   # show alums approved profiles
					allOtherUsers = User.find(:all, :conditions => ["id != ? AND author != ? AND author != 0 AND approved = '1'", @user.id, @user.id])				
				elsif (@user.user_type == "0")   # show students seeded profiles
					allOtherUsers = User.find(:all, :conditions => ["id != ? AND author != ? AND author = 0", @user.id, @user.id])
				end
				if allOtherUsers != nil
					@recommended = allOtherUsers[rand(allOtherUsers.length)]
				end
				@recommendedText = ""
			end
		end
		
		@contributors = allUsers[0..4]
		
		@contributors.reject! {|contributor| (User.find(:all, :conditions => [ "author = ? AND id != ? AND approved = '1'", contributor.id, contributor.id])).size == 0}
		
		days = 7
		days_ago = Time.now - (days * (60*60*24)) 
		@recent_interviews = User.find(:all, :conditions => ['author != ? and approved > ? and user_type <> "2"', 0, 0], :order => 'date_modified DESC', :limit => 5)
		
		@authoredPathways = User.find(:all, :conditions => ['author != ? and approved > ?', 0, 0])
		
	end
	
	def interview
		createNewLogEntry(request.request_uri)
		# The search parameters are set in the commit variable
		if (params[:commit] && (params[:commit] != ""))
			# @seeded = User.find(:all, :conditions => ['match(name,summary,alum_interview_text,student_interview_text,six_words) against (? with query expansion) and author = ?', params[:commit], 0], :order => 'name')
			@seeded = User.find(:all, :conditions => ['match(name,summary,alum_interview_text,student_interview_text,six_words) against (?) and author = ?', params[:commit], 0], :order => 'name')
		else
			@seeded = User.find(:all, :conditions => ['author = ?', 0], :order => 'name')
		end
	end
	
	def browse
		createNewLogEntry(request.request_uri)
		# The search parameters are set in the commit variable
		if (params[:commit] && (params[:commit] != ""))
			@admins   = User.find(:all, :conditions => ['match(name,summary,alum_interview_text,student_interview_text,six_words) against (?) and user_type = ?', params[:commit], "2"], :order => 'name')
			@alums    = User.find(:all, :conditions => ['match(name,summary,alum_interview_text,student_interview_text,six_words) against (?) and user_type = ?', params[:commit], "1"], :order => 'name')
			@students = User.find(:all, :conditions => ['match(name,summary,alum_interview_text,student_interview_text,six_words) against (?) and user_type = ?', params[:commit], "0"], :order => 'name')
		else
			@admins   = User.find(:all, :conditions => ['user_type = ?', "2"], :order => 'name')
			@alums    = User.find(:all, :conditions => ['user_type = ?', "1"], :order => 'name')
			@students = User.find(:all, :conditions => ['user_type = ?', "0"], :order => 'name')
		end
	end
	
	def post_authorProfile
		createNewLogEntry(request.request_uri)
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
			author.save
			redirect_to("/profiles/edit/#{@user[:id]}")
		else
			render(:action => :interview)
		end
	end
	
	def post_newUser
		createNewLogEntry(request.request_uri)
		
		@user = User.find_by_email(params[:user][:email])
		if (@user.nil?)
			@user = User.new
			@user.name = params[:user][:name]
			@user.email = params[:user][:email]
		end
		@user.author = session["#{$master.url}_id"]
		@user.alum_interview_text = $master.alum_default_qs
		@user.student_interview_text = $master.student_default_qs
		@user.user_type = "1"
		@user.date_added = Time.now
		@user.date_modified = Time.now
		@user.interview_date = Time.now
		@user.question_asked = DateTime.new(Time.now.year - 1, 1, 1)
		
		
		password = getPassword(@user.name)
		#print password + "\n"
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
			author.save
			redirect_to("/profiles/edit/#{@user[:id]}")
			else
			render(:action => :interview)
			end
		end
	
	def post_submit
		createNewLogEntry(request.request_uri)
		@user = User.find(params[:id])
		@user.approved = -1
		@user.save
		@author = User.find(@user.author)
		subject = "Your Pathway has been created"
		encoded_url = $master.url + "/user/post_publish?user[email]=#{@user[:email]}&temp=#{@user[:hashed_password]}"
		
		Emailer.deliver_submit(@user.email, @user.name, @author.name, subject, subject, $master.formal_name, $master.informal_name, encoded_url)
		return if request.xhr?
		redirect_to(:action => :view, :id => @user.id)
	end
	
	def post_approve
		createNewLogEntry(request.request_uri)
		@user = User.find(params[:id])
		@user.approved = 1
		@user.save
		redirect_to(:action => :view, :id => @user.id)
	end

	def rss
		createNewLogEntry(request.request_uri)
		@recent_interviews = User.find(:all, :conditions => ['author != ? and approved > ? and user_type <> "2"', 0, 0], :order => 'date_modified DESC', :limit => 5)
	end
	
	def about
		createNewLogEntry(request.request_uri)
	end
	
	def getClassYears(user)
		years = Array.new
		degrees = Degree.find(:all, :conditions => ["user_id = ? and school = ?", user.id, "Stanford University"])
		
		degrees.each do |degree|
			if degree.class_year != nil && degree.class_year > 0
				years << degree.class_year
			end
		end
		
		if years.length == 0
			return ""
		end
		
		#print "years contains " + years.length.to_s + "\n"
		
		years.sort!
		return "('" + years[0].to_s[2..3] + ")"
		
		end
	
	def getPassword(name)
		name = name + name + name + name + name + name + name + name + name + name
		name = name.downcase.delete(" ")
		return name[0..4].gsub(/./) {|s| ((s[0] + 2).chr)} + name[5..7].gsub(/./) {|s| (s[0] % 10)}
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
