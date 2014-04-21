#   Copyright 2013-2014 Cisco Systems, Inc.
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#
#   Author: Donald Talton <dotalton@cisco.com>


## WIP not yet functional

class cephdeploy::mds(
  $user = $cephdeploy::params::ceph_deploy_user,
) inherits cephdeploy::params {

  include cephdeploy

  exec { 'create mds':
    cwd     => "/home/$user/bootstrap",
    command => "/usr/local/bin/ceph-deploy mds create $::hostname",
    unless  => '/bin/ps -ef | /bin/grep -v grep | /bin/grep ceph-mds',
    require => Exec['install ceph'],
    provider => shell,
  }

  exec {'iptables mds':
    command => "/sbin/iptables -A INPUT -i $::ceph_public_interface -m multiport tcp -s $::ceph_public_network --dport 6800:6810 -j ACCEPT",
    unless  => '/sbin/iptables -L | grep "multiport dports 6800:6810"',
  }


}
