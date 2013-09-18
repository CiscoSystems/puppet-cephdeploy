class cephdeploy::radosgw::ceph(
  $cluster,
  $cluster_id,
) {

#  package {'ceph':
#    ensure => present,
#  }

  package {'radosgw':
    ensure  => present,
    require => Package['apache2'],
  }

  package {'radosgw-agent':
    ensure  => present,
    require => Package['apache2'],
  }

  file {'data dir':
    path   => "/var/lib/ceph/radosgw/$cluster-$cluster_id",
    ensure => directory,
  }

  service {'ceph':
    ensure  => running,
#    require => [ Package['radosgw'], Package['ceph'] ],
    require => Package['radosgw'],
  }

  concat::fragment {'ceph.conf.radosgw':
    target  => 'ceph.conf',
    order   => '02',
    content => template('cephdeploy/radosgw/ceph.conf.radosgw.erb'),
    require => Concat['ceph.conf'],
  }
  
  exec {'create gw user':
    command => "radosgw-admin user create --uid=$username --display-name=\"$display_name\"",
#    unless => 'something to check for this user's existence',
  }
  
  exec {'create swift user':
    command => "radosgw-admin subuser create --uid=$swiftuser --subuser=$swiftuser:swift --access=full",
#    unless => 'something to check for this user's existence',
  } 

  exec {'create swift user key':
    command => "radosgw-admin key create --subuser=$swiftuser:swift --key-type=swift",
#    unless => 'something to check for this user's key existence',
  }



}
