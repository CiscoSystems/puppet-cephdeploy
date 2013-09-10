class cephdeploy::osd(
  $disk,
){

  include cephdeploy

  exec { 'create osd':
    command => "/usr/local/bin/ceph-deploy create osd $::hostname:$disk",
    cwd     => '/etc/ceph/bootstrap',
    unless  => '/bin/ps -ef | /bin/grep -v grep | /bin/grep ceph-mon',
    require => [ Exec['get ceph-deploy'], File['ceph.mon.keyring'] ],
  }


}
