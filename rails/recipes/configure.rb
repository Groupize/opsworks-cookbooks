# include_recipe "deploy"
#
# node[:deploy].each do |application, deploy|
#
#   if deploy[:application_type] != 'rails'
#     Chef::Log.debug("Skipping rails::configure application #{application} as it is not an Rails app")
#     next
#   end
#
#   node.default[:deploy][application][:database][:adapter] = OpsWorks::RailsConfiguration.determine_database_adapter(
#     application,
#     deploy,
#     "#{deploy[:deploy_to]}/current",
#     :force => node[:force_database_adapter_detection],
#     :consult_gemfile => deploy[:auto_bundle_on_deploy]
#   )
#
#   deploy = node[:deploy][application] # update the value, as a key was just added.
#
#   rails_configuration "Update opsworks configration for app #{application.inspect} and restart rails application stack" do
#     application application
#     deploy_to deploy[:deploy_to]
#     rails_env deploy[:rails_env]
#     user deploy[:user]
#     group deploy[:group]
#     database_data deploy[:database]
#     memcached_data deploy[:memcached] || {}
#
#     restart true
#   end
#
# end

include_recipe "deploy"

node[:deploy].each do |application, deploy|
  deploy = node[:deploy][application]

  execute "restart Rails app #{application}" do
    cwd deploy[:current_path]
    command node[:opsworks][:rails_stack][:restart_command]
    action :nothing
  end

  node[:deploy][application][:database][:adapter] = OpsWorks::RailsConfiguration.determine_database_adapter(application, node[:deploy][application], "#{node[:deploy][application][:deploy_to]}/current", :force => node[:force_database_adapter_detection])

  template "#{deploy[:deploy_to]}/shared/config/database.yml" do
    source "database.yml.erb"
    cookbook 'rails'
    mode "0660"
    group deploy[:group]
    owner deploy[:user]
    variables(:database => deploy[:database], :environment => deploy[:rails_env])

    notifies :run, resources(:execute => "restart Rails app #{application}")

    only_if do
      File.exists?("#{deploy[:deploy_to]}") && File.exists?("#{deploy[:deploy_to]}/shared/config/")
    end
  end

  template "#{deploy[:deploy_to]}/shared/config/memcached.yml" do
    source "memcached.yml.erb"
    cookbook 'rails'
    mode "0660"
    group deploy[:group]
    owner deploy[:user]
    variables(
      :memcached => deploy[:memcached] || {},
      :environment => deploy[:rails_env]
    )

    notifies :run, resources(:execute => "restart Rails app #{application}")

    only_if do
      File.exists?("#{deploy[:deploy_to]}") && File.exists?("#{deploy[:deploy_to]}/shared/config/")
    end
  end
end
