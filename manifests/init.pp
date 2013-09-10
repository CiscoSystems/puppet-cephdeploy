class cephdeploy(
  $user = $::ceph_deploy_user,
  $pass = $::ceph_deploy_pass,
){
  
  package {'python-pip':
    ensure => present,
  }

  # get latest ceph-deploy
  exec {'get ceph-deploy':
    cwd     => '/etc/ceph/bootstrap',
    command => '/usr/bin/pip install ceph-deploy',
  }

  file {'/etc/ceph/bootstrap':
    ensure => directory,
    owner  => 'root',
    mode   => '0755',
  }

  file { "ceph.conf":
    path    => '/etc/ceph/bootstrap',
    content => template('cephdeploy/ceph.conf.erb'),
    require => File['/etc/ceph/bootstrap'],
    unless  => '/usr/bin/test -e /etc/ceph/bootstrap/ceph.conf',
  }

  file { "ceph.mon.keyring":
    path    => '/etc/ceph/bootstrap',
    content => template('cephdeploy/ceph.mon.keyring.erb'),
    require => File['ceph.conf'],
    unless  => '/usr/bin/test -e /etc/ceph/bootstrap/ceph.mon.keyring',
  }

  exec { "install ceph":
    command => "/usr/local/bin/ceph-deploy install $::hostname",
    cwd     => '/etc/ceph/bootstrap',
    unless  => '/usr/bin/dpkg -l | grep ceph',
    require => [ Exec['get ceph-deploy'], File['ceph.mon.keyring'] ],
  }


}
