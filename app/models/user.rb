class User < ActiveRecord::Base
	has_many :jobs
	
  after_update :save_jobs

  def new_job_attributes=(job_attributes)
    job_attributes.each do |attributes|
      jobs.build(attributes)
    end 
  end

  def existing_job_attributes=(job_attributes)
    jobs.reject(&:new_record?).each do |job|
      attributes = job_attributes[job.id.to_s]
      if attributes['_delete'] == '1'
        jobs.delete(job)
      else
       job.attributes = attributes
      end
    end
  end

  private

  def save_jobs
    jobs.each do |job|
      job.save(false)
    end
  end

  validates_associated :jobs
  
end
