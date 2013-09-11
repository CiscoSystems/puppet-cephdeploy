define cephdeploy::osd(
  $setup_pools = false,
){

  include cephdeploy
  $user = $::ceph_deploy_user
  $disk = $name

#  file {'service perms':
#    mode => 0644,
#    path => '/etc/ceph/ceph.client.admin.keyring',
#    require => exec['copy key'],
#  }

  package { 'sysfsutils':
    ensure => present,
  }

  file {"log $disk":
    owner => $user,
    group => $user,
    mode  => 0777,
    path  => "/home/$user/bootstrap/ceph.log",
    require => Exec["install ceph"],
  }

  exec { "get config $disk":
    cwd     => "/home/$user/bootstrap",
    user    => $user,
    command => "/usr/local/bin/ceph-deploy config push $::hostname",
    require => [ Exec['install ceph'], File["/etc/sudoers.d/$user"], File["log $disk"] ],
    unless  => "/usr/bin/test -e /etc/ceph/ceph.conf",
  }
    
  exec { "gatherkeys_$disk":
    cwd     => "/home/$user/bootstrap",
    user    => $user,
    command => "/usr/local/bin/ceph-deploy gatherkeys $::ceph_primary_mon",
    require => [ Exec['install ceph'], File["/etc/sudoers.d/$user"], Exec["get config $disk"] ],
    unless  => "/usr/bin/test -e /home/$user/bootstrap/ceph.bootstrap-osd.keyring",
  }

  exec {"copy admin key $disk":
    command => "/bin/cp /home/$user/bootstrap/ceph.client.admin.keyring /etc/ceph",
    unless  => '/usr/bin/test -e /etc/ceph/ceph.client.admin.keyring',
    require => Exec["gatherkeys_$disk"],
  }

  exec { "zap $disk":
    cwd     => "/home/$user/bootstrap",
    command => "/usr/local/bin/ceph-deploy disk zap $::hostname:$disk",
    require => [ Exec['install ceph'], Exec["gatherkeys_$disk"] ],
    unless  => "/usr/bin/test -e /home/$user/zapped/$disk",
  }

  exec { "create osd $disk":
    cwd     => "/home/$user/bootstrap",
    command => "/usr/local/bin/ceph-deploy --overwrite-conf osd create $::hostname:$disk",
    require => Exec["zap $disk"],
    unless  => "/usr/bin/test -e /home/$user/zapped/$disk",
  }
  
  file { "/home/$user/zapped/$disk":
    ensure  => present,
    require => [ Exec["zap $disk"], Exec["create osd $disk"], File["/home/$user/zapped"] ],
  }

  exec {'iptables osd':
    command => "/sbin/iptables -A INPUT -i $::ceph_cluster_interface  -m multiport -p tcp -s $::ceph_cluster_network --dports 6800:6810 -j ACCEPT",
    unless  => '/sbin/iptables -L | grep "multiport dports 6800:6810"',
  }

  if $setup_pools {

    exec { "create glance images pool $disk":
      command => "/usr/bin/ceph osd pool create ${::glance_ceph_pool} 128",
      unless => "/usr/bin/rados lspools | grep -sq $::glance_ceph_pool",
      require => Exec["create osd $disk"],
    }

    exec { "create cinder volumes pool $disk":
      command => "/usr/bin/ceph osd pool create $::cinder_rbd_pool 128",
      unless => "/usr/bin/rados lspools | grep -sq $::cinder_rbd_pool",
      require => Exec["create osd $disk"],
      notify => [ Service['cinder-volume'], Service['nova-compute'] ],
    }

  }




}
