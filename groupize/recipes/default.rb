Chef::Log.info("sourcing environment variables initializer")
node[:deploy].each do |application, deploy|
  deploy = node[:deploy][application]
  execute "restart Rails app #{application}" do
    Chef::Log.debug("restarting Rails app after setting env vars")
    cwd deploy[:current_path]
    command node[:opsworks][:rails_stack][:restart_command]
    action :nothing
  end

  template "#{deploy[:deploy_to]}/current/config/initializers/env_vars.rb" do
    source "env_vars.erb"
    cookbook 'rails'
    mode "0660"
    group deploy[:group]
    owner deploy[:user]
    variables(:smtp => deploy[:smtp], :environment => deploy[:rails_env])

    notifies :run, resources(:execute => "restart Rails app #{application}")

    only_if do
      File.exists?("#{deploy[:deploy_to]}") && File.exists?("#{deploy[:deploy_to]}/current/config/")
    end
  end
end

Chef::Log.info("Set up directory for asset precompile")
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

