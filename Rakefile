require 'marvin'
require 'yaml'

namespace :marvin do
  task :start do
    env = ENV['MARVIN_ENV'] || 'development'
    config = YAML::load_file(File.dirname(__FILE__) + '/config/jabber.yml')[env]
    
    username, passwd = config.values_at("username", "passwd")
    
    Marvin.start({
      :jabber_server => "talk.google.com",
      :username => username,
      :passwd => passwd
    })
  end
end