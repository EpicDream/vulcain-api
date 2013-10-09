#!/bin/bash
function stopDispatcher {
  echo 'Stop dispatcher ...'
  /etc/init.d/vulcain-dispatcher stop
}

function killVulcains {
  echo 'Kill(SIGINT) Vulcains Processes ...'
  kill -2 $(ps aux | pgrep -f 'vulcain/bin/run.rb')
}

function startDispatcher {
  echo 'Start Dispatcher ...'
  /etc/init.d/vulcain-dispatcher start
}

function restartUnicorns {
  echo 'Re-start Unicorns ...'
  /etc/init.d/vulcain-unicorn restart
}

echo 'WARNING. This script will kill all vulcains processes. Be sure no one is running.'

read -p 'Continue?(y/n)' choice

if [ $choice = "y" ]; then
  stopDispatcher
  killVulcains
  startDispatcher
  restartUnicorns
else
  exit
fi  




