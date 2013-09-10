class cephdeploy::osd(
  $disk,
){

  include cephdeploy

  exec { 'zap disk':
    command => "/usr/local/bin/ceph-deploy disk zap $::hostname:$disk",
    require => Exec['install ceph'],
  }

  exec { 'create osd':
    command => "/usr/local/bin/ceph-deploy create osd $::hostname:$disk",
    cwd     => '/etc/ceph/bootstrap',
    unless  => '/bin/ps -ef | /bin/grep -v grep | /bin/grep ceph-mon',
    require => Exec['zap disk'],
  }


}
