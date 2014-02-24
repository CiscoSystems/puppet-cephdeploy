class cephdeploy::client(
  $user        = 'cephdeploy',
  $primary_mon = 'kraken',
  $pass        = hiera('ceph_deploy_password'),
){

## User setup

  user {$user:
    ensure   => present,
    password => $pass,
    home     => "/home/${user}",
    shell    => '/bin/bash',
  }

  file {"/home/${user}":
    ensure  => directory,
    owner   => $user,
    group   => $user,
    mode    => '0755',
    require => User[$user],
  }

  file {"/home/${user}/.ssh":
    ensure  => directory,
    owner   => $user,
    group   => $user,
    mode    => '0700',
    require => File["/home/${user}"],
  }

  file {"/home/${user}/.ssh/id_rsa":
    content => template('cephdeploy/id_rsa.erb'),
    owner   => $user,
    group   => $user,
    mode    => '0600',
    require => File["/home/${user}/.ssh"],
  }

  file {"/home/${user}/.ssh/id_rsa.pub":
    content => template('cephdeploy/id_rsa.pub.erb'),
    owner   => $user,
    group   => $user,
    mode    => '0644',
    require => File["/home/${user}/.ssh"],
  }

  file {"/home/${user}/.ssh/authorized_keys":
    content => template('cephdeploy/id_rsa.pub.erb'),
    owner   => $user,
    group   => $user,
    mode    => '0600',
    require => File["/home/${user}/.ssh"],
  }

  file {"/home/${user}/.ssh/config":
    content => template('cephdeploy/config.erb'),
    owner   => $user,
    group   => $user,
    mode    => '0600',
    require => File["/home/${user}/.ssh"],
  }

  exec {'passwordless sudo for ceph deploy user':
    command => "/bin/echo \"${user} ALL = (root) NOPASSWD:ALL\"\
                 | sudo tee /etc/sudoers.d/${user}",
    unless  => "/usr/bin/test -e /etc/sudoers.d/${user}",
  }

  file {"/etc/sudoers.d/${user}":
    mode    => '0440',
    require => Exec['passwordless sudo for ceph deploy user'],
  }

  file {"/home/${user}/bootstrap":
    ensure  => directory,
    owner   => $user,
    group   => $user,
    require => File["/home/${user}"],
  }

  # install ceph client packages

  package {'ceph-common':
    ensure  => present,
    require => File["/home/${user}/bootstrap"],
  }

  package {'python-ceph':
    ensure  => present,
    require => File["/home/${user}/bootstrap"],
  }

  file { '/etc/ceph':
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    require => Package['ceph-common'],
  }

  # get and install config and keys

  exec { 'get keys':
    command => "/usr/bin/scp ${user}@${primary_mon}:bootstrap/{*.key*,ceph.conf} .",
    user    => $user,
    cwd     => "/home/${user}/bootstrap",
    require => [ File["/home/${user}/bootstrap"], File["/home/${user}/.ssh/config"] ],
    unless  => "/usr/bin/test -e /home/${user}/bootstrap/ceph.conf",
  }

  exec { 'place keys':
    command => "/bin/cp /home/${user}/bootstrap/* /etc/ceph/",
    cwd     => "/home/${user}/bootstrap",
    require => [ Exec['get keys'], File['/etc/ceph'] ],
    unless  => '/usr/bin/test -e /etc/ceph/ceph.conf',
  }



}
