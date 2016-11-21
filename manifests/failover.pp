define dhcp::failover(
  $peer_address,
  $ensure    = present,
  $address   = $::ipaddress,
  $peer_port = 647,
  $port      = 647,
  $options   = {},
  $role      = 'primary',
) {

  validate_re($ensure, ['present', 'absent'])
  validate_ipv4_address($address)
  validate_ipv4_address($peer_address)
  validate_integer($port)
  validate_integer($peer_port)
  validate_hash($options)
  validate_re($role, ['primary', 'secondary'])

  include ::dhcp::params

  $my_ensure = $ensure? {
    'present' => 'file',
    default   => $ensure,
  }

  file {"${dhcp::params::config_dir}/failover.d/${name}.conf":
    ensure  => $my_ensure,
    content => template("${module_name}/failover.conf.erb"),
    group   => 'root',
    mode    => '0644',
    notify  => Service['dhcpd'],
    owner   => 'root',
  }

  $mycontent = $ensure ? {
      'present' => "include \"${dhcp::params::config_dir}/failover.d/${name}.conf\";\n",
      default   => ''
  }
  concat::fragment {"dhcp.failover.${name}":
    content => $mycontent,
    target  => "${dhcp::params::config_dir}/dhcpd.conf",
  }

}
