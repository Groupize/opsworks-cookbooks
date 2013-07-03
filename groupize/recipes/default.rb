Chef::Log.info("Running asset precompile")
node[:deploy].each do |application, deploy|
  rails_env = node[:deploy][application][:rails_env]
  Chef::Log.info("Ensuring shared/assets directory for #{application} app in environment #{rails_env}...")
  directory "#{deploy[:deploy_to]}/shared/assets" do
    group deploy[:group]
    owner deploy[:user]
    mode 0775
    action :create
    recursive true
  end
end
