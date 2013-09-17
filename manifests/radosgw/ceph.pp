class cephdeploy::radosgw::ceph(
  $cluster,
  $cluster_id,
) {

  package {'ceph':
    ensure => present,
  }

  package {'radosgw':
    ensure  => present,
    require => Package['apache2'],
  }

  package {'radosgw-agent':
    ensure  => present,
    require => Package['apache2'],
  }

  file {'data dir':
    path => "/var/lib/ceph/radosgw/$cluster-$cluster_id",
    ensure => directory,
  }

  service {'ceph':
    ensure  => running,
    require => [ Package['radosgw'], Package['ceph'] ],
  }

}
