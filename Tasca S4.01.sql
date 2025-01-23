/*Nivell 1

Descàrrega els arxius CSV, estudia'ls i dissenya una base de dades amb un esquema d'estrella que contingui, 
almenys 4 taules de les quals puguis realitzar les següents consultes:*/

CREATE DATABASE IF NOT EXISTS ventas;

CREATE TABLE IF NOT EXISTS companies (
	company_id varchar(15) primary key,
    company_name varchar(255),
    phone varchar(15),
    email varchar(100),
    country varchar(100),
    website varchar(255)
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/companies.csv'
INTO TABLE companies
FIELDS TERMINATED BY ','   -- Especifica que las columnas están separadas por comas
ENCLOSED BY '"'            -- Si las cadenas están entre comillas dobles
LINES TERMINATED BY '\n'   -- Especifica que cada línea representa un registro
IGNORE 1 ROWS;             -- Ignora la primera fila (cabeceras), si las tiene

-- También se pueden cargar los ficheros CSV poniéndose sobre la tabla y clicando a Table Data Import Wizard
SELECT * FROM companies;

CREATE TABLE IF NOT EXISTS credit_cards (
	id varchar(20) primary key,
    user_id int,
    iban varchar(50),
    pan varchar(20),
    pin varchar(4),
    cvv int,
    track1 varchar(50),
    track2 varchar(50),
    expiring_date varchar(20),
    FOREIGN KEY(user_id) REFERENCES users(id)
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/credit_cards.csv'
INTO TABLE credit_cards
FIELDS TERMINATED BY ','   -- Especifica que las columnas están separadas por comas
ENCLOSED BY '"'            -- Si las cadenas están entre comillas dobles
LINES TERMINATED BY '\n'   -- Especifica que cada línea representa un registro
IGNORE 1 ROWS;             -- Ignora la primera fila (cabeceras), si las tiene

SELECT * FROM credit_cards;

CREATE TABLE IF NOT EXISTS products (
	id int primary key,
    product_name varchar(50),
    price varchar(15),
    colour varchar(15),
    weight float,
    warehouse_id varchar(15)
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/products.csv'
INTO TABLE products
FIELDS TERMINATED BY ','   -- Especifica que las columnas están separadas por comas
ENCLOSED BY '"'            -- Si las cadenas están entre comillas dobles
LINES TERMINATED BY '\n'   -- Especifica que cada línea representa un registro
IGNORE 1 ROWS;             -- Ignora la primera fila (cabeceras), si las tiene

SELECT * FROM products;

CREATE TABLE IF NOT EXISTS users (
	id int primary key,
    name varchar(100),
    surname varchar(100),
    phone varchar(150),
    email varchar(150),
    birth_date varchar(100),
    country varchar(150),
    city varchar(150),
    postal_code varchar(100),
    address varchar(255)
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/users_usa.csv'
INTO TABLE users
FIELDS TERMINATED BY ','   -- Especifica que las columnas están separadas por comas
ENCLOSED BY '"'            -- Si las cadenas están entre comillas dobles
LINES TERMINATED BY '\r\n'   -- Especifica que cada línea representa un registro cuando hay espacios dentro del campo
IGNORE 1 ROWS;             -- Ignora la primera fila (cabeceras), si las tiene

SELECT * FROM users;

CREATE TABLE IF NOT EXISTS transactions (
	id varchar(255) primary key,
    card_id varchar(20),
    business_id varchar(15),
    timestamp timestamp,
    amount float,
    declined boolean,
    product_ids varchar(255),
    user_id int,
    lat float,
    longitud float,
    FOREIGN KEY(card_id) REFERENCES credit_cards(id),
    FOREIGN KEY(business_id) REFERENCES companies(company_id),
    FOREIGN KEY(user_id) REFERENCES users(id)
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/transactions.csv'
INTO TABLE transactions
FIELDS TERMINATED BY ';'   -- Especifica que las columnas están separadas por punto y coma
ENCLOSED BY '"'            -- Si las cadenas están entre comillas dobles
LINES TERMINATED BY '\r\n'   -- Especifica que cada línea representa un registro cuando hay espacios dentro del campo
IGNORE 1 ROWS;             -- Ignora la primera fila (cabeceras), si las tiene

-- Si hay comas dentro de un campo, cargar con el wizard pero especificar en "configure import setting" que el "field separator" es ";". 
SELECT * FROM transactions;

/* - Exercici 1
Realitza una subconsulta que mostri tots els usuaris amb més de 30 transaccions utilitzant almenys 2 taules.*/
SELECT id, name, surname
FROM users
WHERE id IN (SELECT user_id
			 FROM transactions t
			 WHERE declined=0
			 GROUP BY user_id
			 HAVING count(id) > 30)
ORDER BY id;

/* - Exercici 2
Mostra la mitjana d'amount per IBAN de les targetes de crèdit a la companyia Donec Ltd, utilitza almenys 2 taules.*/
SELECT co.company_id, co.company_name, cc.iban, round(avg(t.amount),2) as media_importe
FROM transactions t
LEFT JOIN credit_cards cc
		  ON cc.id = t.card_id
LEFT JOIN companies co
		  ON co.company_id = t.business_id
WHERE co.company_name = 'Donec Ltd' and t.declined=0
GROUP BY co.company_id, co.company_name, cc.iban;

/* Nivell 2

Crea una nova taula que reflecteixi l'estat de les targetes de crèdit basat en si les últimes tres transaccions 
van ser declinades i genera la següent consulta:*/

CREATE TABLE credit_cards_estado AS (
SELECT 
a.id,
a.user_id,
a.iban,
CASE WHEN sum(a.declined) >= 3 THEN 'Inactiva' ELSE 'Activa' END AS estado_tarjeta
FROM (SELECT 
			cc.id, 
            cc.user_id,
			cc.iban, 
			t.timestamp, 
			t.declined,
			ROW_NUMBER() OVER (PARTITION BY cc.id ORDER BY t.timestamp DESC) AS num_operaciones
		FROM credit_cards cc
		LEFT JOIN transactions t
				  ON cc.id = t.card_id
		ORDER BY cc.id, t.timestamp DESC
		) a
WHERE a.num_operaciones <= 3
GROUP BY a.id, a.user_id, a.iban
);

ALTER TABLE credit_cards_estado
ADD CONSTRAINT fk_credit_cards_estado
FOREIGN KEY (id) REFERENCES credit_cards(id);

SELECT * FROM credit_cards_estado;

/*Exercici 1
Quantes targetes estan actives?*/
SELECT count(*) as num_tarjetas_activas
FROM credit_cards_estado
WHERE estado_tarjeta='Activa';

/*Nivell 3
Crea una taula amb la qual puguem unir les dades del nou arxiu products.csv amb la base de dades creada, 
tenint en compte que des de transaction tens product_ids. Genera la següent consulta:*/
CREATE TABLE transactions_products AS (
WITH RECURSIVE numeros AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1
    FROM numeros
    WHERE n <= 100  -- Cambiar según el número máximo de elementos en la lista
)
SELECT 
    t.id,
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(t.product_ids, ',', numeros.n), ',', -1)) AS product_id
FROM transactions t
LEFT JOIN numeros
		  ON numeros.n <= 1 + LENGTH(t.product_ids) - LENGTH(REPLACE(t.product_ids, ',', ''))
WHERE TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(t.product_ids, ',', numeros.n), ',', -1)) <> ''
ORDER BY t.id, numeros.n
);

ALTER TABLE transactions_products
ADD CONSTRAINT fk_transactions_products
FOREIGN KEY (id) REFERENCES transactions(id);

ALTER TABLE transactions_products
MODIFY COLUMN product_id INT;

ALTER TABLE transactions_products
ADD CONSTRAINT fk_transactions_products2
FOREIGN KEY (product_id) REFERENCES products(id);

SELECT * FROM transactions_products;

/*Exercici 1
Necessitem conèixer el nombre de vegades que s'ha venut cada producte.*/
SELECT p.id, p.product_name, count(tp.product_id) as num_ventas_producto
FROM products p
LEFT JOIN transactions_products tp
		  ON tp.product_id = p.id
GROUP BY p.id, p.product_name
ORDER BY num_ventas_producto DESC;





