###Vulcain API

Note : Le password est géré par défaut pour le moment et est "shopelia"
######Exemple d'utilisation avec curl pour crééer un compte(Rue du Commerce)

    curl -d"user[firstname]=Eric&user[lastname]=Larcheveque&user[email]=elarch%2B3@gmail.com&user[address]=14%20boulevard%20du%20chateau&user[city]=Neuilly%20sur%20seine&user[postalcode]=92200&user[birthday]=1973-09-30" 127.0.0.1:8080/accounts

######Exemple d'utilisation avec curl pour passer une commande

    curl -d"user[email]=elarch%2B3@gmail.com&cb[number]=&cb[month_expire]=&cb[year_expire]=15&cb[crypto]=&product_url=http://m.rueducommerce.fr/fiche-produit/TRANS-TS8GJF600" 127.0.0.1:8080/orders


# Installation-Dev

## Linux

Avant d'appeler bundle, il faut penser à installer mongodb

    sudo apt-get install mongodb

Suite à un problème de chargement de mongo dans rails, il faut aussi installer la gem correspondante avant aussi.

    gem install mongo

Vous pouvez maintenant exécuter bundle.

    bundle

Il se peut qu'on message vous indique que pour des raisons de performance vous deviez installer bson_ext.
Faites le puis réexécutez bundle.

    gem install bson_ext
    bundle

Si vous voulez lancer des Selenium en local vous devez aussi l'installer.
Aller sur la page http://code.google.com/p/chromedriver/downloads/list pour télécharger la version du driver correspondante.
Installez la où la gem pourra la trouver (/usr/bin/ par exemple).
