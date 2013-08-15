class cephdeploy::osd(
  $host,
  $disk = [],
)},

  # create and run the OSD, why doesn't puppet have iterators?
  define disks {
    exec {"${title}":
      cwd => '/var/tmp',
      command => 
