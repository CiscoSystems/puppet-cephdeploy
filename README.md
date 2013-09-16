Automating ceph-deploy
================================

This puppet module allows you to fully automate the deployment of a ceph cluster. The need for this sort of functionality came about with the goal of full bottom-up automation of an OpenStack cloud that is ceph-backed. If you wish to try this automation, check out Cisco OpenStack Installer CiscoSystems/grizzly-manifests


Create/modify your site.pp, you will need to add the following information:

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


Add these class declarations to your puppet node definitions where the respective service(s) is desired.

This is the base class that installs ceph and configures the requirements on the system. This is the core class that mon, osd, and mds build on. If you are using this on a compute node, you must pass the has_compute arg.

class {'cephdeploy': }

eg on a compute node:

class {'cephdeploy': has_compute => true, }

Use this class where you want to deploy a mon service. There is no longer any need to pass a unique id number class

{'cephdeploy::mon': }

To create an OSD, just call this class and pass the disk name. Multiple disks call for multiple declaration, as in the example:

cephdeploy::osd { 'sdb': } cephdeploy::osd { 'sdc': }

When creating you first osd node, you will want to pass it the setup_pools arg, this will create the primary glance and cinder rbd pools eg

cephdeploy::osd { 'sdb': setup_pools => true, }

To create an mds node:

class {'cephdeploy::mds': }

There is also a basic class. The point of this class is to install ceph and it's keys. This class should only be called on a node that is not running, or going to ever run, any additional ceph services. For example, this is what you want to use on a controller that has no mon.

class {'cephdeploy::baseconfig': }

Donald Talton
Systems Development Unit
dotalton@cisco.com
