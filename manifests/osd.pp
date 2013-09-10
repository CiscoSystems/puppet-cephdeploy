class cephdeploy::osd(
  $disk,
){

  include cephdeploy

  exec { 'gatherkeys':
    cwd => '/etc/ceph/bootstrap',
    user => $::ceph_deploy_user,
    command => "/usr/local/bin/ceph-deploy gatherkeys -h $::mon_host"
    require => Exec['install ceph'],
  }

  exec { 'zap disk':
    cwd     => '/etc/ceph/bootstrap',
    command => "/usr/local/bin/ceph-deploy disk zap $::hostname:$disk",
    require => [ Exec['install ceph'], Exec['gatherkeys'] ],
  }

  exec { 'create osd':
    command => "/usr/local/bin/ceph-deploy osd create $::hostname:$disk",
    cwd     => '/etc/ceph',
    require => Exec['zap disk'],
  }


}
