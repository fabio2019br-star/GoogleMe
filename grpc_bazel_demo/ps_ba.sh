for pid in $(pgrep -f 'bazel\('); do
  ws=$(tr '\0' ' ' < /proc/$pid/cmdline | grep -oP '(?<=--workspace_directory=)\S+')
  ib=$(tr '\0' ' ' < /proc/$pid/cmdline | grep -oP '(?<=--install_base=)\S+')
  ob=$(tr '\0' ' ' < /proc/$pid/cmdline | grep -oP '(?<=--output_base=)\S+')
  echo "PID=$pid"
  echo "  workspace:    $ws"
  echo "  install_base: $ib"
  echo "  output_base:  $ob"
  echo
done
