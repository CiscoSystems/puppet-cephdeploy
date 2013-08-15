class cephdeploy::mon(
  $mon,
){

  # install pip
  package {'python-pip'}:
    ensure => present,
  }

  # get ceph-deploy
  exec {'get ceph-deploy':
    cwd     => '/var/tmp',
    command => '/usr/bin/pip install ceph-deploy',
    require => Package['python-pip'],
  }

  # create the config file and secret, probably want to skip this and use a
  # puppet template instead to ensure correct listening IP, fsid, etc.
  exec {'initialize cluster'}:
    cwd     => '/var/tmp',
    command => "/usr/local/bin/ceph-deploy new ${mon}",
    require => Exec['get ceph-deploy'],
  }

  # install the ceph packages, latest stable is always used. We can offer
  # an override to pass to the deploy CLI later
  exec {'install ceph'}:
    cwd     => '/var/tmp',
    command => "/usr/local/bin/ceph-deploy install ${mon}",
    require => Exec['initialize cluster'],
  }

  # this actually creates and starts the mon, we can specify these hosts
  # in the bootstrap ceph.conf
  exec {'execute mon'}:
    cwd     => '/var/tmp',
    command => "/usr/local/bin/ceph-deploy create ${mon}",
    require => Exec['install ceph'],
  }

  # gather the keys from the newly created mon to use in deploying OSDs
  # we need to only do this once.
  exec {'gather keys'}:
    cwd     => '/var/tmp',
    command => "/usr/local/bin/ceph-deploy gatherkeys ${mon}",
    require => Exec['execute mon'],
  }

}
