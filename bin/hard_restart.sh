#!/bin/bash

echo 'Stop dispatcher ...'
/etc/init.d/vulcain-dispatcher stop

echo 'Kill(SIGINT) Vulcains Processes ...'
kill -2 $(ps aux | pgrep -f 'vulcain/bin/run.rb')

echo 'Start Dispatcher ...'
/etc/init.d/vulcain-dispatcher start

echo 'Re-start Unicorns ...'
/etc/init.d/vulcain-unicorn restart

