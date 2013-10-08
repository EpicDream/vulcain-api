#!/bin/bash

/etc/init.d/vulcain-dispatcher stop
kill $(ps aux | pgrep -f 'vulcain/bin/run.rb')
/etc/init.d/vulcain-dispatcher start
/etc/init.d/vulcain-unicorn restart

