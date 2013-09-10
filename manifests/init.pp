class cephdeploy(
  $user = $::ceph_deploy_user,
  $pass = $::ceph_deploy_pass,
){
  
  package {'python-pip':
    ensure => present,
  }

  package {'ceph-deploy':
    ensure   => present,
    provider => pip,
  }
  
  $cephdirs = ['/etc/ceph', '/etc/ceph/bootstrap']
  file {$cephdirs:
    ensure => directory,
    owner  => 'root',
    mode   => '0755',
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
