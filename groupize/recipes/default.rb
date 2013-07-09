execute "restart Rails app #{application}" do
  cwd deploy[:current_path]
  command node[:opsworks][:rails_stack][:restart_command]
  action :nothing
end

Chef::Log.info("sourcing SMTP initializer")
node[:deploy].each do |application, deploy|
  template "#{deploy[:deploy_to]}/current/config/initializers/smtp.rb" do
    source "smtp.rb.erb"
    cookbook 'rails'
    mode "0660"
    group deploy[:group]
    owner deploy[:user]
    variables(:smtp => deploy[:smtp], :environment => deploy[:rails_env])

    notifies :run, resources(:execute => "restart Rails app #{application}")
  end
end

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

