Prérequis
=========

Pour fonctionner correctement, doivent être installés :
* google-chrome
* chromedriver (http://code.google.com/p/chromedriver/downloads/list)

Une fois google-chrome installé, il est recommendé d'installer 'Adblock Plus' :  
lancez google-chrome, plus installez 'Adblock Plus'.

Lancements
==========

Via rake
--------

Dans un terminal, rendez-vous à la racine de vulcain-api, puis lancez la commande

    rake strategies:lunch_plugin

Manuellement
------------

Lancez le server rails dans un terminal

    rails server

Puis lancez google-chrome avec l'extension installée manuellement (voir ci-après).


Installez le plugin manuellement
--------------------------------

Pour celà rendez vous sur la page des extensions de chrome, puis cochez la case 'Mode développeur'.  
Ensuite cliquez sur 'Charger l'extension non empaquetée...' puis rendez vous dans le dossier 'plugin' 
et sélectionnez le dossier 'mapper'.

Utilisation
===========

Lorsque vous êtes sur la page principale du site dont vous voulez créer la stratégie,
cliquez sur l'icone de l'extension.  
A chaque fois que vous reviendrez sur ce site, l'extension se chargera automatiquement.  
Pour désactiver ce comportement, recliquez sur l'icone de l'extension.

Pour activer la console développeur (voir les erreurs, les éléments trouvés, le chemin de ses éléments, etc),
le raccourci est Ctrl+Shift+I.
Vous pouvez aussi l'activer en allant dans le menu, puis Outils, puis Outils de développement.

L'aide pour l'utilisation du plugin se trouve dans celui-ci.

Une fois la stratégie terminée, faites

    rake strategies:create[identifiant_de_la_strategie]

avec identifiant_de_la_strategie l'id que vous trouverez sur la page de démarrage du plugin.
Cette commande créera les fichiers nécessaires.

Un fois les fichiers créés, il faut encore les envoyer sur le serveur.

    git commit -a -m "[Strategy] add Le_Nom_De_La_Strategie"
    git push
