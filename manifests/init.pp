class cephdeploy(){

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
    require => File['/etc/ceph/bootstrap'],
    unless  => '/usr/bin/test -e /etc/ceph/bootstrap/ceph.mon.keyring',
  }



}
