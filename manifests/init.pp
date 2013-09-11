class cephdeploy(
  $user = $::ceph_deploy_user,
  $pass = $::ceph_deploy_password,
){

  # cheesy hack so push autoadds host keys
  # needed because ceph-deploy doesn't have any cool args to do this
  exec { 'hack pushy':
    command => "/bin/sed -i 's/missing_host_key_policy=\"reject\"/missing_host_key_policy=\"autoadd\"/g' /usr/local/lib/python2.7/dist-packages/pushy/transport/ssh.py",
    unless  => '/bin/grep "missing_host_key_policy=\"autoadd\"" /usr/local/lib/python2.7/dist-packages/pushy/transport/ssh.py',
  }

  # add a user with ssh keys for gatherkeys to work for osd creation
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
    require => File["/home/$user/.ssh"],
  }

  file {"/home/$user/.ssh/authorized_keys":
    content => template('cephdeploy/id_rsa.pub.erb'),
    owner  => $user,
    group  => $user,
    mode   => 0600,
    require => File["/home/$user/.ssh"],
  }

  file {"/home/$user/.ssh/config":
    content => template('cephdeploy/config.erb'),
    owner  => $user,
    group  => $user,
    mode   => 0600,
    require => File["/home/$user/.ssh"],
  }

  file { "/home/$user/zapped":
    ensure => directory,
  }

  exec {'passwordless sudo for ceph deploy user':
    command => "/bin/echo \"$user ALL = (root) NOPASSWD:ALL\" | sudo tee /etc/sudoers.d/$user",
  }
 
  file {"/etc/sudoers.d/$user":
    mode    => 0440,
    require => Exec['passwordless sudo for ceph deploy user'],
  }

#  package {'python-pip':
#    ensure => present,
#  }

  package {'ceph-deploy':
    ensure   => present,
    provider => pip,
  }

  $cephdirs = ['/etc/ceph', '/etc/ceph/bootstrap']
  file {$cephdirs:
    ensure => directory,
    owner  => 'root',
    mode   => '0777',
  }

  file {'/etc/ceph/bootstrap/ceph.log':
    mode => 0777,
  }

  file { "ceph.conf":
    path    => '/etc/ceph/bootstrap/ceph.conf',
    content => template('cephdeploy/ceph.conf.erb'),
    require => File[$cephdirs],
  }

  file { "ceph.mon.keyring":
    path    => '/etc/ceph/bootstrap/ceph.mon.keyring',
    content => template('cephdeploy/ceph.mon.keyring.erb'),
    require => File['ceph.conf'],
  }

  exec { "install ceph":
    cwd     => '/etc/ceph/bootstrap',
    command => "/usr/local/bin/ceph-deploy install $::hostname",
    unless  => '/usr/bin/dpkg -l | grep ceph-common',
    require => [ Package['ceph-deploy'], File['ceph.mon.keyring'], File[$cephdirs] ],
  }


}
