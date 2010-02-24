class Emailer < ActionMailer::Base

   def submit(recipient, recipient_name, submitter, subject, title, formal_name, informal_name, encoded_url, sent_at = Time.now)
      @subject = subject
      @recipients = recipient
      @from = 'no-reply@stanfordpathways.com'
      @sent_on = sent_at
	  @body["title"] = title
  	  @body["email"] = 'sender@stanfordpathways.com'
          @body["recipient_name"] = recipient_name
          @body["submitter"] = submitter
          @body["formal_name"] = formal_name
	  @body["informal_name"] = informal_name
          @body["encoded_url"] = encoded_url 
      @headers = {}
   end

end
