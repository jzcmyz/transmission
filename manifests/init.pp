class transmission (
 # $utp_enabled                    = $transmission::params::utp_enabled,
) {
  File {
    ensure => directory,
    owner  => $transuser,
    group  => $transgroup,
    mode   => '0644',
  }
  user { $transuser:
    ensure  => present,
    home    => $transd,
    comment => 'Transmission BitTorrent',
    gid     => $transgroup,
    shell   => '/sbin/nologin',
  }
  group { $transgroup:
    ensure => present,
  }

  package { [ 'transmission','transmission-cli','transmission-common','transmission-daemon','transmission-gtk' ]:
    ensure  => installed,
    before  => File['settings.json'],
  }

  file { 'settings.json':
    ensure  => present,
    path    => "${transd_config}/settings.json",
    mode    => '0600',
    content => template("${module_name}/settings.json.erb"),
  }~>
    service { 'transmission-daemon reload':
      restart     => '/usr/bin/pkill -HUP transmission-da',
    }

  service { 'transmission-daemon':
    ensure    => running,
    enable    => true,
  }

  if $download_dir == $incomplete_dir {
    $dirs = $download_dir
  } else {
    $dirs = [ $download_dir, $incomplete_dir ]
  }

  file { $dirs:
    require => Package['transmission-daemon'],
  }
}
