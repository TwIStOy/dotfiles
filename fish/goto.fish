function goto --description 'login remote server via proxy'
  set -l options 'h/help' 'u/user=?' 'p/port=?' 'd/direct' 'c/coco'

  argparse --name=goto $options -- $argv

  if set --query _flag_help
    printf 'Usage: goto [OPTIONS]\n\n'
    printf 'Options:\n'
    printf '  -h/--help    Show this message and exit.\n'
    printf '  -u/--user    Username to login.\n'
    printf '  -p/--port    Port to connect to on the remote host.\n'
    printf '  -d/--direct  Use direct mode.\n'
    printf '  -c/--coco    Login via jumpserver.(ignore all other options)\n'
    return 0
  end

  if test (count $argv) -lt 1
    echo (set_color red)'ip address is required'(set_color normal)
    return
  end

  set -l host (string replace -a '-' '.' $argv[1])
  echo (set_color green)"[$_flag_user@$host:$_flag_port] connecting..."(set_color normal)

  if set --query _flag_coco
    # via jumpserver
    jumpgo $host
  else
    set --query _flag_user;   or set --local _flag_user devops
    set --query _flag_port;   or set --local _flag_port 20220

    if set --query _flag_direct
      echo "ssh -A -p $_flag_port $_flag_user@$host"
      ssh -A -p $_flag_port $_flag_user@$host
    else
      echo "ssh -A -o ProxyCommand='connect -S 127.0.0.1:7891 %h %p' -p $_flag_port $_flag_user@$host"
      ssh -A -o ProxyCommand='connect -S 127.0.0.1:7891 %h %p' -p $_flag_port $_flag_user@$host
    end
  end
end

