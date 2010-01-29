
class ProfilesController < ActionController::Base
	
	def edit
		id = params[:id]
		@user = User.find(id)
		if @user.total_authored > 0
			@interviewees = User.find(:all, :conditions => [ "author = ? AND id != ?", id, id])
		end
	end
	
	def post_edit
		@curUser = User.find(params[:id])
		@curUser.degree = params[:degree]
		@curUser.satisfaction = params[:satisfaction]
		
 		prev = params[:user][:image_file]
		if (prev != nil)
			image_file = @curUser.id.to_s() + '_' + prev.original_filename
			new = Dir.getwd + "/public/images/" + image_file
			create(prev, new)
		else
			image_file = @curUser.image_file
		end
		
		if @curUser.update_attributes(params[:user]) then
			@curUser.image_file = image_file
			@curUser.save
			redirect_to("/profiles/view/#{@curUser[:id]}")
		else
			redirect_to("/profiles/edit/#{@curUser[:id]}")
		end
	end
	
	def view
		id = params[:id]
		@user = User.find(id)
		@user.views = @user.views + 1
		@author = User.find(@user.author)
		@author.total_views = @author.total_views + 1
		if @user.total_authored > 0
			@interviewees = User.find(:all, :conditions => [ "author = ? AND id != ?", id, id])
		end
		@user.save
		@author.save
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
		user1 = 1 + rand(numUsers)
		while true
			user2 = 1 + rand(numUsers)
			if user2 != user1
				break
			end
		end
		while true
			user3 = 1 + rand(numUsers)
			if user3 != user1 && user3 != user2
				break
			end
		end
		@user1 = User.find(user1)
		@user2 = User.find(user2)
		@user3 = User.find(user3)

		@contributors = User.find(:all, :conditions => ['total_authored > ?', 0])
	end
	
	def post_newUser
		@user = User.new
		@user.views = 0
		@user.total_views = 0
		@user.total_authored = 0
		@user.likes = 0
		@user.summary = ""
		@user.image_file = "blank_profile_pic.jpg"
		@user.interview_text = "== Interview Form ==

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
		@user.author = session[:user_id]
		if @user.save
			redirect_to("/profiles/edit/#{@user[:id]}")
			author = User.find(session[:user_id])
			author.total_authored = author.total_authored + 1
			author.save
		end
	end
	
	def post_newWorkExp
	end
end
