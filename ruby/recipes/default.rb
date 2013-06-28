include_recipe 'ruby_build'

ruby_build_ruby "#{node[:ruby][:full_version]}-#{node[:ruby][:patch]}" do
  prefix_path "/usr/local/bin"
end

include_recipe 'opsworks_rubygems'
include_recipe 'opsworks_bundler'
