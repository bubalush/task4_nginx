nginx = "#{node['network']['interfaces']['enp0s8']['routes'][0]["src"]}"


package 'nginx'

template "/etc/nginx/nginx.conf" do
  source "nginx.conf.erb"
  variables({ 
    :ip_nginx => "#{nginx}",  
    })
  action :create_if_missing
end

service "nginx" do
  action [ :enable, :start ]
  supports :restart => true
end

lb "nginx" do
  action :attach
  role "apache_server"
end


