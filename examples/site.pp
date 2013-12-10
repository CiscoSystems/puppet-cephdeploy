class { 'cephdeploy::baseconfig': }
class { 'cephdeploy::radosgw::apache': }
class { 'cephdeploy::radosgw::ceph': }

needs keystone endpoint created

keystone service-create --name swift --type-object store
keystone endpoint-create --service-id <id> --publicurl http://radosgw.example.com/swift/v1 \
        --internalurl http://radosgw.example.com/swift/v1 --adminurl http://radosgw.example.com/swift/v1


#variables

$cluster_name = 'ceph'
$daemon_id = 'radosgw.gateway  #i think this needs to change...hostname? fqdn?

$gateway_user = 'dtalton'
$gateway_user_display_name = 'Don Talton'

$verbose_ops_logging = 'false'

$swift_user = 'dtalton'

$keystone_admin_url = 'some url'
$keystone_admin_token = ''
$keystone_accepted_roles = ''
$keystone_token_cache_size = ''
$keystone_revocation_interval = ''
