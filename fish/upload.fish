function __upload_print_help
  printf 'Usage: upload [OPTIONS] <source_file>... <dest_host>\n\n'
  printf 'Options:\n'
  printf '  -h/--help        Show this message and exit.\n'
  printf '  -u/--user        Username to login.\n'
  printf '  -p/--port        Specifies the port to connect to on the remote host.\n'
  printf '  -d/--direct      Use direct mode.\n'
  printf '  -f/--folder      Upload folder. Default is /tmp.'
  printf '  -i/--identity    Select this file from which the identity (private key)\n'
  printf '                   for public key authentication is read. This options is\n'
  printf '                   directly passed to ssh(1)\n'
  printf '  -v/--verbose     Verbose mode. Causes scp and ssh(1) to print debug messages\n'
  printf '                   about their progress.\n'
  printf '  -c/--coco        Use sftp to copy file via jumpserver. If this option is set,\n'
  printf "                   options 'user', 'port', 'direct', 'folder' will be ignored.\n"
end

function upload --description 'upload file to remote server via proxy'
  set -l options 'h/help' 'u/user=?' 'p/port=?' 'd/direct' 'i/identity=?' 'v/verbose' 'c/coco' 'f/folder'
  argparse --name=upload $options -- $argv
  if test $status -ne 0
    __upload_print_help
    return 1
  end

  if set --query _flag_help
    __upload_print_help
    return 0
  end

  if test (count $argv) -lt 2
    echo (set_color red)"expect 2 parameters as <source> and <dest>"(set_color normal)
    return 1
  end

  set -l host (string replace -a '-' '.' $argv[-1])
  set --erase argv[-1]
  set --query _flag_user; or set --local _flag_user devops
  set --query _flag_port; or set --local _flag_port 20220
  set --query _flag_folder; or set --local _flag_folder '/tmp'

  echo (set_color green)"upload [$argv] to $host:$_flag_folder"(set_color normal)
  if set --query _flag_coco
    echo (set_color green)"upload file via jumpserver"(set_color normal)
    echo (set_color read)'not implemented yet'(set_color normal)
    return 1
  else
    if set --query _flag_direct
      echo (set_color cyan)'upload file via ssh (direct mode)'(set_color normal)
    else
      echo (set_color cyan)'upload file via ssh (proxy mode)'(set_color normal)
    end
    for source_file in $argv
      if set --query _flag_direct
        # direct scp
        scp -C -P $_flag_port $source_file $_flag_user@$host:$_flag_folder
      else
        scp -C -o ProxyCommand="connect -S $SOCKS_PROXY %h %p" -P $_flag_port $source_file $_flag_user@$host:$_flag_folder
      end
      if test $status -ne 0
        echo (set_color red)"upload $source_file failed."(set_color normal)
        return 1
      end
    end
  end
end
