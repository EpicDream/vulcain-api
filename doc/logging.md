##What can be logged during an order operation
----------------------------------------------

*Each log message has session key with uuid and vulcain_id keys*


#####Ever logged

- Each step of strategy the script pass through

#####Logged on demand by vendor stategy

- screenshot
- error_message

#####Logged when global raise
- error message
- stack trace
- page source
- screenshot of driver current page


#####keys

'step', 'screenshot', 'error\_message', 'page\_source', 'session', 'stack\_trace'


#####Log message samples

	{'step':'login', 'session':{'uuid':'20290K', 'vulcain_id':'1'}}
	{'error_message':'some error message', 'session':{'uuid':'20290K', 'vulcain_id':'1'}}

