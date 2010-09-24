class RailsSessionMonitor < Scout::Plugin
  OPTIONS=<<-EOS
  path_to_app:
    name: Full Path to the Rails Application
    notes: "The full path to the Rails application (ex: /var/www/apps/APP_NAME/current)."
  rails_env:
    name: Rails environment that should be used
    default: production
  EOS

  needs 'active_record', 'action_controller', 'yaml', 'erb'

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

    total = ActiveRecord::SessionStore::Session.count
    
    report(:total => total)
  end
end
