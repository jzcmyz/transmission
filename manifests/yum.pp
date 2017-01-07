class transmission::yum {
  yumrepo { 'geekery':
    baseurl  => "http://geekery.altervista.org/geekery/el${::operatingsystemmajrelease}/${::architecture}",
    descr    => 'Transmission BitTorrent Repo',
    enabled  => '1',
    gpgcheck => '1',
    gpgkey   => 'http://geekery.altervista.org/download.php?filename=GEEKERY-GPG-KEY',
    protect  => '1',
  }
  staging::file { "rpmforge":
    source => "http://packages.sw.be/rpmforge-release/rpmforge-release-0.5.2-2.el${::operatingsystemmajrelease}.rf.${::architecture}.rpm",
    target => "/tmp/rpmforge-release-0.5.2-2.el${::operatingsystemmajrelease}.rf.${::architecture}.rpm",
    before => Package['rpmforge-release'],
  }
  package { 'rpmforge-release':
    ensure   => installed,
    provider => 'rpm',
    source   => "/tmp/rpmforge-release-0.5.2-2.el${::operatingsystemmajrelease}.rf.${::architecture}.rpm",
  }
}
