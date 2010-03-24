$VERBOSE=false

class MonitorBackgroundJob < Scout::Plugin
  OPTIONS=<<-EOS
  path_to_app:
    name: Full Path to the Rails Application
    notes: "The full path to the Rails application (ex: /var/www/apps/APP_NAME/current)."
  rails_env:
    name: Rails environment that should be used
    default: production
  EOS
  
  
  needs 'active_record', 'yaml', 'erb'

  require 'active_record'
  class BjJob < ActiveRecord::Base
    self.table_name = 'bj_job'
  end
  
  def build_report
    
    app_path = option(:path_to_app)
    
    # Ensure path to db config provided
    if !app_path or app_path.empty?
      return error("The path to the Rails Application wasn't provided.","Please provide the full path to the Rails Application (ie - /var/www/apps/APP_NAME/current)")
    end
    
    db_config_path = app_path + '/config/database.yml'
    
    if !File.exist?(db_config_path)
      return error("The database config file could not be found.", "The database config file could not be found at: #{db_config_path}. Please ensure the path to the Rails Application is correct.")
    end
    
    db_config = YAML::load(ERB.new(File.read(db_config_path)).result)
    ActiveRecord::Base.establish_connection(db_config[option(:rails_env)])
        
    # Count jobs by state
    report_hash = {'finished' => 0, 'running' => 0, 'pending' => 0, 'dead' => 0}
    report_hash.merge!(Hash[BjJob.count(:state, :group => :state)])
    report_hash['failed'] = BjJob.count(:conditions => 'state = "finished" and exit_status != 0')
    
    report(report_hash)
  end
end
