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

  exec {'iptables mon':
    command => "/sbin/iptables -A INPUT -i $::ceph_public_interface -p tcp -s $::ceph_public_network --dport 6789 -j ACCEPT",
    unless  => '/sbin/iptables -L | grep "tcp dpt:6789"',
  }


}
