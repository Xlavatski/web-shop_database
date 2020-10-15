--UPITI
--upit vraca koliko je ukupan iznos svake pojedine narudzbe
SELECT KUPCI.IME_KUPCA, NARUDZBE.DATUMNAR, DETALJINAR.IDNARUDZBA, PROIZVODI.NAZIV, DETALJINAR.KOLICINA * PROIZVODI.CIJENA 
AS UKUPAN_IZNOS_SVAKE_POJEDINE_NARUDZBE 
FROM DETALJINAR, PROIZVODI, KUPCI, NARUDZBE
WHERE PROIZVODI.IDProizvod = DETALJINAR.IDProizvod AND KUPCI.idKupac = NARUDZBE.idKupac and NARUDZBE.idNarudzba = DETALJINAR.idNarudzba
ORDER BY DETALJINAR.IDNARUDZBA;

--upit koji vraća koliko je koji kupac napravio narudzbi

SELECT KUPCI.ime_kupca, COUNT(*) as broj_narudzbi
FROM NARUDZBE, KUPCI WHERE KUPCI.idKupac = NARUDZBE.idKupac
GROUP BY KUPCI.ime_kupca
ORDER BY broj_narudzbi DESC;

--upit koji vraća koliko je koji kupac potrošio

SELECT k.ime_kupca, SUM(d.kolicina * p.cijena) as koliko_je_koji_kupac_potrosio 
FROM KUPCI k, NARUDZBE n, DETALJINAR d, PROIZVODI p
WHERE k.idKupac = n.idKupac AND n.idNarudzba = d.idNarudzba AND d.idProizvod = p.idProizvod
GROUP BY k.ime_kupca
ORDER BY koliko_je_koji_kupac_potrosio DESC;

--verzija sa inner joinom

SELECT KUPCI.ime_kupca, SUM(DETALJINAR.kolicina * PROIZVODI.cijena) as koliko_je_kupac_trosio
FROM KUPCI 
INNER JOIN NARUDZBE ON KUPCI.idKupac = NARUDZBE.idKupac
INNER JOIN DETALJINAR ON NARUDZBE.idNarudzba = DETALJINAR.idNarudzba
INNER JOIN PROIZVODI ON DETALJINAR.idProizvod = PROIZVODI.idProizvod
GROUP BY KUPCI.ime_kupca
ORDER BY koliko_je_kupac_trosio DESC;

--upit koji vraća koji proizvod je prodan koliko puta

SELECT p.naziv,  SUM(d.kolicina) AS broj_prodanih_proizvoda
FROM PROIZVODI p NATURAL JOIN DETALJINAR d
GROUP BY p.naziv;

--upit koji vraća koji je dobavljac koliko zaradio

SELECT d.ime_dobavljaca, SUM(p.cijena * dn.kolicina) AS UKUPNA_ZARADA
FROM DOBAVLJACI d, PROIZVODI p, DETALJINAR dn
WHERE d.idDobavljac = p.idDobavljac AND p.idProizvod = dn.idProizvod
GROUP BY d.ime_dobavljaca
ORDER BY UKUPNA_ZARADA DESC;
--inner join 
SELECT d.ime_dobavljaca, SUM(p.cijena * dn.kolicina) AS UKUPNA_ZARADA
FROM DOBAVLJACI d
INNER JOIN PROIZVODI p ON d.idDobavljac = p.idDobavljac
INNER JOIN DETALJINAR dn ON p.idProizvod = dn.idProizvod
GROUP BY d.ime_dobavljaca;


--PODUPITI(select) #######################

SELECT naziv, cijena, (SELECT AVG(cijena) FROM PROIZVODI) AS PROSJEK,
    cijena - (SELECT AVG(cijena) FROM PROIZVODI) AS RAZLIKA
FROM PROIZVODI;

--dva različita načina:
SELECT ime_dobavljaca, (SELECT COUNT(*) FROM PROIZVODI
WHERE DOBAVLJACI.idDobavljac = PROIZVODI.idDobavljac) AS BROJ_PROIZVODA
FROM DOBAVLJACI
ORDER BY BROJ_PROIZVODA DESC
FETCH NEXT 1 ROWS ONLY;

SELECT DOBAVLJACI.ime_dobavljaca, count(PROIZVODI.idProizvod) as broj_proizvoda
FROM DOBAVLJACI, PROIZVODI WHERE DOBAVLJACI.idDobavljac = PROIZVODI.idDobavljac
GROUP BY DOBAVLJACI.ime_dobavljaca
ORDER BY broj_proizvoda DESC
FETCH NEXT 1 ROWS ONLY;

--PODUPITI(from)

SELECT naziv, cijena, (SELECT AVG(CIJENA) FROM PROIZVODI ) as prosjek 
FROM (SELECT idProizvod, naziv, cijena FROM PROIZVODI);

--primjer 2 (isto rješenje, dva različita načina)

SELECT ime_dobavljaca FROM (
        SELECT dobavljaci.ime_dobavljaca, count(PROIZVODI.idProizvod) AS broj FROM dobavljaci, proizvodi
        WHERE dobavljaci.idDobavljac = proizvodi.idDobavljac
        GROUP BY dobavljaci.ime_dobavljaca ORDER BY broj DESC
	);
        
SELECT DOBAVLJACI.ime_dobavljaca, COUNT(PROIZVODI.naziv) AS BROJ  FROM dobavljaci, proizvodi
WHERE DOBAVLJACI.idDobavljac = PROIZVODI.idDobavljac
GROUP BY DOBAVLJACI.ime_dobavljaca
ORDER BY BROJ DESC;

--PODUPITI (where)

SELECT naziv FROM (
    SELECT naziv, cijena
    FROM PROIZVODI
    WHERE cijena = (SELECT MAX(cijena) FROM PROIZVODI)
   );

--primjer 2 (upit vraca sve proizvode koji koštaju iznad prosječne cijene)

SELECT naziv, cijena 
FROM PROIZVODI WHERE cijena > (SELECT AVG(cijena) FROM PROIZVODI);

--primjer 3 (upit vraca najvecu cijenu proizvoda određenog dobavljaca)

SELECT ime_dobavljaca, naziv, cijena FROM PROIZVODI, DOBAVLJACI 
WHERE PROIZVODI.idDobavljac = DOBAVLJACI.idDobavljac 
        AND cijena = (SELECT max(cijena) FROM (    
        SELECT d1.ime_dobavljaca, p1.naziv, P1.cijena
        FROM PROIZVODI p1, DOBAVLJACI d1 
        WHERE p1.idDobavljac = d1.idDobavljac AND d1.ime_dobavljaca = 'HP')
    );

--podupiti koji vracaju vrijednost (IN)

SELECT ime_kupca FROM KUPCI
WHERE idKupac IN (SELECT DISTINCT idKupac FROM NARUDZBE);

SELECT ime_kupca FROM KUPCI
WHERE idKupac NOT IN (SELECT DISTINCT idKupac FROM NARUDZBE 
WHERE idkupac IS NOT NULL);

--podupit vraca koliko je proizvoda prodano na određeni dan

SELECT datumNar, SUM(kolicina) AS KOL, (SELECT AVG(SUM(kolicina))
FROM NARUDZBE, DETALJINAR
WHERE NARUDZBE.idNarudzba = DETALJINAR.idNarudzba
GROUP BY datumNar) AS PROSIJEK
FROM NARUDZBE, DETALJINAR
WHERE NARUDZBE.idNarudzba = DETALJINAR.idNarudzba
GROUP BY datumNar
ORDER BY KOL DESC
FETCH NEXT 5 ROWS ONLY;
