/* Nivell 1

- Exercici 1
A partir dels documents adjunts (estructura_dades i dades_introduir), importa les dues taules. 
Mostra les característiques principals de l'esquema creat i explica les diferents taules i variables que existeixen. 
Assegura't d'incloure un diagrama que il·lustri la relació entre les diferents taules i variables.
*/
-- Mediante la función Database/Reverse Engineer, se puede obtener el gráfico del esquema del modelo con todos sus campos
-- Ambas tablas se relacionan mediante el campo company.id y transaction.company_id.

/* - Exercici 2
Utilitzant JOIN realitzaràs les següents consultes:*/
USE transactions
-- Llistat dels països que estan fent compres.
SELECT DISTINCT c.country
FROM company c
	INNER JOIN transaction t
    ON c.id = t.company_id
WHERE t.declined=0;
    
-- Des de quants països es realitzen les compres.
SELECT count(distinct c.country) as Num_paises
FROM company c
	INNER JOIN transaction t
    ON c.id = t.company_id 
 WHERE t.declined=0;
    
-- Identifica la companyia amb la mitjana més gran de vendes.
SELECT c.company_name, avg(t.amount) as media_ventas
FROM company c
	LEFT JOIN transaction t
				ON c.id = t.company_id
WHERE t.declined=0
GROUP BY t.company_id
ORDER BY media_ventas DESC
LIMIT 1; 

/* - Exercici 3
Utilitzant només subconsultes (sense utilitzar JOIN):*/
-- Mostra totes les transaccions realitzades per empreses d'Alemanya.
SELECT *
FROM transaction
WHERE declined=0 and company_id in (SELECT id 
									 FROM company 
									 WHERE country='Germany');
    
-- Llista les empreses que han realitzat transaccions per un amount superior a la mitjana de totes les transaccions.
SELECT c.company_name, c.phone, c.email, c.country, c.website, t.amount
FROM company c
LEFT JOIN transaction t
ON c.id = t.company_id
WHERE c.id in (SELECT company_id
					FROM transaction
                    WHERE amount > (SELECT avg(amount)
											FROM transaction
                                            WHERE declined=0)
				)
	and t.declined=0;

-- Eliminaran del sistema les empreses que no tenen transaccions registrades, entrega el llistat d'aquestes empreses.
SELECT *
FROM company 
WHERE NOT EXISTS (SELECT DISTINCT company_id
							FROM transaction
							WHERE declined=0);

-- No hay ninguna empresa sin transacciones registradas

/* Nivell 2
Exercici 1
Identifica els cinc dies que es va generar la quantitat més gran d'ingressos a l'empresa per vendes. 
Mostra la data de cada transacció juntament amb el total de les vendes.*/
SELECT date(timestamp) as Dia, sum(amount) as Ventas_diarias
FROM transaction
WHERE Declined=0
GROUP BY Dia
ORDER BY Ventas_diarias DESC
LIMIT 5;

/*Exercici 2
Quina és la mitjana de vendes per país? Presenta els resultats ordenats de major a menor mitjà.*/
SELECT c.country, avg(t.amount) as Media_ventas
FROM company c
	INNER JOIN transaction t
    ON c.id = t.company_id
WHERE t.declined=0
GROUP BY c.country
ORDER BY Media_ventas DESC;

/*Exercici 3
En la teva empresa, es planteja un nou projecte per a llançar algunes campanyes publicitàries per a fer competència
a la companyia "Non Institute". Per a això, et demanen la llista de totes les transaccions realitzades per empreses 
que estan situades en el mateix país que aquesta companyia.
Mostra el llistat aplicant JOIN i subconsultes.*/
SELECT c.company_name, c.country, t.*
FROM transaction t
	  INNER JOIN company c
				 ON c.id = t.company_id
WHERE t.declined=0 and c.country = (SELECT country 
									FROM company 
                                    WHERE company_name="Non Institute")
ORDER BY c.company_name;

-- Mostra el llistat aplicant solament subconsultes.
SELECT t.*
FROM transaction t
WHERE t.declined= 0 and t.company_id in (SELECT id
										  FROM company
										  WHERE country = (SELECT country
															 FROM company
															 WHERE company_name="Non Institute")
									     )
ORDER BY t.company_id;

/* Nivell 3
Exercici 1
Presenta el nom, telèfon, país, data i amount, d'aquelles empreses que van realitzar transaccions amb un valor comprès 
entre 100 i 200 euros i en alguna d'aquestes dates: 29 d'abril del 2021, 20 de juliol del 2021 i 13 de març del 2022. 
Ordena els resultats de major a menor quantitat.*/
SELECT c.company_name, c.phone, c.country, t.amount, date(t.timestamp) as dia
FROM transaction t
	  LEFT JOIN company c
				 ON c.id = t.company_id
WHERE t.declined=0 
	  and (t.amount between 100 and 200) 
      and (date(t.timestamp) in ('2021-04-29','2021-07-20','2022-03-13'))	
ORDER BY t.amount DESC;

/*Exercici 2
Necessitem optimitzar l'assignació dels recursos i dependrà de la capacitat operativa que es requereixi, 
per la qual cosa et demanen la informació sobre la quantitat de transaccions que realitzen les empreses, 
però el departament de recursos humans és exigent i vol un llistat de les empreses on especifiquis 
si tenen més de 4 transaccions o menys.*/

SELECT c.company_name, 
	   count(t.id) as num_transacciones,
	   case when count(t.id) >= 4 then "Superior o igual a 4 transacciones" 
			else "Inferior a 4 transacciones" end as "Volumen transacciones"
FROM company c
	LEFT JOIN transaction t
			  ON c.id = t.company_id
WHERE t.declined=0
GROUP BY t.company_id
ORDER BY c.company_name;
