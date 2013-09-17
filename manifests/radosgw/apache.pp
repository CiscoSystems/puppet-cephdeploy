class og::apache() {

  package {'apache2':
    ensure  => present,
    require => Apt::Source['apache2'],
  }

  package {'libapache2-mod-fastcgi':
    ensure  => present,
    require => Apt::Source['fastcgi'],
  }

  exec {'rewrite':
    command => '/usr/sbin/a2enmod rewrite',
    require => Package['apache2'],
  }

  exec {'fastcgi':
    command => '/usr/sbin/a2enmod fastcgi',
    require => Package['apache2'],
  }

  exec {'ssl':
    command => '/usr/sbin/a2enmod ssl',
    require => Package['apache2'],
  }

  exec {'ssl cert':
    command => 'openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout 
                /etc/apache2/ssl/apache.key -out /etc/apache2/ssl/apache.crt',
    unless  => '/usr/bin/test -e /etc/apache2/ssl/apache.crt',
  }

  file {'hostname.httpd.conf':
    path    => '/etc/apache2/httpd.conf',
    content => template('og/hostname.http.conf'),
    require => Package['apache2'],
  }

  file {'rgw':
    path    => '/etc/apache2/sites-available/rgw',
    unless  => '/usr/bin/test -e /etc/apache2/sites-available/rgw',
    content => template('cephdeploy/radosgw/rgw.conf.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => 0644,
    require => Package['apache2'],
  }

  exec {'activate rgw':
    command => 'a2ensite /etc/apache2/sites-available/rgw.conf',
    require => File['rgw'],
    unless  => '/usr/bin/test -e /etc/apache2/sites-enabled/rgw',
  }
  
  exec {'deactivate default':
    command => 'a2dissite default',
    require => Package['apache2'],
  }

  file {'gateway script':
    path    => '/var/www/s3gw.fcgi',
    content => 'puppet:///modules/cephdeploy/s3gw.fcgi',
    unless  => '/usr/bin/test -e /var/www/s3gw.fcgi',
    mode    => 0755,
    owner   => 'root',
    group   => 'root',
    require => Package['apache2'],
  }
  

  service {'apache2':
    ensure  => running,
    require => [ Package['apache2'], File['hostname.httpd.conf'], Exec['ssl cert] ],
  }

  


}
