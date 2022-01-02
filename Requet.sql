/*Select des tables*/
SELECT id, nom, prénom FROM Client;

SELECT id, nom prénom FROM Membre INNER JOIN Client ON Client.id = Membre.idClient;


/*Affichage hôtel dans ville*/
SELECT Hôtel.nom, Ville.nom FROM Hôtel INNER JOIN Ville ON Ville.id = Hôtel.idVille

/*Requête 1*/
/*Client avec reservation où hôtel = ville*/
 SELECT DISTINCT Client.id, Client.nom, prénom FROM Client
 INNER JOIN Membre ON Client.id = Membre.idClient
 INNER JOIN Hôtel ON Membre.idHôtel = Hôtel.id
 WHERE Hôtel.idVille = Client.idVille
 
 /*Requête 2*/
 /*prix min. prix.max pour nuit interlaken*/
 SELECT MIN(prixParNuit), MAX(prixParNuit) FROM Chambre
 INNER JOIN Hôtel ON Hôtel.id = Chambre.idHôtel
 INNER JOIN Ville ON Ville.id = Hôtel.idVille
 WHERE Ville.nom = 'Interlaken'
 
 
 
 /*Requête 3*/
 /*prix moyen par étage ordonné par ordre croissant*/
SELECT AVG(prixParNuit) AS moyenne, étage FROM Chambre
INNER JOIN Hôtel ON Hôtel.id = Chambre.idHôtel
WHERE nom = 'JungFrau Petrus Palace'
GROUP BY étage
ORDER BY moyenne
 
 
 /*Requête 4*/
 /*hôtel avec chambre qui a baignoire > 1*/
SELECT Hôtel.nom FROM Hôtel
INNER JOIN Chambre ON Chambre.idHôtel = Hôtel.id
INNER JOIN Chambre_Equipement ON Chambre_Equipement.idChambre = Chambre.idHôtel AND Chambre_Equipement.numéroChambre = Chambre.numéro
WHERE Chambre_Equipement.nomEquipement = 'Baignoire' AND quantité > 1
 
 
 /*Requête 5*/
 /*hôtel avec le plus de tarif*/
 SELECT nom AS nomHôtel, COUNT(DISTINCT prixParNuit) AS differentTarif FROM Hôtel
 INNER JOIN Chambre ON Chambre.idHôtel = Hôtel.id
 GROUP BY Hôtel.nom
 ORDER BY differentTarif DESC
 LIMIT 1
 
  /*Requête 6*/
  /*client réserve la même chambre > 1*/
 SELECT Client.id, Client.nom, prénom, Hôtel.nom, Réservation.numéroChambre FROM Client
 INNER JOIN Réservation ON Réservation.idClient = Client.id
 INNER JOIN Hôtel ON Hôtel.id = Réservation.idChambre 
 GROUP BY Client.id, Hôtel.id, Réservation.idChambre, Réservation.numéroChambre 
 HAVING COUNT(dateArrivée) > 1
 
 
 /*Requête 7*/
 /*membre Kurz Alpinhotel sans réservation*/
 SELECT Client.id, Client.nom, prénom FROM Client
INNER JOIN Membre ON Membre.idclient = Client.id
INNER JOIN Hôtel ON Hôtel.id = Membre.idhôtel
WHERE Hôtel.nom = 'Kurz Alpinhotel'
EXCEPT
SELECT DISTINCT Client.id, Client.nom, prénom FROM Client
INNER JOIN Réservation ON Réservation.idclient = Client.id
INNER JOIN Hôtel ON Hôtel.id = Réservation.idChambre
WHERE Hôtel.nom = 'Kurz Alpinhotel'

/*Requête 8*/
/*ville décroissant capacité d'accueil*/
SELECT Ville.id, Ville.nom, SUM(nbPlaces * quantité) AS place FROM Ville
INNER JOIN Hôtel ON Hôtel.idville = Ville.id
INNER JOIN Chambre ON Chambre.idhôtel = Hôtel.id
INNER JOIN Chambre_Equipement ON Chambre_Equipement.idchambre = Chambre.idhôtel
AND Chambre_Equipement.numérochambre = Chambre.numéro 
INNER JOIN Lit ON Lit.nomequipement = Chambre_Equipement.nomEquipement
GROUP BY Ville.id
ORDER BY place DESC

/*Requête 9*/
/*ville avec le plus de réservations*/
 SELECT Ville.id, Ville.nom, COUNT(Réservation.idClient) FROM Ville
INNER JOIN Hôtel ON Hôtel.idville = Ville.id
INNER JOIN Chambre ON Chambre.idhôtel = Hôtel.id
INNER JOIN Réservation ON Réservation.idchambre = Hôtel.id AND Réservation.numérochambre = Chambre.numéro
GROUP BY Ville.id
  