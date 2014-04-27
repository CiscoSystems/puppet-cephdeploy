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
# [*primary_mon*]
#   (require) The primary MON in the monmap.
#
# [*pass*]
#   (required) The cephdeploy account password.
#
# [*setup_virsh*]
#   (optional) Configure virsh with ceph secret.
#   This allows nova-compute to use rbd.


class cephdeploy::client(
  $ceph_deploy_user = $cephdeploy::params::ceph_deploy_user,
  $pass = $cephdeploy::params::pass,
  $primary_mon = $cephdeploy::params::primary_mon,
  $setup_virsh = $cephdeploy::params::setup_virsh,
  $setup_pools = $cephdeploy::params::setup_pools,
  $cinder_system_group = $cephdeploy::params::cinder_system_group,
  $glance_system_group = $cephdeploy::params::glance_system_group,
  $cephx_keys_permission_enforce = $cephdeploy::params::cephx_keys_permission_enforce,
  $ceph_cluster_name = $cephdeploy::params::ceph_cluster_name,
  $glance_ceph_user = $cephdeploy::params::glance_ceph_user,
  $cinder_rbd_user = $cephdeploy::params::cinder_rbd_user,
  $puppet_install_repositories = $cephdeploy::params::puppet_install_repositories,
) inherits cephdeploy::params {

## User setup

  user {$ceph_deploy_user:
    ensure   => present,
    password => $pass,
    home     => "/home/$ceph_deploy_user",
    shell    => '/bin/bash',
  }

  file {"/home/$ceph_deploy_user":
    ensure  => directory,
    owner   => $ceph_deploy_user,
    group   => $ceph_deploy_user,
    mode    => '0755',
    require => User[$ceph_deploy_user],
  }

  file {"/home/$ceph_deploy_user/.ssh":
    ensure  => directory,
    owner   => $ceph_deploy_user,
    group   => $ceph_deploy_user,
    mode    => '0700',
    require => File["/home/$ceph_deploy_user"],
  }

  file {"/home/$ceph_deploy_user/.ssh/id_rsa":
    content => template('cephdeploy/id_rsa.erb'),
    owner   => $ceph_deploy_user,
    group   => $ceph_deploy_user,
    mode    => '0600',
    require => File["/home/$ceph_deploy_user/.ssh"],
  }

  file {"/home/$ceph_deploy_user/.ssh/id_rsa.pub":
    content => template('cephdeploy/id_rsa.pub.erb'),
    owner   => $ceph_deploy_user,
    group   => $ceph_deploy_user,
    mode    => '0644',
    require => File["/home/$ceph_deploy_user/.ssh"],
  }

  file {"/home/$ceph_deploy_user/.ssh/authorized_keys":
    content => template('cephdeploy/id_rsa.pub.erb'),
    owner   => $ceph_deploy_user,
    group   => $ceph_deploy_user,
    mode    => '0600',
    require => File["/home/$ceph_deploy_user/.ssh"],
  }

  file {"/home/$ceph_deploy_user/.ssh/config":
    content => template('cephdeploy/config.erb'),
    owner   => $ceph_deploy_user,
    group   => $ceph_deploy_user,
    mode    => '0600',
    require => File["/home/$ceph_deploy_user/.ssh"],
  }

  exec {'passwordless sudo for ceph deploy user':
    command => "/bin/echo \"$ceph_deploy_user ALL = (root) NOPASSWD:ALL\"\
                 | sudo tee /etc/sudoers.d/$ceph_deploy_user",
    unless  => "/usr/bin/test -e /etc/sudoers.d/$ceph_deploy_user",
  }

  file {"/etc/sudoers.d/$ceph_deploy_user":
    mode    => '0440',
    require => Exec['passwordless sudo for ceph deploy user'],
  }

  file {"/home/$ceph_deploy_user/bootstrap":
    ensure  => directory,
    owner   => $ceph_deploy_user,
    group   => $ceph_deploy_user,
    require => File["/home/$ceph_deploy_user"],
  }

  # install ceph client packages

  package {'ceph-deploy':
      ensure => present,
  }

  case $::osfamily {
    'RedHat', 'Suse': {
      if $ceph_install_repositories == 'true' {
        cephdeploy::yum {'ceph-packages':
          release => $ceph_release,
        }
      }
    }
    'Debian': {
      if $ceph_install_repositories == 'true' {
        cephdeploy::apt {'ceph-packages':
          release => $ceph_release,
        }
      }
    }
  }

  package {'ceph-common':
    ensure  => present,
    require => File["/home/$ceph_deploy_user/bootstrap"],
  }

  package {'python-ceph':
    ensure  => present,
    require => File["/home/$ceph_deploy_user/bootstrap"],
  }

  file { '/etc/ceph':
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    require => Package['ceph-common'],
  }

  # get and install config and keys

  exec { 'get keys':
    command => "/usr/bin/scp $ceph_deploy_user@${primary_mon}:bootstrap/{*.key*,ceph.conf} .",
    user    => $ceph_deploy_user,
    cwd     => "/home/$ceph_deploy_user/bootstrap",
    require => [ File["/home/$ceph_deploy_user/bootstrap"], File["/home/$ceph_deploy_user/.ssh/config"] ],
    unless  => "/usr/bin/test -e /home/$ceph_deploy_user/bootstrap/ceph.conf",
  }

  exec { 'place keys':
    command => "/bin/cp /home/$ceph_deploy_user/bootstrap/* /etc/ceph/",
    cwd     => "/home/$ceph_deploy_user/bootstrap",
    require => [ Exec['get keys'], File['/etc/ceph'] ],
    unless  => '/usr/bin/test -e /etc/ceph/ceph.conf',
  }

  if $setup_pools == 'true' {
    if $cephx_keys_permission_enforce == 'true' {

      file { "/etc/ceph/$ceph_cluster_name.keyring.client.$glance_ceph_user":
        group => "$glance_system_group",
	mode => "0640",
      }

      file { "/etc/ceph/$ceph_cluster_name.keyring.client.$cinder_rbd_user":
        group => "$cinder_system_group",
        mode => "0640",
      }
    }
  }


  if $setup_virsh == 'true' {

    if !defined(Package['libvirt-bin']) {
      package {'libvirt-bin':
        ensure => installed,
      }
    }

    file { '/etc/ceph/secret.xml':
      content => template('cephdeploy/secret.xml-compute.erb'),
      require => Package['ceph-common'],
    }

    exec { 'get-or-set virsh secret':
      command => '/usr/bin/virsh secret-define --file /etc/ceph/secret.xml | /usr/bin/awk \'{print $2}\' | sed \'/^$/d\' > /etc/ceph/virsh.secret',
      creates => '/etc/ceph/virsh.secret',
      require => [ Package['libvirt-bin'], File['/etc/ceph/secret.xml'] ],
    }

    exec { 'set-secret-value virsh':
      command => "/usr/bin/virsh secret-set-value --secret $(cat /etc/ceph/virsh.secret) --base64 $(ceph auth get-key $cinder_rbd_user)",
      require => Exec['get-or-set virsh secret'],
    }

  }




}
