Automating ceph-deploy
======================

This puppet module allows you to fully automate the deployment of a ceph cluster. The need for this sort of functionality came about with the goal of full bottom-up automation of an OpenStack cloud that is ceph-backed.

This module will also configure OpenStack cinder and nova-compute nodes to use the ceph cluster.

*This automation will be implemented in the Havana release of [Cisco OpenStack Installer](http://docwiki.cisco.com/wiki/OpenStack:Grizzly-Multinode)*

Questions? Comments?  
Donald Talton  
dotalton@cisco.com


site.pp variables
-----------------

    $ceph_monitor_fsid = 'e80afa94-a64c-486c-9e34-d55e85f26406'
    $ceph_monitor_secret = 'AQAJzNxR+PNRIRAA7yUp9hJJdWZ3PVz242Xjiw=='
    $cinder_rbd_user = 'admin'
    $cinder_rbd_pool = 'volumes'
    $cinder_rbd_secret_uuid = 'e80afa94-a64c-486c-9e34-d55e85f26406'
    $mon_initial_members = 'control-server'
    $ceph_primary_mon = 'control-server'
    $ceph_monitor_address = '10.0.0.1,' yes leave the trailing comma intact for now
    $ceph_deploy_user = 'k9de9kdkasdok'
    $ceph_deploy_password = 'dsaadsadasdk09as09kdsad'
    $ceph_cluster_interface = 'eth1'
    $ceph_public_interface = 'eth1'
    $ceph_public_network = '10.0.0.0/24'
    $ceph_cluster_network = '10.0.0.0/24'


Installation on your nodes
--------------------------

This is the base class that installs ceph and configures the requirements on the system. If you are using this on a nova-compute node, you must pass "has_compute".


Install
-------
    class {'cephdeploy': }

    #on a compute node
    class {'cephdeploy': has_compute => true, }


Create a MON
------------

    {'cephdeploy::mon': }


Create an OSD 
-------------
Multiple disks call for multiple declaration.

    cephdeploy::osd { 'sdb': }
    cephdeploy::osd { 'sdc': }

When creating you first osd node, you will want to pass "setup_pools", this will create the glance and cinder rbd pools.

    cephdeploy::osd { 'sdb': setup_pools => true, }


Create an MDS
-------------
    class {'cephdeploy::mds': }


Create a client-only node
-------------------------

The point of this class is to install ceph and its keys. This class should only be called on a node that is not running, or going to ever run, any additional ceph services. For example, this is what you want to use on a controller that has no mon.

    class {'cephdeploy::baseconfig': }
