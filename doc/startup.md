Configuration
-------------
* Fichier de configuration : /config/dispatcher.yml

*voir /config/dispatcher.yml.sample*

Lancement
-------------

**vulcain-api**

1 - Lancer le serveur rails : 

	$ rails server


2 - Lancer le dispatcher :

	$ rake vulcain:dispatcher:start
	
Le dispatcher va *"pinger"* les vulcains pour rétablir son pool. 

Il est préférable d'attendre qu'il soit près pour lancer les instances de vulcains.

**"Started" apparaît lorsque le dispatcher est près.**


3 - Lancer les vulcains:

	$ ./bin/run.sh
	

Lancement en mode debug
-------------

Permet d'afficher les logs dans la console.


	$ DISPATCHER_MODE=DEBUG rake vulcain:dispatcher:start


