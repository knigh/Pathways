class Emailer < ActionMailer::Base

   def submit(recipient, recipient_name, submitter, subject, title, formal_name, informal_name, encoded_url, sent_at = Time.now)
      @subject = subject
      @recipients = recipient
      @from = 'team@stanfordpathways.com'
	  @bcc = 'submissions@stanfordpathways.com'
      @sent_on = sent_at
	  @body["title"] = title
  	  @body["email"] = 'team@stanfordpathways.com'
	  @body["recipient_name"] = recipient_name
	  @body["submitter"] = submitter
	  @body["formal_name"] = formal_name
	  @body["informal_name"] = informal_name
	  @body["encoded_url"] = encoded_url 
      @headers = {}
   end
   
   def signup_notification(recipient, recipient_name, subject, title, formal_name, informal_name, admin_email, encoded_url, sent_at = Time.now)
      @subject = subject
      @recipients = recipient
      @from = admin_email
	  @bcc = 'signup@stanfordpathways.com'
      @sent_on = sent_at
	  @body["title"] = title
  	  @body["email"] = admin_email
	  @body["recipient_name"] = recipient_name
	  @body["formal_name"] = formal_name
	  @body["informal_name"] = informal_name
	  @body["encoded_url"] = encoded_url
      @headers = {}
	end
	
	def signup_pending(recipient, recipient_name, subject, title, formal_name, informal_name, admin_email, sent_at = Time.now)
      @subject = subject
      @recipients = recipient
      @from = admin_email
	  @bcc = 'signup@stanfordpathways.com'
      @sent_on = sent_at
	  @body["title"] = title
  	  @body["email"] = admin_email
	  @body["recipient_name"] = recipient_name
	  @body["formal_name"] = formal_name
	  @body["informal_name"] = informal_name
      @headers = {}
	end
	
end
