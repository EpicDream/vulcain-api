Vérification des vulcains
--------------------------

Permet de vérifier le bon déroulement de 3 commandes simultanées

Une réponse "assess" : false sera automatiquement renvoyée au dispatcher pour les 3 commandes lorsque la question sera demandée par les vulcains core.

0 - Voir doc startup.md

1 - Lancer le dispatcher en Mode 'check':

	DISPATCHER_MODE=CHECK rake vulcain:dispatcher:start 

2 - Lancer les 3 vulcains
		
3 - Lancer le script :

	ruby test/integration/check_test.rb
	