#!/bin/bash
function stop_dispatcher {
  echo 'Stop dispatcher ...'
  /etc/init.d/vulcain-dispatcher stop
}

function start_dispatcher {
  echo 'Start Dispatcher ...'
  /etc/init.d/vulcain-dispatcher start
}

function kill_vulcains {
  echo 'Kill(SIGINT) Vulcains Processes ...'
  kill -2 $(ps aux | pgrep -f 'vulcain/bin/run.rb')
}

function restart_unicorns {
  echo 'Restart Unicorns ...'
  /etc/init.d/vulcain-unicorn restart
}

function reload_vulcains {
  echo 'Reload Vulcains ...'
  kill -s USR2 $(ps aux | pgrep -f 'dispatcher')
}


if [ "$1" = "--hard" ]; then
  echo 'WARNING. This script will kill all vulcains processes. Be sure no one is running.'
  read -p 'Continue?(y/n)' choice

  if [ $choice = "y" ]; then
    stop_dispatcher
    kill_vulcains
    start_dispatcher
    restart_unicorns
  else
    exit
  fi
  
elif [ "$1" = "--soft" ]; then
  stop_dispatcher
  start_dispatcher
  sleep 10
  reload_vulcains
else
  reload_vulcains
fi




