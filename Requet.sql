/*Select des tables*/
SELECT id, nom, prénom FROM Client;

SELECT id, nom, prénom FROM Membre INNER JOIN Client ON Client.id = Membre.idClient;

SELECT * FROM Hôtel;

/*Affichage hôtel dans ville*/
SELECT Hôtel.nom, Ville.nom FROM Hôtel INNER JOIN Ville ON Ville.id = Hôtel.idVille;

/*Requête 1*/
/*Les clients ayant fait au moins une réservation dans un hôtel se trouvant dans la ville dans
laquelle ils habitent.*/
SELECT DISTINCT Client.id, Client.nom, Client.prénom
FROM Client
	INNER JOIN Réservation ON Réservation.idClient = Client.id
	INNER JOIN Hôtel ON Hôtel.id = Réservation.idChambre
WHERE Client.idVille = Hôtel.idVille;

/*test : Requête affichant les clients avec leur ville et l'id des hôtels auxquels les clients ont réservés*/
SELECT DISTINCT Client.id, Client.nom, Client.prénom, Ville.nom, Chambre.idHôtel 
FROM Réservation
	INNER JOIN Client ON Client.id = Réservation.idclient
	INNER JOIN Ville ON Ville.id = Client.idVille
	INNER JOIN Chambre ON Chambre.idhôtel = Réservation.idChambre AND Chambre.numéro = Réservation.numéroChambre 
ORDER BY Client.id;

/*Requête 2*/
/*Prix min. prix.max pour nuit à Interlaken*/
SELECT MIN(Chambre.prixParNuit) AS "prix min (non membre)",
	   MAX(chambre.prixParNuit) AS "prix max (non membre)"/*,
	   MIN(CAST((100 - Hôtel.rabaisMembre) AS float)/100 * Chambre.prixParNuit) AS "prix min (membre)",
	   MAX(CAST((100 - Hôtel.rabaisMembre) AS float)/100 * Chambre.prixParNuit) AS "prix max (membre)"*/
FROM Hôtel
	INNER JOIN Chambre ON Chambre.idhôtel = Hôtel.id
	INNER JOIN Ville ON Ville.id = Hôtel.idVille 
WHERE Ville.nom = 'Interlaken';


/*Requête 3*/
/*Prix moyen par étage ordonné par ordre croissant de l'hôtel JungFrau Petrus Palace*/
SELECT AVG(Chambre.prixParNuit) AS "prix moyen chambre", Chambre.étage
FROM Chambre
	INNER JOIN Hôtel ON Hôtel.id = Chambre.idHôtel
WHERE Hôtel.nom = 'JungFrau Petrus Palace'
GROUP BY Chambre.étage
ORDER BY Chambre.étage;

/*Requête 4*/
/*Hôtel avec chambre qui a baignoire > 1*/
SELECT Hôtel.nom
FROM Hôtel
	INNER JOIN Chambre ON Chambre.idHôtel = Hôtel.id
	INNER JOIN Chambre_Equipement ON Chambre_Equipement.idChambre = Chambre.idHôtel
			   AND Chambre_Equipement.numéroChambre = Chambre.numéro
WHERE Chambre_Equipement.nomEquipement = 'Baignoire' AND Chambre_Equipement.quantité > 1;

/*Requête 5*/
/*Hôtel avec le plus de tarif différent*/
WITH NombreDeTarifsDifférentsParHôtel AS (
	SELECT nom, COUNT(DISTINCT Chambre.prixParNuit) AS nbr
	FROM Hôtel
		INNER JOIN Chambre ON Chambre.idHôtel = Hôtel.id
	GROUP BY nom
	ORDER BY nbr DESC
	LIMIT 1
)
SELECT nom
FROM NombreDeTarifsDifférentsParHôtel;

/*Requête 6*/
/*Clients ayant réservés la même chambre > 1*/
WITH ClientsAyantRéservésLaMêmeChambre AS (
	SELECT Client.id AS idClient, Client.nom AS nom, Client.prénom AS prénom, Hôtel.nom AS hôtel,
		   Chambre.numéro AS numéroChambre, COUNT(*) AS nbrRéservations
	FROM Client
		INNER JOIN Réservation ON Réservation.idClient = Client.id
		INNER JOIN Chambre ON Chambre.idhôtel = Réservation.idchambre
				   AND Chambre.numéro = Réservation.numéroChambre
	   	INNER JOIN Hôtel ON Hôtel.id = Chambre.idhôtel 
	GROUP BY Client.id, Hôtel.Nom, Chambre.Numéro
)
SELECT idClient, nom, prénom, hôtel, numéroChambre
FROM ClientsAyantRéservésLaMêmeChambre
WHERE ClientsAyantRéservésLaMêmeChambre.nbrRéservations > 1;

/*Requête 7*/
/*Membre Kurz Alpinhotel sans réservation*/
SELECT Client.id, Client.nom, prénom
FROM Client
	INNER JOIN Membre ON Membre.idclient = Client.id
	INNER JOIN Hôtel ON Hôtel.id = Membre.idhôtel
