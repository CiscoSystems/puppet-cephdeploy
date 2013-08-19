class cephdeploy::osd(
  $host,
  $server_disks = $::server_disks,
) {

  exec {'prepare OSD disks and activate OSD node':
    cws     => '/etc/ceph',
    command => "/usr/bin/ceph-deploy osd create ${server_disks}",
    unless  => "ceph-deploy disk list ${host} | grep active",
  }
}
