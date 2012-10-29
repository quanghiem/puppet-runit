define runit::user {
  $user = $title
  file { "/etc/runit/${user}":
    ensure  => directory,
    mode    => '0755',
  }
  file { "/etc/runit/${user}/down":
    ensure  => absent,
  }
  file { "/etc/runit/${user}/run":
    ensure  => file,
    mode    => '0555',
    content => template('runit/user_run.erb'),
  }
  file { "/etc/runit/${user}/log":
    ensure  => directory,
    mode    => '0755',
    require => File["/etc/runit/${user}"],
  }
  file { "/etc/runit/${user}/log/down":
    ensure  => absent,
    require => File["/etc/runit/${user}/log"],
  }
  file { "/etc/runit/${user}/log/run":
    ensure  => file,
    mode    => '0555',
    content => template('runit/user_log_run.erb'),
    require => File[
      "/etc/runit/${user}/log",
      "/etc/runit/${user}/log/down",
      "/home/${user}/logs/runsvdir"
    ],
  }

  file { "/home/${user}/service":
    ensure  => directory,
    mode    => '0755',
    owner   => $user,
  }
  file { "/home/${user}/logs":
    ensure  => directory,
    mode    => '0755',
    owner   => $user,
  }
  file { "/home/${user}/logs/runsvdir":
    ensure  => directory,
    mode    => '0755',
    owner   => $user,
    require => File["/home/${user}/logs"],
  }

  service { "runit-${user}":
    ensure   => 'running',
    name     => $user,
    provider => 'runit',
    path     => '/etc/runit',
    require  => File["/etc/runit/${user}/run"],
  }
}
