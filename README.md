puppet-cephdeploy
=================

automating ceph-deploy

This is a completely new module and has no relation to puppet-ceph.
There are a lot of changes between this module and puppet-ceph, the primary being the use of ceph-deploy rather than utilizing the manual ceph installation process.
To use the module, there are now only a few class calls that have to be made. Store configs is no longer needed.
Only one pass is needed on each respective node for the cluster to completely come up and be online. This includes osd nodes with multiple disks. This results in a great increase in deployment speed.
All services can now co-habitate without issue (osd+mon+mds, or any combination thereof).



BEGIN HOWTO

Under this new model, you can add services as needed and just run the puppet agent for configuration. 
To add a new service, just use the respective class call(s) which are listed below.
You cannot remove services in this fashion. Mons can be removed with ceph-deploy, but as of this email osds cannot. It's a feature in the works. 

To take it for a test drive, on your build server:

git clone https://github.com/dontalton/puppet-cephdeploy /usr/share/puppet/modules/cephdeploy

Modify your site.pp, leaving all the old ceph configuration options commented out.
Add the following ceph configuration options, modifying to fit your environment:

$ceph_monitor_fsid      = 'e80afa94-a64c-486c-9e34-d55e85f26406'
$ceph_monitor_secret    = 'AQAJzNxR+PNRIRAA7yUp9hJJdWZ3PVz242Xjiw=='
$cinder_rbd_user        = 'admin'
$cinder_rbd_pool        = 'volumes'
$cinder_rbd_secret_uuid = 'e80afa94-a64c-486c-9e34-d55e85f26406'
$mon_initial_members    = 'control-server'
$ceph_primary_mon       = 'control-server'
# yes leave the trailing comma intact for now
$ceph_monitor_address   = '10.0.0.1,'
$ceph_deploy_user       = 'k9de9kdkasdok'
$ceph_deploy_password   = 'dsaadsadasdk09as09kdsad'
$ceph_cluster_interface = 'eth1'
$ceph_public_interface  = 'eth1'
$ceph_public_network    = '10.0.0.0/24'
$ceph_cluster_network   = '10.0.0.0/24'


The module calls. Add these to your puppet node definitions where the respective service(s) is desired.

This is the base class that installs ceph and configures the requirements on the system. This is the core class that mon, osd, and mds build on. If you are using this on a compute node, you must pass the has_compute arg.

class {'cephdeploy': }

eg on a compute node: 

  class {'cephdeploy':
    has_compute => true,
  }

Use this class where you want to deploy a mon service. There is no longer any need to pass a unique id number class 

{'cephdeploy::mon': }


To create an OSD, just call this class and pass the disk name. Multiple disks call for multiple declaration, as in the example:

cephdeploy::osd { 'sdb': }
cephdeploy::osd { 'sdc': }

When creating you first osd node, you will want to pass it the setup_pools arg, this will create the primary glance and cinder rbd pools eg 

  cephdeploy::osd { 'sdb':
    setup_pools => true,
  }

To create an mds node:

class {'cephdeploy::mds': }

There is also a basic class. The point of this class is to install ceph and it's keys. This class should only be called on a node that is not running, or going to ever run, any additional ceph services.
For example, this is what you want to use on a controller that has no mon.

class {'cephdeploy::baseconfig': }


Donald Talton
Systems Development Unit
dotalton@cisco.com


