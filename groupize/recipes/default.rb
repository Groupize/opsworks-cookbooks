Chef::Log.info("Running asset precompile")
node[:deploy].each do |application, deploy|
  rails_env = node[:deploy][application][:rails_env]
  Chef::Log.info("Precompiling for #{rails_env}")
end
