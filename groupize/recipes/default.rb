Chef::Log.info("Running asset precompile")
rails_env = node[:deploy][application][:rails_env]
Chef::Log.info("Precompiling for #{rails_env}")
