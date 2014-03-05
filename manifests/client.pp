class cephdeploy::client(
  $ceph_deploy_user = hiera('ceph_deploy_user'),
  $primary_mon      = hiera('ceph_primary_mon'),
  $pass             = hiera('ceph_deploy_password'),
  $setup_virsh      = true,
){

## User setup

  user {$ceph_deploy_user:
    ensure   => present,
    password => $pass,
    home     => "/home/${user}",
    shell    => '/bin/bash',
  }

  file {"/home/${user}":
    ensure  => directory,
    owner   => $ceph_deploy_user,
    group   => $ceph_deploy_user,
    mode    => '0755',
    require => User[$ceph_deploy_user],
  }

  file {"/home/${user}/.ssh":
    ensure  => directory,
    owner   => $ceph_deploy_user,
    group   => $ceph_deploy_user,
    mode    => '0700',
    require => File["/home/${user}"],
  }

  file {"/home/${user}/.ssh/id_rsa":
    content => template('cephdeploy/id_rsa.erb'),
    owner   => $ceph_deploy_user,
    group   => $ceph_deploy_user,
    mode    => '0600',
    require => File["/home/${user}/.ssh"],
  }

  file {"/home/${user}/.ssh/id_rsa.pub":
    content => template('cephdeploy/id_rsa.pub.erb'),
    owner   => $ceph_deploy_user,
    group   => $ceph_deploy_user,
    mode    => '0644',
    require => File["/home/${user}/.ssh"],
  }

  file {"/home/${user}/.ssh/authorized_keys":
    content => template('cephdeploy/id_rsa.pub.erb'),
    owner   => $ceph_deploy_user,
    group   => $ceph_deploy_user,
    mode    => '0600',
    require => File["/home/${user}/.ssh"],
  }

  file {"/home/${user}/.ssh/config":
    content => template('cephdeploy/config.erb'),
    owner   => $ceph_deploy_user,
    group   => $ceph_deploy_user,
    mode    => '0600',
    require => File["/home/${user}/.ssh"],
  }

  exec {'passwordless sudo for ceph deploy user':
    command => "/bin/echo \"${user} ALL = (root) NOPASSWD:ALL\"\
                 | sudo tee /etc/sudoers.d/${user}",
    unless  => "/usr/bin/test -e /etc/sudoers.d/${user}",
  }

  file {"/etc/sudoers.d/${user}":
    mode    => '0440',
    require => Exec['passwordless sudo for ceph deploy user'],
  }

  file {"/home/${user}/bootstrap":
    ensure  => directory,
    owner   => $ceph_deploy_user,
    group   => $ceph_deploy_user,
    require => File["/home/${user}"],
  }

  # install ceph client packages

  package {'ceph-common':
    ensure  => present,
    require => File["/home/${user}/bootstrap"],
  }

  package {'python-ceph':
    ensure  => present,
    require => File["/home/${user}/bootstrap"],
  }

  file { '/etc/ceph':
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    require => Package['ceph-common'],
  }

  # get and install config and keys

  exec { 'get keys':
    command => "/usr/bin/scp ${user}@${primary_mon}:bootstrap/{*.key*,ceph.conf} .",
    user    => $ceph_deploy_user,
    cwd     => "/home/${user}/bootstrap",
    require => [ File["/home/${user}/bootstrap"], File["/home/${user}/.ssh/config"] ],
    unless  => "/usr/bin/test -e /home/${user}/bootstrap/ceph.conf",
  }

  exec { 'place keys':
    command => "/bin/cp /home/${user}/bootstrap/* /etc/ceph/",
    cwd     => "/home/${user}/bootstrap",
    require => [ Exec['get keys'], File['/etc/ceph'] ],
    unless  => '/usr/bin/test -e /etc/ceph/ceph.conf',
  }


  if $setup_virsh {

    if !defined(Package['libvirt-bin']) {
      package {'libvirt-bin':
        ensure => installed,
      }
    }

    file { '/etc/ceph/secret.xml':
      content => template('cephdeploy/secret.xml-compute.erb'),
      require => Package['ceph-common'],
    }

    exec { 'get-or-set virsh secret':
      command => '/usr/bin/virsh secret-define --file /etc/ceph/secret.xml | /usr/bin/awk \'{print $2}\' | sed \'/^$/d\' > /etc/ceph/virsh.secret',
      creates => "/etc/ceph/virsh.secret",
      require => [ Package['libvirt-bin'], File['/etc/ceph/secret.xml'] ],
    }

    exec { 'set-secret-value virsh':
      command => "/usr/bin/virsh secret-set-value --secret $(cat /etc/ceph/virsh.secret) --base64 $(ceph auth get-key client.admin)",
      require => Exec['get-or-set virsh secret'],
    }

  }




}
