define cephdeploy::osd(
  $setup_pools            = true,
  $user                   = hiera('ceph_deploy_user'),
  $ceph_primary_mon       = hiera('ceph_primary_mon'),
  $ceph_cluster_interface = hiera('ceph_cluster_interface'),
  $ceph_cluster_network   = hiera('ceph_cluster_network'),
  $glance_ceph_pool       = hiera('glance_ceph_pool'),
  $cinder_rbd_pool        = hiera('cinder_rbd_pool'),
){

  include cephdeploy

  $disk_hash = $name
  $disk_array = split($disk_hash, ':')
  $disk = $disk_array[0]
  $disk_journal = $disk_array[1]
  if $disk_journal {
    $disk_journal_real = $disk_journal
  } else {
    $disk_journal_real = $disk
  }

  exec { "create osd $disk":
     cwd     => "/home/$user/bootstrap",
     command => "/usr/bin/ceph-deploy --overwrite-conf osd create $::hostname:$disk:$disk_journal_real",
     require => Exec["zap $disk"],
     unless  => "/usr/bin/test -e /home/$user/zapped/$disk",
  }

  exec { "get config $disk":
    cwd     => "/home/$user/bootstrap",
    user    => $user,
    command => "/usr/bin/sudo /usr/bin/ceph-deploy config push $::hostname",
    require => [ Exec['install ceph'], File['/etc/ceph/ceph.conf'] ],
    unless  => "/usr/bin/test -e /etc/ceph/ceph.conf",
  }

  exec { "gatherkeys_$disk":
    command => "/usr/bin/scp $user@$ceph_primary_mon:bootstrap/*.key* .",
    user    => $user,
    cwd     => "/home/$user/bootstrap",
    require => [ Exec['install ceph'], File["/etc/sudoers.d/$user"], Exec["get config $disk"] ],
    unless  => '/usr/bin/test -e /home/$user/bootstrap/$cluster.bootstrap-osd.keyring',
  }

  exec {"copy admin key $disk":
    command => "/bin/cp /home/$user/bootstrap/ceph.client.admin.keyring /etc/ceph",
    unless  => '/usr/bin/test -e /etc/ceph/ceph.client.admin.keyring',
    require => Exec["gatherkeys_$disk"],
  }

  exec { "zap $disk":
    cwd     => "/home/$user/bootstrap",
    command => "/usr/bin/ceph-deploy disk zap $::hostname:$disk",
    require => [ Exec['install ceph'], Exec["gatherkeys_$disk"] ],
    unless  => "/usr/bin/test -e /home/$user/zapped/$disk",
  }

  file { "/home/$user/zapped/$disk":
    ensure  => present,
    require => [ Exec["zap $disk"], Exec["create osd $disk"], File["/home/$user/zapped"] ],
  }

  exec {"iptables osd $disk":
    command => "/sbin/iptables -A INPUT -i $ceph_cluster_interface  -m multiport -p tcp -s $ceph_cluster_network --dports 6800:6810 -j ACCEPT",
    unless  => '/sbin/iptables -L | grep "multiport dports 6800:6810"',
  }

  if $setup_pools {

    exec { "create glance images pool $disk":
      command => "/usr/bin/ceph osd pool create $glance_ceph_pool 128",
      unless  => "/usr/bin/rados lspools | grep -sq $glance_ceph_pool",
      require => Exec["create osd $disk"],
    }

    exec { "create cinder volumes pool $disk":
      command => "/usr/bin/ceph osd pool create $cinder_rbd_pool 128",
      unless  => "/usr/bin/rados lspools | grep -sq $cinder_rbd_pool",
      require => Exec["create osd $disk"],
      notify  => [ Service['cinder-volume'], Service['nova-compute'] ],
    }

  }


}

