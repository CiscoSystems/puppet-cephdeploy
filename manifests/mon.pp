class cephdeploy::mon(
  $user = $::ceph_deploy_user,
){

  include cephdeploy

  exec { 'create mon':
    cwd     => "/home/$user/bootstrap",
    command => "/usr/local/bin/ceph-deploy mon create $::hostname",
    unless  => '/bin/ps -ef | /bin/grep -v grep | /bin/grep ceph-mon',
    require => Exec['install ceph'],
    provider => shell,
  }


}
