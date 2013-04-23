0 - Général
------------
**Format des dates** :
		Les jours et mois sont des valeurs entières.
		L'année comporte 4 chiffres

**Format du genre** : valeurs entières
		0 => "Mr", 1 => "Mme", 2 => "Mlle"

Les clés context.session.uuid et  context.session.callback **doivent être présentes à chaque requête**.


I - Lancement d'une commande 
--------------------------------

* Url vulcain API :  /orders
* Content-Type: application/json
		
#####clés obligatoires:

* 'vendor' : Nom de la stratégie en camel case
* 'context.account.login'
* 'context.account.password'
* 'context.user.*
* 'context.session.uuid' : identifiant session shopelia
* 'context.session.callback_url' : url de callback sur shopelia
* 'context.order.products_urls' : Array des urls des produits à commander

#####clés optionelles:

* 'context.account.new_account' : true si la création préalable d'un compte chez le marchand est nécessaire
* 'context.order.credentials' : peut être passé lors de la confirmation de la commande avant paiement


Exemple (au format Ruby):
-------------------------

	{'vendor' => 'Amazon',
	'context' => {
          	'account' => {'login' => 'marie_rose_07@yopmail.com', 'password' => 'shopelia2013', 'new_account' => true},
            'session' => {'uuid' => '0129801H', 'callback_url' => 'http://shopelia.com/'},
            'order' => {'products_urls' => ['url_1', 'url_2'],
                        'credentials' => {
                          holder => '', 
                          'number' => '', 
                          'exp_month' => '',
                          'exp_year' => '',
                          'cvv' => ''}},

            'user' => {'birthdate' => {'day' => 1, 'month' => 4, 'year' => 1985},
                       'mobile_phone' => '0134562345',
                       'land_phone' => '0134562345',
                       'first_name' => 'Pierre',
                       'gender' => 0,
                       'last_name' => 'Legrand',
                       'address' => { 'address_1' => '12 rue des lilas',
                                      'address_2' => '',
                                      'additionnal_address' => '',
                                      'zip' => '75019',
                                      'city' => 'Paris',
                                      'country' => 'FR'}
                      }
            }}


II - Question & Réponse à une question
--------------------------------
####- Question
Vulcain API envoie un message à l'url de callback de Shopelia de la forme :

**clés**:

*"verb":"ask"*

*"content":{"questions":[{},{}..]}*

*"session":{…}*


	{"verb"=>"ask", 
	 "content"=>{"questions"=>[{"text"=>"Choix de la couleur", "id"=>"2", "options"=>{"0"=>"Jet Black"}}]},
	 "session"=>{"uuid"=>"2129801H", "callback_url"=>"http://127.0.0.1:3000/shopelia"}
	}
####- Réponse
* Url vulcain API :  /answers
* Content-Type: application/json

Shopelia doit alors répondre sur l'url /answers en POST avec un Content-Type "application/json".

La valeur de clé "question_id" de la réponse *DOIT* être égale à celle de la clé "id" de la question.

La valeur de la clé "session.uuid" de la réponse *DOIT* être égale à celle de la clé "session.uuid" de la question.

**clés**:

