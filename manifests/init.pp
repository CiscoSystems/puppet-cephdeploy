class cephdeploy(
  $user = $::ceph_deploy_user,
  $pass = $::ceph_deploy_password,
  $has_compute = false,
){

#  include pip

## User setup

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

  exec {'passwordless sudo for ceph deploy user':
    command => "/bin/echo \"$user ALL = (root) NOPASSWD:ALL\" | sudo tee /etc/sudoers.d/$user",
    unless  => "/usr/bin/test -e /etc/sudoers.d/$user",
  }

  file {"/etc/sudoers.d/$user":
    mode    => 0440,
    require => Exec['passwordless sudo for ceph deploy user'],
  }

  file { "/home/$user/zapped":
    ensure => directory,
  }

  file {"/home/$user/bootstrap":
    ensure => directory,
    owner  => $user,
    group  => $user,
  }

## Install ceph and dependencies

  package {'python-pip':
    ensure => installed,
  }

  exec {'install ceph-deploy':
    command => '/usr/bin/pip install ceph-deploy', 
    require => Package['python-pip'],
    unless  => '/usr/bin/pip install ceph-deploy | /bin/grep satisfied',
  }

# this is here for some forgotten reason but may be useful at some point
#  file { 'ceph.conf':
#  file { "/home/$user/bootstrap/ceph.conf":
#    owner   => $user,
#    group   => $user,
#    path    => "/home/$user/bootstrap/ceph.conf",
#    content => template('cephdeploy/ceph.conf.erb'),
#    require => File["/home/$user/bootstrap"],
#  }

## ceph.conf setup

  concat { "/home/$user/bootstrap/ceph.conf":
    owner   => $user,
    group   => $user,
    path    => "/home/$user/bootstrap/ceph.conf",
    require => File["/home/$user/bootstrap"],
  }

  concat::fragment { 'ceph':
    target  => "/home/$user/bootstrap/ceph.conf",
    order   => '01',
    content => template('cephdeploy/ceph.conf.erb'),
    require => File["/home/$user/bootstrap"],
  }

## Keyring setup

  file { "ceph.mon.keyring":
    owner   => $user,
    group   => $user,
    path    => "/home/$user/bootstrap/ceph.mon.keyring",
    content => template('cephdeploy/ceph.mon.keyring.erb'),
    require => File["/home/$user/bootstrap/ceph.conf"],
  }

  file {'service perms':
    mode => 0644,
    path => '/etc/ceph/ceph.client.admin.keyring',
    require => exec['install ceph'],
  }

  exec { "install ceph":
    cwd     => "/home/$user/bootstrap",
    command => "/usr/local/bin/ceph-deploy install $::hostname",
    unless  => '/usr/bin/dpkg -l | grep ceph-common',
    require => [ Exec['install ceph-deploy'], File['ceph.mon.keyring'], File["/home/$user/bootstrap"] ],
  }

## If the ceph node is also running nova-compute

  if $has_compute {

    file { '/etc/ceph/secret.xml':
      content => template('cephdeploy/secret.xml-compute.erb'),
      require => Exec["install ceph"],
    }

    exec { 'get-or-set virsh secret':
      command => '/usr/bin/virsh secret-define --file /etc/ceph/secret.xml | /usr/bin/awk \'{print $2}\' | sed \'/^$/d\' > /etc/ceph/virsh.secret',
      creates => "/etc/ceph/virsh.secret",
      require => [ File['ceph.conf'], Package['libvirt-bin'], File['/etc/ceph/secret.xml'] ],
    }

    exec { 'set-secret-value virsh':
      command => "/usr/bin/virsh secret-set-value --secret $(cat /etc/ceph/virsh.secret) --base64 $(ceph auth get-key client.admin)",
      require => [ Exec['get-or-set virsh secret'], Exec['install ceph'] ],
    }

  }


}