WHERE Hôtel.nom = 'Kurz Alpinhotel'
EXCEPT
SELECT Client.id, Client.nom, prénom FROM Client
	INNER JOIN Membre ON Membre.idclient = Client.id
	INNER JOIN Hôtel ON Hôtel.id = Membre.idhôtel
	INNER JOIN Réservation ON Réservation.idclient = Client.id AND Réservation.idChambre = Hôtel.id 
WHERE Hôtel.nom = 'Kurz Alpinhotel' AND Réservation.dateRéservation >= Membre.depuis
GROUP BY Client.id;

/*test : Membres de Kurz Alpinhotel et leurs date de réservations dans l'hôtel Kurz Alpinhotel
 * (peut-être null s'ils n'en n'ont pas)*/
SELECT Client.id, Client.nom, Client.prénom, Membre.depuis , Réservation.dateRéservation
FROM Client 
	INNER JOIN Membre ON Membre.idClient = Client.id
	INNER JOIN Hôtel ON Hôtel.id = Membre.idHôtel
	LEFT JOIN Réservation ON Réservation.idClient = Client.id AND Réservation.idChambre = Hôtel.id
WHERE Hôtel.nom = 'Kurz Alpinhotel';

/*test : Ajout d'un membre ayant une réservation à l'hôtel avant de s'y être inscrit*/
INSERT INTO Client VALUES (11, 1, 'Fernandez', 'Loic');
INSERT INTO Réservation (idClient, idChambre, numéroChambre, dateArrivée, dateRéservation, nbNuits, nbPersonnes) VALUES (11, 4, 17, '2019-02-22', '2019-02-22', 2, 1);
INSERT INTO Réservation (idClient, idChambre, numéroChambre, dateArrivée, dateRéservation, nbNuits, nbPersonnes) VALUES (11, 4, 17, '2018-02-22', '2018-02-22', 2, 1);
INSERT INTO Membre (idClient, idHôtel, depuis) VALUES (11, 4, '2020-05-18');
DELETE FROM Membre WHERE idClient = 11;
DELETE FROM Réservation WHERE idclient = 11;
DELETE FROM Client WHERE id = 11;


/*Requête 8*/
/*Ville décroissant capacité d'accueil*/
SELECT Ville.nom, SUM(Chambre_Equipement.quantité) AS capacité
FROM Chambre_Equipement
	INNER JOIN Hôtel ON Hôtel.id = Chambre_Equipement.idChambre
	INNER JOIN Ville ON Ville.id = Hôtel.idVille
WHERE Chambre_Equipement.nomEquipement LIKE 'Lit%'
GROUP BY Ville.nom
ORDER BY capacité DESC;


/*Requête 9*/
/*Ville avec le plus de réservations*/
SELECT Ville.nom, SUM(Hôtel.id) AS nbrRéservations
FROM Réservation
	INNER JOIN Hôtel ON Hôtel.id = Réservation.idChambre
	INNER JOIN Ville ON Ville.id = Hôtel.idVille
GROUP BY Ville.nom
ORDER BY nbrRéservations DESC;


/*Requête 10*/
/*Chambres réservées pour le 24 décembre de l'année (2021)*/
SELECT DISTINCT Hôtel.nom, Chambre.numéro/*, Réservation.dateRéservation, Réservation.nbNuits*/
FROM Chambre
	INNER JOIN Hôtel ON Hôtel.id = Chambre.idHôtel
	INNER JOIN Réservation ON Réservation.idChambre = Chambre.idhôtel 
			   AND Réservation.numéroChambre = Chambre.numéro
WHERE Réservation.dateRéservation = '2021-12-24' OR
	('2021-12-24' > Réservation.dateRéservation AND
	 '2021-12-24' < Réservation.dateRéservation + Réservation.nbNuits);

/*test : Ajout d'un membre avec des réservations autour de la nuit du 24 décembre 2021*/
INSERT INTO Client VALUES (11, 1, 'Fernandez', 'Loic');
INSERT INTO Réservation (idClient, idChambre, numéroChambre, dateArrivée, dateRéservation, nbNuits, nbPersonnes) VALUES (11, 4, 17, '2021-12-24', '2021-12-24', 2, 1);
INSERT INTO Réservation (idClient, idChambre, numéroChambre, dateArrivée, dateRéservation, nbNuits, nbPersonnes) VALUES (11, 4, 17, '2021-12-22', '2021-12-22', 2, 1);
INSERT INTO Réservation (idClient, idChambre, numéroChambre, dateArrivée, dateRéservation, nbNuits, nbPersonnes) VALUES (11, 4, 17, '2021-12-21', '2021-12-21', 4, 1);
INSERT INTO Réservation (idClient, idChambre, numéroChambre, dateArrivée, dateRéservation, nbNuits, nbPersonnes) VALUES (11, 4, 17, '2021-12-23', '2021-12-23', 3, 1);
DELETE FROM Réservation WHERE idclient = 11;
DELETE FROM Client WHERE id = 11;