*"context":{"answers":[{},{}..], "session":{…}*


	{ "context"=>{
			"answers"=>[{"question_id"=>"2", "answer"=>"0"}],
			"session"=>{"uuid"=>"2129801H", "callback_url"=>"http://127.0.0.1:3000/shopelia"}
		}
	}

#####clés obligatoires:
* 'context.session.*'
* 'context.answers : Array de hashes contenant les clés 'question_id' et 'answer'


III - Messages
---------------
Les messages ne demandent pas de réponse de la part de Shopelia. Ce sont simplement des messages indiquant
l'état où en est le processus de commande, comme par exemple "Panier vidé", "Panier rempli" ...

*Format du message:*

**clés**:

*"verb":"message"*

*"content":"…",*

*"session":{…}*

	{ "verb"=>"message", 
	  "content"=>"Cart filled", 
		"session"=>{"uuid"=>"0129801H", "callback_url"=>"http://127.0.0.1:3000/shopelia"}}


IV - Confirmation d'achat
------------------------
* Url vulcain API :  /answers
* Content-Type: application/json

La confirmation d'achat demande une réponse true/false de la part de Shopelia.

####- Question
Vulcain API envoie un message à l'url de callback de Shopelia de la forme :

**clés**:

*"verb":"assess"*

*"content":{"questions":[{}], "products":[{},{}…], "billing":{"price":Float, "shipping":Float}}*

*"session":{…}*

Chaque élement 'product' de la clé "products" est composé des clés suivantes:

*"price\_text":String* => Prix texte affiché sur le site

*"product\_title":String* => Libellé du produit

*"product\_image\_url":String* => Url de l'image du produit

*"price\_delivery":Float* => Montant de la  livraison

*"price\_product":Float* => Prix du produit(sans livraison)

*"url":String* => Url du produit


Une seule question est présente qui ne comporte qu'une seule clé avec une valeur, "id",  c'est l'id que devra avoir la clé "question_id" de la réponse. Il n'y a pas de valeur pour les clés "options" et "text" car les seules réponses possibles sont toujours *true* ou *false* et qu'implicitement, le texte de la question est "Confirmez vous la commande?".

	{"verb"=>"assess", 
	 "content"=>{"questions"=>[{"text"=>nil, "id"=>"3", "options"=>nil}], 
	 "products"=>[{"price_text"=>"Prix : EUR 40,00 & livraison et retour gratuits ", "product_title"=>"Oakley Represent Short homme", "product_image_url"=>"http://ecx.images-amazon.com/images/I/41Ba3%2BKXceL._AA300_.jpg", "price_delivery"=>0, "price_product"=>40.0, "url"=>"http://www.amazon.fr/Oakley-Represent-Short-homme-Stone/dp/B0097LKBAW"}], 
	 "billing"=>{"price"=>40.0, "shipping"=>0}},
	 "session"=>{"uuid"=>"2129801H", "callback_url"=>"http://127.0.0.1:3000/shopelia"}}



####- Réponse
* Url vulcain API :  /answers
* Content-Type: application/json

La valeur de clé "question_id" de la réponse *DOIT* être égale à celle de la clé "id" de la question.

La valeur de la clé "session.uuid" de la réponse *DOIT* être égale à celle de la clé "session.uuid" de la question.

**clés**:


*"context":{"answers":[{}], "session":{…}*


	{ "context"=>{
		"answers"=>[{"question_id"=>"3", "answer"=>true}],
		"session"=>{"uuid"=>"2129801H", "callback_url"=>"http://127.0.0.1:3000/shopelia"}
		}
	}


#####clés obligatoires:
* 'context.session.*'
* 'context.answers : Une seule réponse ici contenant les clés 'question_id' et 'answer'



VI - Echecs
-----------

Les messages d'échecs ont pour verbe 'failure' et ne demandent pas de réponse de la part de Shopelia.

**clés**:

*"verb":"failure"*

*"status":""*

*"error_message":""*

*"session":{...}*

	{ "verb":"failure", "status":"no_idle", "error_message":"", "session":{"uuid"=>"2129801H", "callback_url"=>"http://127.0.0.1:3000/shopelia"}}
	
Les différents statuts peuvent être :

"no_idle" : aucun vulcain n'est disponible.

"exception": une exception s'est produite.

"error": Erreur avec un message d'erreur de la stratégie


VII - Succès
-------------

Le message de succès est le dernier message envoyé par Vulcain-API en cas de succès de la commande.
Une fois ce message envoyé, la commande est considérée comme terminée et l'instance de vulcain core est libérée.

**clés**:

*"verb":"success"*

*"session":{...}*

	{ "verb":"success", "session":{"uuid"=>"2129801H", "callback_url"=>"http://127.0.0.1:3000/shopelia"}}








