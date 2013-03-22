###Vulcain API

Note : Le password est géré par défaut pour le moment et est "shopelia"
######Exemple d'utilisation avec curl pour crééer un compte(Rue du Commerce)

curl -d"user[firstname]=Eric&user[lastname]=Larcheveque&user[email]=elarch%2B3@gmail.com&user[address]=14%20boulevard%20du%20chateau&user[city]=Neuilly%20sur%20seine&user[postalcode]=92200&user[birthday]=1973-09-30" 127.0.0.1:8080/accounts

######Exemple d'utilisation avec curl pour passer une commande

curl -d"user[email]=elarch%2B3@gmail.com&cb[number]=&cb[month_expire]=&cb[year_expire]=15&cb[crypto]=&product_url=http://m.rueducommerce.fr/fiche-produit/TRANS-TS8GJF600" 127.0.0.1:8080/orders


