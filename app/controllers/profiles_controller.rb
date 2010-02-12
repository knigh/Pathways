
class ProfilesController < ActionController::Base
	
	def edit
		id = params[:id]
		@user = User.find(id)
		@jobs = Job.find(:all, :conditions => ["user_id = ?", id])

		if @user.total_authored > 0
			@interviewees = User.find(:all, :conditions => [ "author = ? AND id != ?", id, id])
		end
	end
	
	def post_edit
		@curUser = User.find(params[:id])
		
 		prev = params[:user][:image_file]
		if (prev != nil)
			image_file = @curUser.id.to_s() + '_' + prev.original_filename
			new = Dir.getwd + "/public/images/pics/" + image_file
			create(prev, new)
		else
			image_file = @curUser.image_file
		end
		
		@jobs = Job.find(:all, :conditions => ["user_id = ?", @curUser.id])
		@jobs.each do |job|
			job.update_attributes(params[:user][:existing_job_attributes][job.id])
			job.save
		end
		
		if @curUser.update_attributes(params[:user]) then
			@curUser.image_file = image_file
			@curUser.save
			if params[:commit] == "+"
				@job = Job.new
				@job.user_id = @curUser.id
				@job.save
				redirect_to("/profiles/edit/#{@curUser[:id]}")
			else
				print "commit: '" + params[:commit] + "'"
				redirect_to("/profiles/view/#{@curUser[:id]}")
			end
		else
			redirect_to("/profiles/edit/#{@curUser[:id]}")
		end
	end
	
	def view
		id = params[:id]
		@user = User.find(id)
		@jobs = Job.find(:all, :conditions => ["user_id = ?", id])
		@user.views = @user.views + 1
		@author = User.find(@user.author)
		@author.total_views = @author.total_views + 1
		if @user.total_authored > 0
			@interviewees = User.find(:all, :conditions => [ "author = ? AND id != ?", id, id])
		end
		@user.save
		@author.save
		
		if @user.is_alum
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
		@user.new_question = params[:user][:new_question]
		asker = ""
		if session[:user_id]
			user = User.find(session[:user_id])
			asker = " (posted by " + user.name + ")"
		end
		@user.interview_text = @user.interview_text + "\nQ: " + @user.new_question + asker + "\nA:\n"
		@user.views = @user.views - 1
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
		
		numUsers = User.count

		if numUsers > 0
			while true
				user1 = 1 + rand(numUsers)
				@user1 = User.find(user1)
				if @user1 != nil 
					break
				end
			end
		end
		if numUsers > 1
			while true
				user2 = 1 + rand(numUsers)
				if user2 != user1
					@user2 = User.find(user2)
					if @user2 != nil
						break
					end
				end
			end
		end
		if numUsers > 2
			while true
				user3 = 1 + rand(numUsers)
				if user3 != user1 && user3 != user2
					@user3 = User.find(user3)
					if @user3 != nil
						break
					end
				end
			end
		end
		
		@contributors = User.find(:all, :conditions => ['total_authored > ?', 0], :order => 'total_authored DESC, total_views DESC', :limit => 5)
		 days = 7
		 days_ago = Time.now - (days * (60*60*24)) 
		@recent_interviews = User.find(:all, :conditions => ['date_modified > ? AND author != id', days_ago], :order => 'date_modified DESC', :limit => 5)
	end
	
	def post_newUser
		@user = User.new
		@user.author = session[:user_id]
		if @user.save
			@job = Job.new
			@job.user_id = @user[:id]
			@job.save
			author = User.find(session[:user_id])
			author.total_authored = author.total_authored + 1
			author.save
			redirect_to("/profiles/edit/#{@user[:id]}")
		end
	end
	
end
