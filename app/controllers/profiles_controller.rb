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
			
			if !(session["#{$master.url}_id"] == @user.id || (session["#{$master.url}_id"] == @user.author && @user.editing_allowed == "1"))
				redirect_to(:action => :view, :id => id)
				elsif (@user.author != 0 && @user.id != @user.author && session["#{$master.url}_id"] == @user.id && @user.approved == 0)
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
			
			@max_title_word_count = 6
			@max_summary_length = 250
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
			print "url goes to view\n"
			flash[:url] = "/profiles/view/#{params[:id]}"
		else 
			print "url goes to interview\n"
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
			
			if @user.is_alum == "1"
				@interview_text = @user.alum_interview_text
			else 
				@interview_text = @user.student_interview_text
			end
			
			@interview_text.gsub!(/<.*\|.*>/) {|match| '<a href="' + match[(match.index('|') + 1)..(match.length - 2)] + '">' + match[1..match.index('|') - 1] + '</a>'}
			@interview_text.gsub!(/\[.*\]/) {|match| '<br/><br/><span class="question">' + match[1..(match.length - 2)] + '</span><br/>'}
			@interview_text.gsub!(/\|\|/) {|match| '<br/>'}
			
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
		asker = ""
		if session["#{$master.url}_id"]
			user = User.find(session["#{$master.url}_id"])
			asker = ' (posted by <' + user.name + '|/profiles/view/' + user.id.to_s + '>)'
		end
		
		#Adds an extra line break if needed
		text = @user.alum_interview_text
		if (text[(text.length-1)..(text.length-1)] != "\n")
			@user.alum_interview_text = text + "\n"
		end
		
		text = @user.student_interview_text
		if (text[(text.length-1)..(text.length-1)] != "\n")
			@user.student_interview_text = text + "\n"
		end
		
		@user.alum_interview_text = @user.alum_interview_text + "\n[" + new_question + asker + "]\n"
		@user.student_interview_text = @user.student_interview_text + "\n[" + new_question + asker + "]\n"
		
		if (session[:user_id] != @user.id && session[:user_id] != @user.author)
			@user.views = @user.views - 1
			author = User.find(@user.author)
			author.total_views = author.total_views - 1
			author.save
		end
		
		@user.question_asked = Time.now
		
		@user.save
		redirect_to("/profiles/view/#{@user[:id]}")
	end
	
	def create(prev, new)
		File.open(new, "wb") { |file| file << prev.read}
	end
	
	def search
		
		if session["#{$master.url}_ab_assignment"] == nil
			if ($master.ab_last_assigned == 1) # 0 corresponds to A, 1 corresponds to B
				session["#{$master.url}_ab_assignment"] = "a"
			else
				session["#{$master.url}_ab_assignment"] = "b"
			end
			
			$master.ab_last_assigned = ($master.ab_last_assigned + 1) % 2 #Toggles assignment between 0 and 1
			$master.save
		end
		
		print "\nsession: " + session["#{$master.url}_ab_assignment"] + "\n"
		
		
		@ATest = true
		# Get a random potential interview for B-Testing
		if (session["#{$master.url}_ab_assignment"] == "b")
			@ATest = false
			potential_interviewees = User.find(:all, :conditions => ["author = ?", 0])
			if (potential_interviewees != nil && potential_interviewees.length > 0)
				@random_interviewee = potential_interviewees[rand(potential_interviewees.length)]
			else
				# Go back to ATest if we have no unauthored pathways
				session["#{$master.url}_ab_assignment"] = "a"
				@ATest = true
			end
		end
		
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
		
		@contributors = allUsers[0..4]
		
		@contributors.reject! {|contributor| (User.find(:all, :conditions => [ "author = ? AND id != ? AND approved = '1'", contributor.id, contributor.id])).size == 0}
		
		days = 7
		days_ago = Time.now - (days * (60*60*24)) 
		@recent_interviews = User.find(:all, :conditions => ['author != ? and approved > ?', 0, 0], :order => 'date_modified DESC', :limit => 5)
		
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
		@user.is_alum = "1"
		@user.date_added = Time.now
		@user.date_modified = Time.now
		@user.interview_date = Time.now
		@user.question_asked = DateTime.new(Time.now.year - 1, 1, 1)
		
		
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
		
		print "years contains " + years.length.to_s + "\n"
		
		years.sort!
		return "('" + years[0].to_s[2..3] + ")"
		
		end
	
	def getPassword(name)
		name = name + name + name + name + name + name + name + name + name + name
		name = name.downcase.delete(" ")
		return name[0..4].gsub(/./) {|s| ((s[0] + 2).chr)} + name[5..7].gsub(/./) {|s| (s[0] % 10)}
	end
	
	def rss
		@recent_interviews = User.find(:all, :conditions => ['author != ? and approved > ?', 0, 0], :order => 'date_modified DESC', :limit => 5)
	end
	
	def about
	end
	
	def createNewLogEntry(url)
		entry = Log.new
		if (session["#{$master.url}_id"] != nil)
			entry.user_id = session["#{$master.url}_id"]
		else
			entry.user_id = 0
		end
		if (session["#{$master.url}_ab_assignment"] != nil)
			entry.ab_assignment = session["#{$master.url}_ab_assignment"]
		else
			entry.ab_assignment = ""
		end
		entry.url_visited = url
		entry.time_visited = Time.now
		entry.save
	end
end
