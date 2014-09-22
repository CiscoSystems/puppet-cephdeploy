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

# === Parameters:
#
# [*ceph_deploy_user*]
#   (required) The cephdeploy account username
#
# [*ceph_public_interface*]
#   (required) The interface for MON to listen on.
#
# [*ceph_public_network*]
#   (required) The client-facing network.
#
# [*ceph_primary_mon*]
#   (required) The primary MON in the monmap.
#
# [*ceph_cluster_name*]
#   (required) The ceph cluster name.
#


class cephdeploy::mon(
  $ceph_deploy_user = $cephdeploy::params::ceph_deploy_user,
  $ceph_public_interface = $cephdeploy::params::ceph_public_interface,
  $ceph_public_network = $cephdeploy::params::ceph_public_network,
  $ceph_primary_mon = $cephdeploy::params::ceph_primary_mon,
  $ceph_cluster_name = $cephdeploy::params::ceph_cluster_name,
  $setup_pools = $cephdeploy::params::setup_pools,
  $glance_ceph_user = $cephdeploy::params::glance_ceph_user,
  $glance_ceph_pool = $cephdeploy::params::glance_ceph_pool,
  $cinder_rbd_user = $cephdeploy::params::cinder_rbd_user,
  $cinder_rbd_pool = $cephdeploy::params::cinder_rbd_pool,
) inherits cephdeploy::params {

  include cephdeploy

  exec { 'create mon':
    cwd      => "/home/$ceph_deploy_user/bootstrap",
    command  => "/usr/bin/ceph-deploy --ceph-conf=/home/$ceph_deploy_user/bootstrap/ceph.initial.conf mon create $::hostname",
    unless   => '/usr/bin/sudo /usr/bin/ceph --cluster=ceph --admin-daemon /var/run/ceph/`hostname -s`-mon.ceph.asok mon_status',
    require  => Exec['install ceph'],
    provider => shell,
  }

  exec { 'gather keys':
    cwd      => "/home/$ceph_deploy_user/bootstrap",
    command  => "/usr/bin/ceph-deploy gatherkeys $::hostname",
    require  => Exec['create mon'],
  }

  if $ceph_primary_mon == $::hostname {
    exec { 'copy keys':
      path => '/bin:/usr/bin',
      command => "cp /var/lib/ceph/bootstrap-mds/$ceph_cluster_name.keyring /home/$ceph_deploy_user/bootstrap/$ceph_cluster_name.bootstrap-mds.keyring &&
cp /var/lib/ceph/bootstrap-osd/$ceph_cluster_name.keyring /home/$ceph_deploy_user/bootstrap/$ceph_cluster_name.bootstrap-osd.keyring &&
cp /etc/ceph/ceph.client.admin.keyring /home/$ceph_deploy_user/bootstrap/ceph.client.admin.keyring &&
cp /var/lib/ceph/mon/ceph-$ceph_primary_mon/keyring /home/$ceph_deploy_user/bootstrap/ceph.mon.keyring &&
chown $ceph_deploy_user:$ceph_deploy_user /home/$ceph_deploy_user/bootstrap/* &&
chmod 644 /home/$ceph_deploy_user/bootstrap/*
",
      require => [ Exec['create mon'], Exec['gather keys'] ],
      unless => "/usr/bin/test -e /home/$ceph_deploy_user/bootstrap/$cluster.bootstrap-osd.keyring",
    }
  }

  exec {'iptables mon':
    command => "/sbin/iptables -A INPUT -i $ceph_public_interface -p tcp -s $ceph_public_network --dport 6789 -j ACCEPT",
    unless  => '/sbin/iptables -L | grep "tcp dpt:6789"',
  }

  if $setup_pools == 'true' {

    if $ceph_primary_mon == $::hostname {

      if $glance_ceph_user != 'admin' {
        exec { "create glance cephx user $glance_ceph_user":
          command => "/usr/bin/ceph auth get-or-create client.$glance_ceph_user mon 'allow *' osd 'allow * pool=$glance_ceph_pool' > /etc/ceph/$ceph_cluster_name.client.$glance_ceph_user.keyring",
          unless  => "/usr/bin/ceph auth list | grep -sq $glance_ceph_user",
          require => [ Exec['create mon'], Exec['gather keys'] ],
        }
        exec { "copy glance user key $glance_ceph_user":
          path => '/bin:/usr/bin',
          command => "cp /etc/ceph/$ceph_cluster_name.client.$glance_ceph_user.keyring /home/$ceph_deploy_user/bootstrap/$ceph_cluster_name.client.$glance_ceph_user.keyring && chown $ceph_deploy_user:$ceph_deploy_user /home/$ceph_deploy_user/bootstrap/$ceph_cluster_name.client.$glance_ceph_user.keyring",
          require => Exec["create glance cephx user $glance_ceph_user"],
        }
      }

      if $cinder_rbd_user != 'admin' {
        exec { "create cinder cephx user $cinder_rbd_user":
          command => "/usr/bin/ceph auth get-or-create client.$cinder_rbd_user mon 'allow *' osd 'allow * pool=$cinder_rbd_pool' > /etc/ceph/$ceph_cluster_name.client.$cinder_rbd_user.keyring",
          unless  => "/usr/bin/ceph auth list | grep -sq $cinder_rbd_user",
          require => [ Exec['create mon'], Exec['gather keys'] ],
        }
        exec { 'copy cinder user key $cinder_rbd_user':
          path => '/bin:/usr/bin',
          command => "cp /etc/ceph/$ceph_cluster_name.client.$cinder_rbd_user.keyring /home/$ceph_deploy_user/bootstrap/$ceph_cluster_name.client.$cinder_rbd_user.keyring && chown $ceph_deploy_user:$ceph_deploy_user /home/$ceph_deploy_user/bootstrap/$ceph_cluster_name.client.$cinder_rbd_user.keyring",
          require => Exec["create cinder cephx user $cinder_rbd_user"],
        }
      }

    }

  }

}