/*Requête 11*/
/*Les réservations faites dans des chambres qui ont un nombre de lits supérieur au nombre de personnes de la réservation.*/
SELECT Client.id, Client.nom, Client.prénom, Hôtel.nom AS hôtel, Chambre.numéro AS "no. chambre", Réservation.dateArrivée,
	   Réservation.dateRéservation, Réservation.nbNuits, Réservation.nbPersonnes/*, Chambre_Equipement.nomEquipement, Chambre_Equipement.quantité*/
FROM Réservation
	INNER JOIN Client ON Client.id = Réservation.idClient
	INNER JOIN Chambre ON Chambre.idHôtel = Réservation.idChambre AND Chambre.numéro = Réservation.numéroChambre
	INNER JOIN Hôtel ON Hôtel.id = Chambre.idhôtel
	INNER JOIN Chambre_Equipement ON Chambre_Equipement.idChambre = Chambre.idHôtel AND Chambre_Equipement.numéroChambre = Chambre.numéro
WHERE Chambre_Equipement.nomEquipement LIKE 'Lit%' AND Chambre_Equipement.quantité > Réservation.nbPersonnes;

/*Requête 12*/
/*Les hôtels dont pas toutes les chambres sont équipées d'une TV. N'utiliser ni EXCEPT, ni INTERSECT.*/
WITH ChambresParHôtel AS (
	SELECT idHôtel, COUNT(numéro) AS nbrChambres
	FROM Chambre
	GROUP BY idHôtel
),
/*Ici on considère comme dans le modèle EA, qu'une chambre a forcément un équipement*/
/*On considère aussi que l'équipement TV n'apparaît qu'une seule fois dans la table Equipement*/
ChambresParHôtelAvecTV AS (
	SELECT idChambre AS idHôtel, COUNT(numéroChambre) AS nbrChambres
	FROM Chambre_Equipement
	WHERE nomEquipement LIKE 'TV'
	GROUP BY idChambre
)
SELECT Hôtel.nom
FROM Hôtel
	INNER JOIN ChambresParHôtel ON ChambresParHôtel.idHôtel = Hôtel.id
	INNER JOIN ChambresParHôtelAvecTV ON ChambresParHôtelAvecTV.idHôtel = Hôtel.id
WHERE ChambresParHôtel.nbrChambres != ChambresParHôtelAvecTV.nbrChambres;

/*Requête 13*/
/*Les chambres à Lausanne ayant au moins une TV et un lit à 2 places*/
/*Réecriture des équipements en 1 string*/
WITH ChambreAvecEquipements AS (
	SELECT Hôtel.nom, Chambre.numéro, STRING_AGG(Chambre_Equipement.nomEquipement, ' ') AS equipements
	FROM Chambre
		INNER JOIN Hôtel ON Hôtel.id = Chambre.idHôtel
		INNER JOIN Ville ON Ville.id = Hôtel.id
		INNER JOIN Chambre_Equipement ON Chambre_Equipement.idChambre = Chambre.idHôtel AND Chambre_Equipement.numéroChambre = Chambre.numéro
	GROUP BY Hôtel.nom, Chambre.numéro
),
/*Récupération des chambres ayant un lit à 2 places et une TV*/
ChambreAyantAuMoinsUneTVEtUnLitàDeuxPlaces AS (
	SELECT nom, numéro, COUNT(numéro)
	FROM ChambreAvecEquipements
	WHERE equipements SIMILAR TO '%(King|Queen)%' AND equipements LIKE '%TV%'
	GROUP BY nom, numéro
)
SELECT nom, numéro
FROM ChambreAyantAuMoinsUneTVEtUnLitàDeuxPlaces;


/*Requête 14*/
/*Pour l'hôtel "Hôtel Royal", lister toutes les réservations en indiquant de combien de jours
elles ont été faites à l'avance (avant la date d'arrivée) ainsi que si la réservation a été faite
en tant que membre de l'hôtel. Trier les résultats par ordre des réservations (en 1er celles
faites le plus à l’avance), puis par clients (ordre croissant du nom puis du prénom).*/
SELECT datearrivée - dateréservation AS joursEnAvance, CAST(Membre.idClient AS BOOLEAN) AS "est membre",
	   Client.id, Client.nom, Client.prénom, Hôtel.nom AS Hôtel, Chambre.numéro AS "no. chambre",
	   Réservation.dateArrivée, Réservation.dateRéservation, Réservation.nbNuits, Réservation.nbPersonnes
FROM Réservation
	INNER JOIN Client ON Client.id = Réservation.idClient
	INNER JOIN Chambre ON Chambre.idHôtel = Réservation.idChambre AND Chambre.numéro = Réservation.numéroChambre
	INNER JOIN Hôtel ON Hôtel.id = Chambre.idHôtel
	LEFT JOIN Membre ON Membre.idClient = Client.id AND Membre.idhôtel = Hôtel.id
WHERE Hôtel.nom = 'Hôtel Royal'
ORDER BY joursEnAvance, Client.nom, Client.prénom;



