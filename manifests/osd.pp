define cephdeploy::osd(
){

  include cephdeploy
  $user = $::ceph_deploy_user
  $disk = $name

  notice($disk)

  exec { "gatherkeys_$disk":
    cwd     => '/etc/ceph/bootstrap',
    user    => $user,
    command => "/bin/rm -f /etc/ceph/bootstrap/ceph.log && /usr/local/bin/ceph-deploy gatherkeys $::mon_initial_members",
    require => [ Exec['install ceph'], File["/etc/sudoers.d/$user"], File['/etc/ceph/bootstrap/ceph.log'] ],
    unless  => '/usr/bin/test -e /etc/ceph/bootstrap/ceph.bootstrap-osd.keyring',
  }

  exec { "zap $disk":
    cwd     => '/etc/ceph/bootstrap',
    command => "/usr/local/bin/ceph-deploy disk zap $::hostname:$disk",
    require => [ Exec['install ceph'], Exec["gatherkeys_$disk"] ],
    unless  => "/usr/bin/test -e /home/$user/zapped/$disk",
  }

  exec { "create osd $disk":
    cwd     => '/etc/ceph/bootstrap',
    command => "/usr/local/bin/ceph-deploy osd create $::hostname:$disk",
    require => Exec["zap $disk"],
    unless  => "/usr/bin/test -e /home/$user/zapped/$disk",
  }
  
  file { "/home/$user/zapped/$disk":
    ensure  => present,
    require => [ Exec["zap $disk"], Exec["create osd $disk"], File["/home/$user/zapped"] ],
  }



}
