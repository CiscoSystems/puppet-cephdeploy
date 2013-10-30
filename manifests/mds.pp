class cephdeploy::mds(
  $user = $::ceph_deploy_user,
){

  include cephdeploy

  exec { 'create mds':
    cwd     => "/home/$user/bootstrap",
    command => "/usr/local/bin/ceph-deploy mds create $::hostname",
    unless  => '/bin/ps -ef | /bin/grep -v grep | /bin/grep ceph-mds',
    require => Exec['install ceph'],
    provider => shell,
  }

  exec {'iptables mds':
    command => "/sbin/iptables -A INPUT -i $::ceph_public_interface -m multiport tcp -s $::ceph_public_network --dport 6800:6810 -j ACCEPT",
    unless  => '/sbin/iptables -L | grep "multiport dports 6800:6810"',
  }


}
