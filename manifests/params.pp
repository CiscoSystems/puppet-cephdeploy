class cephdeploy::params {

  # The variable prefix to be used for configuration settings:
  # * default '' to resemble previous behaviour
  if $configuration_variable_prefix {
    $variable_prefix = $configuration_variable_prefix
  } elsif hiera('cephdeloy::configuration_variable_prefix') {
    $variable_prefix = hiera('cephdeploy::configuration_variable_prefix')
  } else {
    $variable_prefix = ''
  }

  # Whether to automatically create the required pools for OpenStack
  $setup_pools = pick(hiera("cephdeploy::${variable_prefix}configuration_variable_prefix"),
                 getvar("::${variable_prefix}setup_pools"),
                 "true")

  # The initial monitoring servers
  $mon_initial_members = pick(hiera("cephdeploy::${variable_prefix}mon_initial_members"),
                         getvar("::${variable_prefix}mon_initial_members"))

  # The primary MON server
  $ceph_primary_mon = pick(hiera("cephdeploy::${variable_prefix}ceph_primary_mon"),
                      getvar("::${variable_prefix}ceph_primary_mon"))

  # The Ceph cluster public network
  $ceph_public_network = pick(hiera("cephdeploy::${variable_prefix}ceph_public_network"),
                         getvar("::${variable_prefix}ceph_public_network"))

  # The Ceph deploy user password
  $ceph_deploy_password = pick(hiera("cephdeploy::${variable_prefix}ceph_deploy_password"),
                          getvar("::${variable_prefix}ceph_deploy_password"))

  # The name of the Cinder RBD pool
  $cinder_rbd_pool = pick(hiera("cephdeploy::${variable_prefix}cinder_rbd_pool"),
                     getvar("::${variable_prefix}cinder_rbd_pool"),
                     "rbdcinder")

  # The name of the Cinder RBD CephX user
  $cinder_rbd_user = pick(hiera("cephdeploy::${variable_prefix}cinder_rbd_user"),
                     getvar("::${variable_prefix}cinder_rbd_user"),
                     "admin")

  # The name of the group the Cinder keyring file should belong to
  $cinder_system_group = pick(hiera("cephdeploy::${variable_prefix}cinder_system_group"),
                         getvar("::${variable_prefix}cinder_system_group"),
                         "cinder")

  # The disks to use in the osdwrapper class
  $disks = pick(hiera("cephdeploy::${variable_prefix}"),
           getvar("::${variable_prefix}disks"))

  # The interface for the Ceph public network
  $ceph_public_interface = pick(hiera("cephdeploy::${variable_prefix}ceph_public_interface"),
                           getvar("::${variable_prefix}ceph_public_interface"))

  # The interface for the Ceph cluster network
  $ceph_cluster_interface = pick(hiera("cephdeploy::${variable_prefix}ceph_cluster_interface"),
                            getvar("::${variable_prefix}ceph_cluster_interface"))

  # Whether to configure virsh or not
  $setup_virsh = pick(hiera("cephdeploy::${variable_prefix}setup_virsh"),
                 getvar("::${variable_prefix}setup_virsh"),
                 "true")

  # The primary MON server
  $primary_mon = pick(hiera("cephdeploy::${variable_prefix}primary_mon"),
                 getvar("::${variable_prefix}primary_mon"))

  # The name of the Glance RBD pool
  $glance_ceph_pool = pick(hiera("cephdeploy::${variable_prefix}glance_ceph_pool"),
                      getvar("::${variable_prefix}glance_ceph_pool"),
                      "rbdglance")

  # The name of the Glance RBD CephX user
  $glance_ceph_user = pick(hiera("cephdeploy::${variable_prefix}glance_ceph_user"),
                      getvar("::${variable_prefix}glance_ceph_user"),
                      "admin")

  # The name of the group the Glance keyring file should belong to
  $glance_system_group = pick(hiera("cephdeploy::${variable_prefix}glance_system_group"),
                         getvar("::${variable_prefix}glance_system_group"),
                         "glance")

  # Whether or not to enforce permissions on the CephX keys
  $cephx_keys_permission_enforce = pick(hiera("cephdeploy::${variable_prefix}cephx_keys_permission_enforce"),
                                   getvar("::${variable_prefix}cephx_keys_permission_enforce"),
                                   "false")

  # Whether a note is a compute node or not
  $has_compute = pick(hiera("cephdeploy::${variable_prefix}has_compute"),
                 getvar("::${variable_prefix}has_compute"),
                 "true")

  # The Ceph MON cluster fsid
  $ceph_monitor_fsid = pick(hiera("cephdeploy::${variable_prefix}ceph_monitor_fsid"),
                       getvar("::${variable_prefix}ceph_monitor_fsid"))

  # The Ceph cluster network address space
  $ceph_cluster_network = pick(hiera("cephdeploy::${variable_prefix}ceph_cluster_network"),
                          getvar("::${variable_prefix}ceph_cluster_network"))

  # The name of the Ceph deploy user
  $ceph_deploy_user = pick(hiera("cephdeploy::${variable_prefix}ceph_deploy_user"),
                      getvar("::${variable_prefix}ceph_deploy_user"))

  # The Ceph deploy user password
  $pass = pick(hiera("cephdeploy::${variable_prefix}pass"),
          getvar("::${variable_prefix}pass"))

  # The type of Ceph deploy account
  $ceph_deploy_system_user = pick(hiera("cephdeploy::${variable_prefix}ceph_deploy_system_user"),
                             getvar("::${variable_prefix}ceph_deploy_system_user"),
                             false)

  # The Ceph release to use
  $ceph_release = pick(hiera("cephdeploy::${variable_prefix}ceph_release"),
                  getvar("::${variable_prefix}ceph_release"),
                  "emperor")

  # The address of the primary Ceph MON server
  $ceph_monitor_address = pick(hiera("cephdeploy::${variable_prefix}ceph_monitor_address"),
                          getvar("::${variable_prefix}ceph_monitor_address"))

  # The name of the Ceph cluster
  $ceph_cluster_name = pick(hiera("cephdeploy::${variable_prefix}ceph_cluster_name"),
                       getvar("::${variable_prefix}ceph_cluster_name"),
                       "ceph")

  # Whether or not to install package repositories
  $ceph_install_repositories = pick(hiera("cephdeploy::${variable_prefix}ceph_install_repositories"),
                               getvar("::${variable_prefix}ceph_install_repositories"),
                               "true")
}
