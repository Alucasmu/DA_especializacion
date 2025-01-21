/* Nivell 1

- Exercici 1
La teva tasca és dissenyar i crear una taula anomenada "credit_card" que emmagatzemi detalls crucials sobre les targetes
de crèdit. La nova taula ha de ser capaç d'identificar de manera única cada targeta i establir una relació adequada amb
les altres dues taules ("transaction" i "company"). Després de crear la taula serà necessari que ingressis la informació
del document denominat "dades_introduir_credit". Recorda mostrar el diagrama i realitzar una breu descripció d'aquest.*/
   
CREATE INDEX idx_credit_card_id ON transaction(credit_card_id);

CREATE TABLE IF NOT EXISTS credit_card (
		id varchar(15) PRIMARY KEY, 
		iban varchar(50), 
		pan varchar(50), 
		pin smallint(4), 
		cvv smallint(3), 
		expiring_date text(8),
        FOREIGN KEY(id) REFERENCES transaction(credit_card_id)        
    );

ALTER TABLE credit_card
DROP CONSTRAINT credit_card_ibfk_1;

ALTER TABLE Pedidos
ADD CONSTRAINT fk_pedidos_clientes
FOREIGN KEY (id_cliente) REFERENCES Clientes(id_cliente);

   
-- Mediante la función Database/Reverse Engineer obtenemos el diagrama con el esquema de las tablas
-- Las nuevas tablas se relacionan con la tabla Transaction mediante los campos user_id y credit_card_id
 
/*- Exercici 2
El departament de Recursos Humans ha identificat un error en el número de compte de l'usuari amb ID CcU-2938. 
La informació que ha de mostrar-se per a aquest registre és: R323456312213576817699999. 
Recorda mostrar que el canvi es va realitzar.*/

UPDATE credit_card
SET iban = 'R323456312213576817699999'
WHERE id='CcU-2938';

SELECT * FROM credit_card
WHERE id='CcU-2938';

/*- Exercici 3
En la taula "transaction" ingressa un nou usuari amb la següent informació:
Id	108B1D1D-5B23-A76C-55EF-C568E49A99DD
credit_card_id	CcU-9999
company_id	b-9999
user_id	9999
lat	829.999
longitude	-117.999
amount	111.11
declined	0
*/
INSERT INTO company (
		Id,
        company_name,
        phone,
        email,
        country,
        website)
VALUES ('b-9999',
		'Barcelona Activa',
        '93 25 16 24 30',
        'barcelonaactiva@gmail.com',
		'Spain',
        'https://barcelonaactiva.com');

 INSERT INTO transaction (       
        Id,
		credit_card_id,
		company_id,
		user_id,
		lat,
		longitude,
        timestamp,
		amount,
		declined)
VALUES ('108B1D1D-5B23-A76C-55EF-C568E49A99DD',
		'CcU-9999',
		'b-9999',
		9999,
		829.999,
		-117.999,
        '2025-01-16 10:29:18',
		111.11,
		0);

SELECT * FROM transaction
WHERE id='108B1D1D-5B23-A76C-55EF-C568E49A99DD';

/*- Exercici 4
Des de recursos humans et sol·liciten eliminar la columna "pan" de la taula credit_*card. Recorda mostrar el canvi realitzat.*/
ALTER TABLE credit_card
DROP COLUMN pan;

SELECT * FROM credit_card;

/*Nivell 2

Exercici 1
Elimina de la taula transaction el registre amb ID 02C6201E-D90A-1859-B4EE-88D2986D3B02 de la base de dades.*/
SET FOREIGN_KEY_CHECKS = 0;

DELETE FROM transaction 
WHERE id = '02C6201E-D90A-1859-B4EE-88D2986D3B02';

SET FOREIGN_KEY_CHECKS = 1;

SELECT * FROM transaction
WHERE id = '02C6201E-D90A-1859-B4EE-88D2986D3B02';

/* Exercici 2
La secció de màrqueting desitja tenir accés a informació específica per a realitzar anàlisi i estratègies efectives. 
S'ha sol·licitat crear una vista que proporcioni detalls clau sobre les companyies i les seves transaccions. 
Serà necessària que creïs una vista anomenada VistaMarketing que contingui la següent informació: 
Nom de la companyia. Telèfon de contacte. País de residència. Mitjana de compra realitzat per cada companyia. 
Presenta la vista creada, ordenant les dades de major a menor mitjana de compra. */
CREATE OR REPLACE VIEW VistaMarketing AS
SELECT  c.company_name as Nombre_companyia, 
		c.phone as Telefono_contacto, 
		c.country as Pais_residencia, 
		round(avg(t.amount),2) as Media_compra
