require 'marvin'
require 'yaml'

namespace :marvin do
  task :start do
    env = ENV['MARVIN_ENV'] || 'development'    
    config = YAML::load_file(File.dirname(__FILE__) + '/config/jabber.yml')[env]
    
    Marvin.start(config)
  end
end