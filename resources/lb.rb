resource_name :lb
property :role, String, default: 'default'


action :attach do

	search(:node, "role:#{new_resource.role}").each do |node|
		ruby_block "ensure node ip address in nginx.conf" do
  		ip_node = "#{node['network']['interfaces']['enp0s8']['routes'][0]['src']}"
  		block do
    		fe = Chef::Util::FileEdit.new("/etc/nginx/nginx.conf")
    		fe.insert_line_after_match(/upstream(.*)/,"server #{ip_node};")
    		fe.write_file    		
				service "nginx" do    
					action :restart  
				end 
  		end
  		only_if { ::File.readlines("/etc/nginx/nginx.conf").grep(/server #{ip_node};/).size == 0 }
  	end
	end

end


action :detach do

	search(:node, "role:#{new_resource.role}").each do |node|
		ruby_block "ensure node ip address out of nginx.conf" do
  		ip_node = "#{node['network']['interfaces']['enp0s8']['routes'][0]['src']}"
  		block do
    		fe = Chef::Util::FileEdit.new("/etc/nginx/nginx.conf")
    		fe.search_file_delete_line(/server #{ip_node};/)
    		fe.write_file
    		service "nginx" do    
					action :restart  
				end 
  		end
  		only_if { ::File.readlines("/etc/nginx/nginx.conf").grep(/server #{ip_node};/).size > 0 }
  	end
	end

end

