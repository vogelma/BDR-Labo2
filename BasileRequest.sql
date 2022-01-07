/*1:*/
SELECT DISTINCT Client.id, Client.nom, Client.prénom
FROM Client
	INNER JOIN Réservation ON Client.id = Réservation.idClient
	INNER JOIN Hôtel ON Réservation.idChambre = Hôtel.id
WHERE Client.idVille = Hôtel.idVille;

/*2:*/
SELECT MIN(Chambre.prixParNuit), MAX(Chambre.prixParNuit)
FROM Chambre
	INNER JOIN Hôtel ON Chambre.idHôtel = Hôtel.id
	INNER JOIN Ville ON Hôtel.idVille = Ville.id
WHERE Ville.nom = 'Interlaken';

/*3:*/
SELECT AVG(Chambre.prixParNuit) AS prixMoyen, Chambre.étage
FROM Chambre
	INNER JOIN Hôtel ON chambre.idHôtel = Hôtel.id
WHERE Hôtel.nom = 'JungFrau Petrus Palace'
GROUP BY Chambre.étage
ORDER BY prixMoyen;

/*4:*/
SELECT Hôtel.nom
FROM Hôtel
	INNER JOIN Chambre ON Chambre.idHôtel = Hôtel.id
	INNER JOIN Chambre_Equipement ON Chambre.idHôtel = Chambre_Equipement.idChambre AND Chambre.numéro = Chambre_Equipement.numéroChambre
WHERE Chambre_Equipement.nomEquipement = 'Baignoire' AND Chambre_Equipement.quantité > 1;

/*5:*/
SELECT Hôtel.nom
FROM Hôtel
	INNER JOIN Chambre ON Chambre.idHôtel = Hôtel.id
GROUP BY Hôtel.nom
ORDER BY COUNT(DISTINCT Chambre.prixParNuit) DESC
LIMIT 1;

/*6:*/
SELECT Client.id, Client.nom, Client.prénom, Hôtel.nom AS nomHôtel, Réservation.numéroChambre
FROM Client
	INNER JOIN Réservation ON Réservation.idClient = Client.id
	INNER JOIN Hôtel ON Hôtel.id = Réservation.idChambre
GROUP BY Client.id, Hôtel.id, Réservation.numéroChambre
HAVING COUNT(*) > 1;

/*7:*/
SELECT Client.id, Client.nom, Client.prénom
FROM Client
	INNER JOIN Membre ON Membre.idClient = Client.id
	INNER JOIN Hôtel ON Membre.idHôtel = Hôtel.id
WHERE Hôtel.nom = 'Kurz Alpinhotel'
EXCEPT
SELECT Client.id, Client.nom, Client.prénom
FROM client
	INNER JOIN Réservation ON Réservation.idClient = Client.id
	INNER JOIN Hôtel ON Réservation.idChambre = Hôtel.id
	INNER JOIN Membre ON Membre.idClient = Client.id
WHERE Hôtel.nom = 'Kurz Alpinhotel'  AND Réservation.dateRéservation >= Membre.depuis;

/*8:*/
SELECT Ville.nom
FROM Ville
	INNER JOIN Hôtel ON Hôtel.idVille = Ville.id
	INNER JOIN Chambre_Equipement ON Chambre_Equipement.idChambre = Hôtel.id
	INNER JOIN Lit ON Lit.nomEquipement = Chambre_Equipement.nomEquipement
GROUP BY Ville.nom
ORDER BY SUM(Lit.nbPlaces * Chambre_Equipement.quantité) DESC;

/*9:*/
SELECT Ville.nom
FROM Ville
	INNER JOIN Hôtel ON Hôtel.idVille = Ville.id
	INNER JOIN Réservation ON Réservation.idChambre = Hôtel.id
GROUP BY Ville.nom
HAVING COUNT(*) >= ALL (SELECT COUNT(*)
				FROM Ville
					INNER JOIN Hôtel ON Hôtel.idVille = Ville.id
					INNER JOIN Réservation ON Réservation.idChambre = Hôtel.id
					GROUP BY Ville.nom);


/*10:*/
SELECT Hôtel.nom, Chambre.numéro
FROM Chambre
	INNER JOIN Hôtel ON Hôtel.id = Chambre.idhôtel
	INNER JOIN Réservation ON Réservation.idChambre = Chambre.idHôtel AND Réservation.numéroChambre = Chambre.numéro
WHERE Réservation.dateArrivée = '2021-12-24' OR
	('2021-12-24' > Réservation.dateRéservation AND
	 '2021-12-24' < Réservation.dateRéservation + Réservation.nbNuits);


