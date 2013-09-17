class og::ceph() {

  package {'radosgw':
    ensure  => present,
    require => Package['apache2'],
  }

  package {'radosgw-agent':
    ensure  => present,
    require => Package['apache2'],
  }

}
