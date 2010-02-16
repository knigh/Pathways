class User < ActiveRecord::Base
	has_many :jobs
	has_many :degrees
	
  after_update :save_jobs, :save_degrees

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

  def new_degree_attributes=(degree_attributes)
    degree_attributes.each do |attributes|
      degrees.build(attributes)
    end 
  end

  def existing_degree_attributes=(degree_attributes)
    degrees.reject(&:new_record?).each do |degree|
      attributes = degree_attributes[degree.id.to_s]
      if attributes['_delete'] == '1'
        degrees.delete(degree)
      else
       degree.attributes = attributes
      end
    end
  end

    private

  def save_jobs
    jobs.each do |job|
      job.save(false)
    end
  end

  def save_degrees
    degrees.each do |degree|
      degree.save(false)
    end
  end
  

  validates_associated :jobs
  validates_associated :degrees

  
  validates_presence_of :name, :email
  validates_uniqueness_of :email, :message => "is already in use"
  
end
