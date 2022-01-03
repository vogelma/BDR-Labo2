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
WHERE Hôtel.nom = 'Kurz Alpinhotel'

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

/*Requête 9*/
/*Ville avec le plus de réservations*/
