class cephdeploy::osdwrapper(
  $disks,
){

  cephdeploy::osd { $disks: }

}
