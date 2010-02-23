class RailsSessionMonitor < Scout::Plugin
  TEST_USAGE = "#{File.basename($0)} path_to_app PATH_TO_APP rails_env RAILS_ENV"

  def run
    ENV['RAILS_ENV'] = @options['rails_env']
    # Ensure require options are provided
    if @options['rails_env'].nil?
      return { :error => {:subject => "Required option not provided",
                          :body    => "Please specify the Rails environment (ie: production, development, test)."}}
    elsif @options['path_to_app'].nil?
      return { :error => {:subject => "Required option not provided",
                          :body    => "The full path to your Rails application is required (ex: /var/www/apps/APP_NAME/current)."}}
    end
    # Load the Rails Env
    quietly { require "#{@options['path_to_app']}/config/environment" }

    total = ActiveRecord::Base.connection.select_value("SELECT count(*) from sms_sessions")
    
    {
      :report => {
        :total => total
      }
    }
  rescue
    { :error => {:subject => "Unable to Monitor SMS Sessions", 
      :body => "The following exception was raised:\n\n#{$!.message}\n\n#{$!.backtrace}"}}
  end

  def quietly
    old_verbose, $VERBOSE = $VERBOSE, false
    yield
  ensure
    $VERBOSE = old_verbose
  end
end
