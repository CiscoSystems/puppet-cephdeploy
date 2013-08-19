class cephdeploy::mon(
  $mon,
){

  # install pip
  package {'python-pip':
    ensure => present,
  }

  # get ceph-deploy
  exec {'get ceph-deploy':
    cwd     => '/etc/ceph/bootstrap',
    command => '/usr/bin/pip install ceph-deploy',
    require => [ Package['python-pip'], File['/etc/ceph/bootstrap'] ],
  }

  # create the config file and secret, probably want to skip this and use a
  # puppet template instead to ensure correct listening IP, fsid, etc.
  exec {'initialize cluster':
    cwd     => '/etc/ceph/bootstrap',
    command => "/usr/local/bin/ceph-deploy new ${mon}",
    require => [ Exec['get ceph-deploy'], File['/etc/ceph/bootstrap'] ]
  }

  file {'/etc/ceph/bootstrap':
    ensure => directory,
    owner  => 'root',
    mode   => '0755',
  }

  # install the ceph packages, latest stable is always used. We can offer
  # an override to pass to the deploy CLI later
  exec {'install ceph':
    cwd     => '/etc/ceph/bootstrap',
    command => "/usr/local/bin/ceph-deploy install ${mon}",
    require => [ Exec['initialize cluster'], File['/etc/ceph'] ],
  }

  # this actually creates and starts the mon, we can specify these hosts
  # in the bootstrap ceph.conf
  exec {'execute mon':
    cwd     => '/etc/ceph/bootstrap',
    command => "/usr/local/bin/ceph-deploy create ${mon}",
    require => [ Exec['install ceph'], File['/etc/ceph'] ],
  }

  # gather the keys from the newly created mon to use in deploying OSDs
  # we need to only do this once.
  exec {'gather keys':
    cwd     => '/etc/puppet/bootstrap',
    command => "/usr/local/bin/ceph-deploy gatherkeys ${mon}",
    require => [ Exec['execute mon'], File['/etc/ceph'] ],
  }

}
