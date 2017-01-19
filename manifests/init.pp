class transmission (

  String $transd,
  String $transd_config,
  String $transuser,
  String $transgroup,
  Integer $alt_speed_down,
  String $alt_speed_enabled,
  Integer $alt_speed_time_begin,
  Integer $alt_speed_time_day,
  String $alt_speed_time_enabled,
  Integer $alt_speed_time_end,
  Integer $alt_speed_up,
  String $bind_address_ipv4,
  String $bind_address_ipv6,
  String $blocklist_enabled,
  String $blocklist_url,
  Integer $cache_size_mb,
  String $dht_enabled,
  String $download_dir,
  String $download_queue_enabled,
  Integer $download_queue_size,
  Integer $encryption,
  Integer $idle_seeding_limit,
  String $idle_seeding_limit_enabled,
  String $incomplete_dir,
  String $incomplete_dir_enabled,
  String $lpd_enabled,
  Integer $message_level,
  String $peer_congestion_algorithm,
  Integer $peer_id_ttl_hours,
  Integer $peer_limit_global,
  Integer $peer_limit_per_torrent,
  Integer $peer_port,
  Integer $peer_port_random_high,
  Integer $peer_port_random_low,
  String $peer_port_random_on_start,
  String $peer_socket_tos,
  String $pex_enabled,
  String $port_forwarding_enabled,
  Integer $preallocation,
  Integer $prefetch_enabled,
  String $queue_stalled_enabled,
  Integer $queue_stalled_minutes,
  Integer $ratio_limit,
  String $ratio_limit_enabled,
  String $rename_partial_files,
  String $rpc_authentication_required,
  String $rpc_bind_address,
  String $rpc_enabled,
  String $rpc_password,
  Integer $rpc_port,
  String $rpc_url,
  String $rpc_username,
  String $rpc_whitelist,
  String $rpc_whitelist_enabled,
  String $scrape_paused_torrents_enabled,
  String $script_torrent_done_enabled,
  Optional[String] $script_torrent_done_filename,
  String $seed_queue_enabled,
  Integer $seed_queue_size,
  Integer $speed_limit_down,
  String $speed_limit_down_enabled,
  Integer $speed_limit_up,
  String $speed_limit_up_enabled,
  String $start_added_torrents,
  String $trash_original_torrent_files,
  Integer $umask,
  Integer $upload_slots_per_torrent,
  String $utp_enabled,

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
