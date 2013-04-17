0 - Général
------------
* Format des dates :
		Les jours et mois sont des valeurs entières.
		L'année comporte 4 chiffres
* Format du genre : valeurs entières
		0 => "Mr", 1 => "Mme", 2 => "Mlle"

* Les clés context.session.uuid et  context.session.callback doivent être présentes à chaque requête.


I - Lancement d'une commande 
--------------------------------

* Url vulcain API :  /orders
* Content-Type: application/json
		
clés obligatoires:
--------------
* 'vendor' : Nom de la stratégie en camel case
* 'context.account.login'
* 'context.account.password'
* 'context.user.*
* 'context.session.uuid' : identifiant session shopelia
* 'context.session.callback_url' : url de callback sur shopelia
* 'context.order.products_urls' : Array des urls des produits à commander

clés optionelles:
---------------
* 'context.account.new_account' : true si la création préalable d'un compte chez le marchand est nécessaire
* 'context.order.credentials' : peut être passé lors de la confirmation de la commande avant paiement


Exemple (au format Ruby):
-------------------------

	{'vendor’ => 'Amazon’,
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
                                      'country' => 'FR’}
                      }
            }}


II - Réponse à une question
--------------------------------

* Url vulcain API :  /answers
* Content-Type: application/json

clés obligatoires:
--------------
* 'context.session.*'
* 'context.answers : Array de hashes contenant les clés 'question_id' et 'answer'

Exemple (au format Ruby):
-------------------------

	{'context' => {
		'session' => {'uuid' => '0129801H', 'callback_url' => 'http://shopelia.com/'},
     'answers' => [{'question_id' => '1', 'answer' => '0'}]}}



III - Messages
---------------
Les messages ne demandent pas de retour de la part de Shopelia.
*Format du message:

IV - Questions
---------------
Les questions exigent une réponse en retour de la part de Shopelia.

V - Confirmation d'achat
------------------------
La confirmation demande une réponse true/false de la part de Shopelia

VI - Echec
-----------

VII - Succès
-------------







