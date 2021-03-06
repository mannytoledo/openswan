#
# Cookbook Name:: openswan
# Recipe:: default
#
# Copyright 2013, Wanelo, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

execute "apt-get update" do
  command "apt-get update"
end

package "openswan" do
  action :install
end

execute "turn on SNAT" do
  command "iptables -t nat -I POSTROUTING -o eth0 -j SNAT --to $(PUBIP)"
end

execute "turn on ipv4 forwarding" do
  command "echo 1 > /proc/sys/net/ipv4/ip_forward"
  not_if "grep 1 /proc/sys/net/ipv4/ip_forward"
end

script "turn off redirects" do
  user "root"
  cwd "/tmp"
  code <<-EOH
  echo 0 > /proc/sys/net/ipv4/conf/all/send_redirects
  echo 0 > /proc/sys/net/ipv4/conf/bond0/send_redirects
  echo 0 > /proc/sys/net/ipv4/conf/default/send_redirects
  echo 0 > /proc/sys/net/ipv4/conf/dummy0/send_redirects
  echo 0 > /proc/sys/net/ipv4/conf/eql/send_redirects
  echo 0 > /proc/sys/net/ipv4/conf/eth0/send_redirects
  echo 0 > /proc/sys/net/ipv4/conf/eth1/send_redirects
  echo 0 > /proc/sys/net/ipv4/conf/ip6tnl0/send_redirects
  echo 0 > /proc/sys/net/ipv4/conf/lo/send_redirects
  echo 0 > /proc/sys/net/ipv4/conf/sit0/send_redirects
  echo 0 > /proc/sys/net/ipv4/conf/tunl0/send_redirects
  echo 0 > /proc/sys/net/ipv4/conf/all/accept_redirects
  echo 0 > /proc/sys/net/ipv4/conf/bond0/accept_redirects
  echo 0 > /proc/sys/net/ipv4/conf/default/accept_redirects
  echo 0 > /proc/sys/net/ipv4/conf/dummy0/accept_redirects
  echo 0 > /proc/sys/net/ipv4/conf/eql/accept_redirects
  echo 0 > /proc/sys/net/ipv4/conf/eth0/accept_redirects
  echo 0 > /proc/sys/net/ipv4/conf/eth1/accept_redirects
  echo 0 > /proc/sys/net/ipv4/conf/ip6tnl0/accept_redirects
  echo 0 > /proc/sys/net/ipv4/conf/lo/accept_redirects
  echo 0 > /proc/sys/net/ipv4/conf/sit0/accept_redirects
  echo 0 > /proc/sys/net/ipv4/conf/tunl0/accept_redirects
  EOH
  not_if "grep 0 /proc/sys/net/ipv4/conf/tunl0/accept_redirects"
end

["ppp", "xl2tpd"].each do |p|
  package p
  action :install
end

template "#{node['openswan']['xl2tpd_path']}/xl2tpd.conf" do
  source "xl3tpd.conf.erb"
end 

template "#{node['openswan']['xl2tpd_path']}/options.xl2tpd" do
  source "options.xl2tpd.erb"
end

template "#{node['openswan']['ppp_path']}/chap-secrets" do
  source "chap-secrets.erb"
  notifies :reload, "service[xl2tpd]"
end

remote_file "#{Chef::Config[:file_cache_path]}/linux-image-3.8.4-joyent-ubuntu-12-opt_1.0.0_amd64.deb" do
  source "http://l03.ryan.net/data/linux-image-3.8.4-joyent-ubuntu-12-opt_1.0.0_amd64.deb"
end

remote_file "#{Chef::Config[:file_cache_path]}/linux-headers-3.8.4-joyent-ubuntu-12-opt_1.0.0_amd64.deb" do
  source "http://l03.ryan.net/data/linux-headers-3.8.4-joyent-ubuntu-12-opt_1.0.0_amd64.deb"
end

["linux-headers-3.8.4-joyent-ubuntu-12-opt_1.0.0_amd64", "linux-image-3.8.4-joyent-ubuntu-12-opt_1.0.0_amd64"].each do |p|
  dpkg_package p
  action :install
end

execute "restart xl2tpd and ipsec" do
  command "/etc/init.d/xl2tpd restart && /etc/init.d/ipsec restart"
end

execute "restart xl2tpd and ipsec" do
  command "/etc/init.d/xl2tpd restart && /etc/init.d/ipsec restart"
end