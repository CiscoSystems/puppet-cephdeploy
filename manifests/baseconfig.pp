class cephdeploy::baseconfig(
  $user = $::ceph_deploy_user,
  $pass = $::ceph_deploy_password,
){

  include pip

  user {$user:
    ensure => present,
    password => $pass,
    home     => "/home/$user",
    shell    => '/bin/bash',
  }

  file {"/home/$user":
    ensure => directory,
    owner  => $user,
    group  => $user,
    mode   => 0755,
    require => User[$user],
  }
  
  file {"/home/$user/.ssh":
    ensure => directory,
    owner  => $user,
    group  => $user,
    mode   => 0700,
    require => File["/home/$user"],
  }

  file {"/home/$user/.ssh/id_rsa":
    content => template('cephdeploy/id_rsa.erb'),
    owner  => $user,
    group  => $user,
    mode   => 0600,
    require => File["/home/$user/.ssh"],
  }

  file {"/home/$user/.ssh/id_rsa.pub":
    content => template('cephdeploy/id_rsa.pub.erb'),
    owner  => $user,
    group  => $user,
    mode   => 0644,
    require => File["/home/$user/.ssh/id_rsa"],
  }

  file {"/home/$user/.ssh/authorized_keys":
    content => template('cephdeploy/id_rsa.pub.erb'),
    owner  => $user,
    group  => $user,
    mode   => 0600,
    require => File["/home/$user/.ssh/id_rsa.pub"],
  }

  file {"/home/$user/.ssh/config":
    content => template('cephdeploy/config.erb'),
    owner  => $user,
    group  => $user,
    mode   => 0600,
    require => File["/home/$user/.ssh/authorized_keys"],
  }

  exec {'passwordless sudo for ceph deploy user':
    command => "/bin/echo \"$user ALL = (root) NOPASSWD:ALL\" | sudo tee /etc/sudoers.d/$user",
    unless  => "/usr/bin/test -e /etc/sudoers.d/$user",
    require => File["/home/$user/.ssh/config"],
  }
 
  file {"/etc/sudoers.d/$user":
    mode    => 0440,
    require => Exec['passwordless sudo for ceph deploy user'],
  }

  file {"log $disk":
    owner => $user,
    group => $user,
    mode  => 0777,
    path  => "/home/$user/bootstrap/ceph.log",
    require => [ Exec["install ceph"], file["/etc/sudoers.d/$user"], ],
  }

  exec {'install ceph-deploy':
    command => '/usr/bin/pip install ceph-deploy', 
    unless  => '/usr/bin/pip install ceph-deploy | /bin/grep satisfied',
    require => Package['python-pip']
  }

  file {"/home/$user/bootstrap":
    ensure => directory,
    owner  => $user,
    group  => $user,
    require => file["/etc/sudoers.d/$user"],
  }

  file { "ceph.conf":
    owner   => $user,
    group   => $user,
    path    => "/home/$user/bootstrap/ceph.conf",
    content => template('cephdeploy/ceph.conf.erb'),
    require => File["/home/$user/bootstrap"],
  }

  file { "ceph.mon.keyring":
    owner   => $user,
    group   => $user,
    path    => "/home/$user/bootstrap/ceph.mon.keyring",
    content => template('cephdeploy/ceph.mon.keyring.erb'),
    require => File['ceph.conf'],
  }

  exec { "install ceph":
    cwd     => "/home/$user/bootstrap",
    command => "/usr/local/bin/ceph-deploy install $::hostname",
    unless  => '/usr/bin/dpkg -l | grep ceph-common',
    require => file["ceph.mon.keyring"],
  }

  exec {'gatherkeys':
    cwd     => "/home/$user/bootstrap",
    command => "/usr/local/bin/ceph-deploy gatherkeys $::ceph_primary_mon",
    unless  => '/usr/bin/test -e /etc/ceph/ceph.client.admin.keyring',
    user     => $user,
    require => exec['install ceph'],
  }

  exec {'copy key':
    command => "/bin/cp /home/$user/bootstrap/ceph.client.admin.keyring /etc/ceph",
    unless  => '/usr/bin/test -e /etc/ceph/ceph.client.admin.keyring',
    require => exec['gatherkeys'],
  }
  
  exec {'copy ceph.conf':
    command => "/bin/cp /home/$user/bootstrap/ceph.conf /etc/ceph",
    unless  => '/usr/bin/test -e /etc/ceph/ceph.conf',
    require => exec['gatherkeys'],
  }

  file {'service perms':
    mode => 0644,
    path => '/etc/ceph/ceph.client.admin.keyring',
    require => exec['copy key'],
  }


}
