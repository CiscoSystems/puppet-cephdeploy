class cephdeploy::client(
  $user        = hiera('ceph_deploy_user'),
  $primary_mon = hiera('ceph_primary_mon'),
){

## User setup

  user {$user:
    ensure   => present,
    password => $pass,
    home     => "/home/$user",
    shell    => '/bin/bash',
  }

  file {"/home/$user":
    ensure  => directory,
    owner   => $user,
    group   => $user,
    mode    => 0755,
    require => User[$user],
  }
  
  file {"/home/$user/.ssh":
    ensure  => directory,
    owner   => $user,
    group   => $user,
    mode    => 0700,
    require => File["/home/$user"],
  }

  file {"/home/$user/.ssh/id_rsa":
    content => template('cephdeploy/id_rsa.erb'),
    owner   => $user,
    group   => $user,
    mode    => 0600,
    require => File["/home/$user/.ssh"],
  }

  file {"/home/$user/.ssh/id_rsa.pub":
    content => template('cephdeploy/id_rsa.pub.erb'),
    owner   => $user,
    group   => $user,
    mode    => 0644,
    require => File["/home/$user/.ssh"],
  }

  file {"/home/$user/.ssh/authorized_keys":
    content => template('cephdeploy/id_rsa.pub.erb'),
    owner   => $user,
    group   => $user,
    mode    => 0600,
    require => File["/home/$user/.ssh"],
  }

  file {"/home/$user/.ssh/config":
    content => template('cephdeploy/config.erb'),
    owner   => $user,
    group   => $user,
    mode    => 0600,
    require => File["/home/$user/.ssh"],
  }

  file {"log $user":
    owner   => $user,
    group   => $user,
    mode    => 0777,
    path    => "/home/$user/bootstrap/ceph.log",
    require => [ Exec["install ceph"], File["/etc/sudoers.d/$user"], File["/home/$user"], User[$user] ],
  }

  exec {'passwordless sudo for ceph deploy user':
    command => "/bin/echo \"$user ALL = (root) NOPASSWD:ALL\" | sudo tee /etc/sudoers.d/$user",
    unless  => "/usr/bin/test -e /etc/sudoers.d/$user",
  }

  file {"/etc/sudoers.d/$user":
    mode    => 0440,
    require => Exec['passwordless sudo for ceph deploy user'],
  }

  file {"/home/$user/bootstrap":
    ensure  => directory,
    owner   => $user,
    group   => $user,
    require => File["/home/$user"],
  }

  # install ceph client packages

  package {'ceph-common':
    ensure => present,
    require => File["/home/$user/bootstrap"],
  }

  package {'python-ceph':
    ensure => present,
    require => File["/home/$user/bootstrap"],
  }

  # get and install config and keys

  exec {'get conf':
    cwd     => "/home/$user/bootstrap",
    command => "/usr/bin/ceph-deploy config pull $primary_mon && /usr/bin/ceph-deploy gatherkeys $primary_mon",
    unless  => "/usr/bin/test -e /home/$user/bootstrap/ceph.client.admin.keyring",
    require => Package['ceph-common'],
  }


}