/*11:*/
SELECT Client.id, Client.nom, Client.prénom, Hôtel.nom AS nomHôtel, Chambre.numéro AS numéroChambre,
			to_char(Réservation.dateArrivée, 'DD.MM.YYYY'), to_char(Réservation.dateRéservation, 'DD.MM.YYYY'), Réservation.nbNuits, Réservation.nbPersonnes
FROM Réservation
	INNER JOIN Client ON Client.id = Réservation.idClient
	INNER JOIN Chambre ON Chambre.idHôtel = Réservation.idChambre AND Chambre.numéro = Réservation.numéroChambre
	INNER JOIN Hôtel ON Hôtel.id = Chambre.idHôtel
	INNER JOIN Chambre_Equipement ON Chambre_Equipement.idChambre = Chambre.idHôtel AND Chambre_Equipement.numéroChambre = Chambre.numéro
	INNER JOIN Lit ON Lit.nomEquipement = Chambre_Equipement.nomEquipement
WHERE Chambre_Equipement.quantité > Réservation.nbPersonnes;


/*12:*/
SELECT Hôtel.nom
FROM Hôtel
	INNER JOIN Chambre ON Chambre.idHôtel = Hôtel.id
GROUP BY Hôtel.id
HAVING COUNT(*) > (SELECT COUNT(*)
			FROM Chambre
				INNER JOIN Chambre_Equipement ON Chambre_Equipement.numéroChambre = Chambre.numéro AND Chambre_Equipement.idChambre = Chambre.idHôtel
			WHERE Chambre_Equipement.nomEquipement = 'TV' AND Chambre.idHôtel = Hôtel.id);


/*13:*/
SELECT DISTINCT Hôtel.nom, Chambre.numéro
FROM Chambre
	INNER JOIN Hôtel ON Hôtel.id = Chambre.idhôtel
	INNER JOIN Ville ON Ville.id = Hôtel.id
	INNER JOIN Chambre_Equipement ON Chambre_Equipement.idChambre = Chambre.idHôtel AND Chambre_Equipement.numéroChambre = Chambre.numéro
	INNER JOIN Lit ON Lit.nomEquipement = Chambre_Equipement.nomEquipement
WHERE Ville.nom = 'Lausanne' AND Lit.nbPlaces = 2
INTERSECT
SELECT DISTINCT Hôtel.nom, Chambre.numéro
FROM Chambre
	INNER JOIN Hôtel ON Hôtel.id = Chambre.idhôtel
	INNER JOIN Ville ON Ville.id = Hôtel.id
	INNER JOIN Chambre_Equipement ON Chambre_Equipement.idChambre = Chambre.idHôtel AND Chambre_Equipement.numéroChambre = Chambre.numéro
WHERE Ville.nom = 'Lausanne' AND Chambre_Equipement.nomEquipement = 'TV';


/*14:*/
SELECT Client.id, Client.nom, Client.prénom, Hôtel.nom AS nomHôtel, Chambre.numéro AS numéroChambre,
	   to_char(Réservation.dateArrivée, 'DD.MM.YYYY'), to_char(Réservation.dateRéservation, 'DD.MM.YYYY'),
	   Réservation.nbNuits, Réservation.nbPersonnes,
	   (Réservation.dateArrivée - Réservation.dateRéservation) AS joursDAvance, Membre.idClient IS NOT NULL AS estMembre
FROM Réservation
	INNER JOIN Client ON Client.id = Réservation.idClient
	INNER JOIN Chambre ON Chambre.idHôtel = Réservation.idChambre AND Chambre.numéro = Réservation.numéroChambre
	INNER JOIN Hôtel ON Hôtel.id = chambre.idHôtel
	LEFT OUTER JOIN Membre ON Membre.idClient = Client.id AND Membre.idHôtel = Hôtel.id
WHERE Hôtel.nom = 'Hôtel Royal'
ORDER BY joursDAvance DESC, Client.nom, Client.prénom;


/*15:*/
SELECT (SUM(Réservation.nbNuits * Chambre.prixParNuit) - SUM(
	CASE WHEN (Membre.idClient IS NOT NULL AND Réservation.dateRéservation > Membre.depuis)
	THEN Réservation.nbNuits * Chambre.prixParNuit * Hôtel.rabaisMembre * 0.01
	ELSE 0 END) ) AS prixTotal
FROM Réservation
	INNER JOIN Chambre ON Chambre.idHôtel = Réservation.idChambre AND Chambre.numéro = Réservation.numéroChambre
	INNER JOIN Hôtel ON Hôtel.id = Chambre.idHôtel
	LEFT OUTER JOIN Membre ON Membre.idClient = Réservation.idClient AND Membre.idHôtel = Hôtel.id
WHERE Hôtel.nom = 'Hôtel Royal';
