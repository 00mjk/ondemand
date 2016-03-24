require 'find'

class OscJob < ActiveRecord::Base
  has_many :jobs, class_name: "OscJobJob", dependent: :destroy
  has_machete_workflow_of :jobs

  # Name that defines the template/target dirs
  #def staging_template_name
  #  "osc_jobs"
  #end

  def staged_script_name
    File.basename(self.script_path)
  end

  def staging_template_dir
    File.dirname(self.script_path)
  end

  def folder_contents
    dir = self.staged_dir || Dir.home
    file_paths = []
    Find.find(dir) do |path|
      file_paths << path unless path == dir
    end
    file_paths
  end

  # Define tasks to do after staging template directory typically copy over
  # uploaded files here
  # def after_stage(staged_dir)
  #   # CODE HERE
  # end

  # Build an array of Machete jobs that are then submitted to the batch server
  def build_jobs(staged_dir, job_list = [])
    job_list << OSC::Machete::Job.new(script: staged_dir.join(staged_script_name))
  end

  # Make copy of workflow
  def copy
    self.dup
  end

end