FROM company c
LEFT JOIN transaction t
		  ON c.id = t.company_id
WHERE t.declined=0
GROUP BY c.company_name, c.phone, c.country
ORDER BY Media_compra DESC;

SELECT * FROM VistaMarketing;

/* Exercici 3
Filtra la vista VistaMarketing per a mostrar només les companyies que tenen el seu país de residència en "Germany" */
SELECT * 
FROM VistaMarketing
WHERE pais_residencia="Germany";


/* Nivell 3
Exercici 1
La setmana vinent tindràs una nova reunió amb els gerents de màrqueting. Un company del teu equip va realitzar 
modificacions en la base de dades, però no recorda com les va realitzar. Et demana que l'ajudis a deixar els 
comandos executats per a obtenir el següent diagrama:
 Recordatori
En aquesta activitat, és necessari que descriguis el "pas a pas" de les tasques realitzades. 
És important realitzar descripcions senzilles, simples i fàcils de comprendre. 
Per a realitzar aquesta activitat hauràs de treballar amb els arxius denominats "estructura_dades_user" i "dades_introduir_user" */

ALTER TABLE company
DROP COLUMN website;

RENAME TABLE user TO data_user;

ALTER TABLE data_user
RENAME COLUMN email
TO personal_email;

ALTER TABLE credit_card
MODIFY COLUMN id VARCHAR(20);

ALTER TABLE credit_card
MODIFY COLUMN pin VARCHAR(4);

ALTER TABLE credit_card
MODIFY COLUMN cvv INT;

ALTER TABLE credit_card
MODIFY COLUMN expiring_date VARCHAR(20);

ALTER TABLE credit_card
ADD COLUMN fecha_actual DATE;

ALTER TABLE credit_card
DROP CONSTRAINT credit_card_ibfk_1;

SELECT credit_card_id
FROM transaction
WHERE credit_card_id NOT IN (SELECT id FROM credit_card);

INSERT INTO credit_card (
		Id,
        iban,
        pin,
        cvv,
        expiring_date,
        fecha_actual)
VALUES ('CcU-9999',
		'L323456312213576817699998',
        '1825',
        123,
		'21/01/2025',
        '2025-01-21');

ALTER TABLE transaction
ADD CONSTRAINT fk_credit_card
FOREIGN KEY (credit_card_id) REFERENCES credit_card(id);
        
ALTER TABLE data_user
DROP CONSTRAINT data_user_ibfk_1;

SELECT user_id
FROM transaction
WHERE user_id NOT IN (SELECT id FROM data_user);

INSERT INTO data_user (
		Id,
        name,
        surname,
        phone,
        personal_email,
        birth_date,
        country,
        city,
        postal_code,
        address)
VALUES (9999,
		'Lucas',
        'Munoz',
        '938943966',
		'lucasm@gmail.com',
        'Mar 9, 1971',
        'Spain',
        'Barcelona',
        '08870',
        'Pz Dr Robert 6');

ALTER TABLE transaction
ADD CONSTRAINT fk_user
FOREIGN KEY (user_id) REFERENCES data_user(id);

/* Exercici 2
L'empresa també et sol·licita crear una vista anomenada "InformeTecnico" que contingui la següent informació:
ID de la transacció
Nom de l'usuari/ària
Cognom de l'usuari/ària
IBAN de la targeta de crèdit usada.
Nom de la companyia de la transacció realitzada.
Assegura't d'incloure informació rellevant de totes dues taules i utilitza àlies per a canviar de nom columnes segons sigui necessari.
Mostra els resultats de la vista, ordena els resultats de manera descendent en funció de la variable ID de transaction.*/
CREATE OR REPLACE VIEW InformeTecnico AS
SELECT 
	t.id as ID_transaccion,
	u.name as Nombre_usuario,
	u.surname as Apellido_usuario,
	cr.iban as IBAN_tarjeta_credito_usada,
	co.company_name as Nombre_companyia
FROM transaction t
LEFT JOIN data_user u
		  ON u.id = t.user_id
LEFT JOIN credit_card cr
		  ON cr.id = t.credit_card_id
LEFT JOIN company co
		  ON co.id = t.company_id
ORDER BY t.id DESC;

SELECT * FROM InformeTecnico;
