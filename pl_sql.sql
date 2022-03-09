DECLARE  
    b_id Bezveze.bzvID%type := 1;  
    b_placa Bezveze.Placa%type;  
BEGIN  
    SELECT Placa   
    INTO b_placa  
    FROM Bezveze   
    WHERE bzvID = b_id;  
      
    IF (b_placa >= 2000) THEN  
        UPDATE Bezveze  
        SET Placa = Placa + 3000  
        WHERE bzvID = b_id;  
        dbms_output.put_line ('Placa azurirana');   
   END IF;   
END;


--PROJEKT
INSERT INTO KUPCI VALUES (1, 'Dino Glavaš', 'Bjelovar');
INSERT INTO KUPCI VALUES (2, 'Ivo Ivic', 'Zagreb');
INSERT INTO KUPCI VALUES (3, 'Ljiljana Lukić', 'Vukovar');
INSERT INTO KUPCI VALUES (4, 'Marija Horvat', 'Bjelovar');
INSERT INTO KUPCI VALUES (5, 'Ratko Rat', 'Zagreb');
INSERT INTO KUPCI VALUES (6, 'Katarina Velika', 'Split');
INSERT INTO KUPCI VALUES (7, 'Marko Marić', 'Zadar');
INSERT INTO KUPCI VALUES (8, 'Veronika Zuzulova', 'Križevci');
INSERT INTO KUPCI VALUES (9, 'Stjepan Štef', 'Bjelovar');


INSERT INTO NARUDZBE VALUES (101, date '2020-01-14', 2);
INSERT INTO NARUDZBE VALUES (102, date '2020-02-04', 1);
INSERT INTO NARUDZBE VALUES (103, date '2020-01-14', 3);
INSERT INTO NARUDZBE VALUES (104, date '2020-02-10', 1);
INSERT INTO NARUDZBE VALUES (105, date '2020-02-13', 4);
INSERT INTO NARUDZBE VALUES (106, date '2020-02-17', 1);
INSERT INTO NARUDZBE VALUES (107, date '2020-02-25', 4);
INSERT INTO NARUDZBE VALUES (108, date '2020-02-27', 5);
INSERT INTO NARUDZBE VALUES (109, date '2020-03-02', 6);
INSERT INTO NARUDZBE VALUES (110, date '2020-03-04', 1);
INSERT INTO NARUDZBE VALUES (111, date '2020-03-14', 6);
INSERT INTO NARUDZBE VALUES (112, date '2020-03-15', 1);
INSERT INTO NARUDZBE VALUES (113, date '2020-03-18', 9);
INSERT INTO NARUDZBE VALUES (114, date '2020-03-24', 1);


INSERT INTO DOBAVLJACI VALUES (1, 'Acer');
INSERT INTO DOBAVLJACI VALUES (2, 'Asus');
INSERT INTO DOBAVLJACI VALUES (3, 'HP');
INSERT INTO DOBAVLJACI VALUES (4, 'Lenovo');

INSERT INTO PROIZVODI VALUES (1, 'Notebook Acer Aspire 3', 4629.46, 1 );
INSERT INTO PROIZVODI VALUES (2, 'Notebook Acer Gaming Nitro 5', 6199, 1 );
INSERT INTO PROIZVODI VALUES (3, 'Notebook Asus X509FA-WB511T', 4899, 2 );
INSERT INTO PROIZVODI VALUES (4, 'Notebook HP 250 G7, 6HL16EA', 5030, 3 );
INSERT INTO PROIZVODI VALUES (5, 'Notebook HP Pavilion Gaming 15-ec0014nm', 5605, 3 );
INSERT INTO PROIZVODI VALUES (6, 'Notebook HP ProBook 450 G6, 15.6" FHD IPS', 6868.65, 3 );
INSERT INTO PROIZVODI VALUES (7, 'Notebook Lenovo ThinkPad E595', 4294, 4 );
INSERT INTO PROIZVODI VALUES (8, 'Notebook Lenovo Gaming Legion Y540', 8264.05, 4 );


INSERT INTO DETALJINAR VALUES (1, 5, 102, 4);
INSERT INTO DETALJINAR VALUES (2, 15, 102, 7);
INSERT INTO DETALJINAR VALUES (3, 2, 102, 8);
INSERT INTO DETALJINAR VALUES (4, 10, 101, 2);
INSERT INTO DETALJINAR VALUES (5, 1, 103, 1);

INSERT INTO DETALJINAR VALUES (6, 5, 104, 3);
INSERT INTO DETALJINAR VALUES (7, 4, 105, 5);
INSERT INTO DETALJINAR VALUES (8, 2, 105, 6);
INSERT INTO DETALJINAR VALUES (9, 10, 106, 2);
INSERT INTO DETALJINAR VALUES (10, 1, 107, 1);

INSERT INTO DETALJINAR VALUES (11, 5, 108, 3);
INSERT INTO DETALJINAR VALUES (12, 4, 109, 5);
INSERT INTO DETALJINAR VALUES (13, 2, 109, 6);
INSERT INTO DETALJINAR VALUES (14, 10, 110, 2);
INSERT INTO DETALJINAR VALUES (15, 1, 111, 1);

INSERT INTO DETALJINAR VALUES (16, 5, 112, 7);
INSERT INTO DETALJINAR VALUES (17, 4, 113, 5);
INSERT INTO DETALJINAR VALUES (18, 2, 113, 8);
INSERT INTO DETALJINAR VALUES (19, 10, 113, 4);
INSERT INTO DETALJINAR VALUES (20, 1, 114, 1);



create table KUPCI (
    idKupac number,
    ime_kupca varchar2(200),
    grad varchar2(200),
    constraint pk_kupac primary key (idKupac)
);

create table NARUDZBE (
    idNarudzba number,
    datumNar date,
    idKupac number,
    constraint pk_narudzba primary key (idNarudzba),
    constraint fk_kupac foreign key (idKupac)
    references KUPCI (idKupac)
);

create table DETALJINAR (
    idDetalji number,
    kolicina number,
    idNarudzba number,
    idProizvod number,
    constraint pk_detalji primary key (idDetalji),
    constraint fk_narudzba foreign key (idNarudzba)
    references NARUDZBE(idNarudzba),
    constraint fk_proizvod foreign key (idProizvod)
    references PROIZVODI(idProizvod)
);

create table PROIZVODI (
    idProizvod number,
    naziv varchar2(200),
    cijena number,
    idDobavljac number,
    constraint pk_proizvod primary key (idProizvod),
    constraint fk_dobavljac foreign key (idDobavljac)
    references DOBAVLJACI(idDobavljac)
);

create table DOBAVLJACI (
    idDobavljac number,
    ime_dobavljaca varchar2(200),
    constraint pk_dobavljac primary key (idDobavljac)
);


--TRIGGERI

CREATE OR REPLACE TRIGGER s_revizija
    BEFORE INSERT OR DELETE OR UPDATE ON KUPCI
    FOR EACH ROW 
    ENABLE
DECLARE
    v_korisnik VARCHAR2(30); 
    v_datum VARCHAR2(30); 
BEGIN
    SELECT user, TO_CHAR(SYSDATE, 'DD/MON/YYYY HH24:MI:SS') INTO v_korisnik, v_datum FROM dual;
    IF INSERTING THEN
        INSERT INTO revizija (novo_ime_kupca, staro_ime_kupca, novi_grad, stari_grad, korisnik, datum_unosa, operacija)
        VALUES (:NEW.ime_kupca, NULL, :NEW.grad, NULL, v_korisnik, v_datum, 'Insert');
    ELSIF DELETING THEN
        INSERT INTO revizija (novo_ime_kupca, staro_ime_kupca, novi_grad, stari_grad, korisnik, datum_unosa, operacija)
        VALUES (NULL, :OLD.ime_kupca, NULL, :OLD.grad, v_korisnik, v_datum, 'Delete');
    ELSIF UPDATING THEN
        INSERT INTO revizija (novo_ime_kupca, staro_ime_kupca, novi_grad, stari_grad, korisnik, datum_unosa, operacija)
        VALUES (:NEW.ime_kupca, :OLD.ime_kupca, :NEW.grad, :OLD.grad, v_korisnik, v_datum, 'Update');
    END IF;
END;
/


CREATE TABLE revizija (
    novo_ime_kupca VARCHAR2(50),
    staro_ime_kupca VARCHAR2(50),
    novi_grad VARCHAR2(50),
    stari_grad VARCHAR2(50),
    korisnik VARCHAR2(50),
    datum_unosa VARCHAR2(50),
    operacija VARCHAR2(50)
);

INSERT INTO KUPCI VALUES(10, 'Ivo Marić', 'Split');
UPDATE KUPCI SET grad = 'Zagreb' WHERE idKupac = 1;
DELETE FROM KUPCI WHERE idKupac = 10;

SELECT * FROM revizija;
SELECT * FROM kupci;

--primjer 2(backup)

CREATE TABLE KUPCI_backup AS SELECT * FROM KUPCI WHERE 1=2;

CREATE OR REPLACE TRIGGER k_backup
BEFORE INSERT OR DELETE OR UPDATE ON KUPCI
FOR EACH ROW
ENABLE
BEGIN
    IF INSERTING THEN    
        INSERT INTO KUPCI_backup (idKupac, ime_kupca, grad) VALUES (:NEW.idKupac, :NEW.ime_kupca, :NEW.grad);  
    ELSIF DELETING THEN   
        DELETE FROM KUPCI_backup WHERE idKupac = :OLD.idKupac;   
    ELSIF UPDATING THEN   
        UPDATE KUPCI_backup SET ime_kupca = :NEW.ime_kupca, grad = :NEW.grad WHERE idKupac = :OLD.idKupac;    
    END IF;   
END;
/

SELECT * FROM KUPCI_BACKUP;

INSERT INTO KUPCI VALUES (10, 'Jadranka Sokolović', 'Čakovec');
UPDATE KUPCI SET grad = 'Zagreb' WHERE idKupac = 10;


--PROSLJEĐIVANJA

CREATE OR REPLACE FUNCTION brojDADA (broj1 NUMBER, broj2 NUMBER DEFAULT 0, broj3 NUMBER)  
RETURN NUMBER  
IS 
BEGIN 
    DBMS_OUTPUT.PUT_LINE ('broj_1 -> ' || broj1); 
    DBMS_OUTPUT.PUT_LINE ('broj_2 -> ' || broj2); 
    DBMS_OUTPUT.PUT_LINE ('broj_3 -> ' || broj3); 
    RETURN broj1+broj2+broj3; 
END; 
/

DECLARE
  rezultat  NUMBER;
BEGIN
  rezultat := brojDADA(30, broj3 =>20, broj2 =>10);
  DBMS_OUTPUT.put_line('Result ->' || rezultat);
END;


--EXCEPTION(IZNIMKE)

DECLARE
    broj1    NUMBER := 10;
    broj2    NUMBER := 5;
    rezultat NUMBER;
    e_iznimka EXCEPTION;
BEGIN
        IF (broj2 = 0)THEN
            RAISE e_iznimka;
        ELSIF (broj1 = 0) THEN
            RAISE e_iznimka;
        ELSE
        rezultat := broj1/ broj2;
        DBMS_OUTPUT.PUT_LINE('Rezultat je ' || rezultat);
        END IF;
    EXCEPTION WHEN e_iznimka THEN
        DBMS_OUTPUT.PUT_LINE('Došlo je do pogreške jedan od brojeva je 0');
END;
/

--primjer 2

DECLARE
    ime KUPCI.ime_kupca%TYPE;
BEGIN
    SELECT ime_kupca INTO ime 
    FROM KUPCI WHERE idKupac = 1;
    DBMS_OUTPUT.PUT_LINE('KUPAC: ' || ime);
    
    EXCEPTION WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('Nema tog kupca');
END;

--primjer 3

DECLARE
    broj_godina NUMBER := 18;
BEGIN
    IF (broj_godina <= 18) THEN
        RAISE_APPLICATION_ERROR (-20008, ' imate manje od 18 godina, ne smijete konzumirati alkohol!!');
    END IF;
    DBMS_OUTPUT.PUT_LINE('Što želite piti');
    EXCEPTION 
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE ('pogreška!! ' || SQLERRM);
END;
/

--primjer 4

DECLARE
    broj_godina NUMBER := 17;
    e_iznimka EXCEPTION;
    PRAGMA EXCEPTION_INIT (e_iznimka, -20008);
BEGIN
    IF (broj_godina <= 18) THEN
        RAISE_APPLICATION_ERROR (-20008, ' imate manje od 18 godina, ne smijete konzumirati alkohol!!');
    END IF;
    DBMS_OUTPUT.PUT_LINE('Što želite piti');
    EXCEPTION 
    WHEN e_iznimka THEN
        DBMS_OUTPUT.PUT_LINE ('pogreška!! ' || SQLERRM);
END;
/


--BULK COLLECT

DECLARE
    TYPE ugnjezdjena_tablica_doba IS TABLE OF VARCHAR2(20);
    doba ugnjezdjena_tablica_doba;
BEGIN
    SELECT ime_dobavljaca BULK COLLECT INTO doba 
    FROM DOBAVLJACI;
    
    FOR idx IN 1..doba.COUNT
    LOOP
        DBMS_OUTPUT.PUT_LINE(idx || ' - ' || doba(idx));
    END LOOP;
END;

--primjer 2

DECLARE
    CURSOR c_kupci IS
    SELECT ime_kupca FROM KUPCI ORDER BY ime_kupca DESC;
    
    TYPE ugnjezdjena_tablica_doba IS TABLE OF VARCHAR2(20);
    ime ugnjezdjena_tablica_doba;
BEGIN
    OPEN c_kupci;
    FETCH c_kupci BULK COLLECT INTO ime LIMIT 5;
    CLOSE c_kupci;
    
    FOR idx IN 1..ime.COUNT
    LOOP
        DBMS_OUTPUT.PUT_LINE(idx || ' - ' || ime(idx));
    END LOOP;
END;

--FORALL

CREATE TABLE tut_78(
    mul_tab NUMBER(5)
);

DECLARE
    TYPE my_nested_table IS TABLE OF number;
    var_nt my_nested_table := my_nested_table (9,18,27,36,45,54,63,72,81,90);
    --Another variable for holding total number of record stored into the table 
    tot_rec NUMBER;
BEGIN
    var_nt.DELETE(3, 6);
     
    FORALL idx IN INDICES OF var_nt
        INSERT INTO tut_78 (mul_tab) VALUES (var_nt(idx));
         
    SELECT COUNT (*) INTO tot_rec FROM tut_78;
    DBMS_OUTPUT.PUT_LINE ('Ukupan broj zapisa je: '||tot_rec);
END;
/

SELECT * FROM tut_78;

--NATIVE DYNAMIC SQL

DECLARE
    ddl_table VARCHAR2 (150);
BEGIN
    ddl_table := 'CREATE TABLE zaposlenici (
                  idZaposlenik NUMBER,
                  ime VARCHAR2 (50)
                    )';
    EXECUTE IMMEDIATE ddl_table;
END;
/
INSERT INTO zaposlenici VALUES (1, 'Dino');

DECLARE
    ddl_dodaj VARCHAR(50);
BEGIN
    ddl_dodaj :='ALTER TABLE zaposlenici ADD datum_rodjenja DATE';
    EXECUTE IMMEDIATE ddl_dodaj;
END;
/
UPDATE zaposlenici SET datum_rodjenja = date '1995-01-20'
WHERE idZaposlenik = 1;

--primjer 2 (višestruke vezane varijable)

CREATE TABLE zaposlenici (
    idZaposlenik NUMBER,
    ime VARCHAR2(50)
);

INSERT INTO zaposlenici VALUES (1, 'Dino');
INSERT INTO zaposlenici VALUES (2, 'Ivana');
INSERT INTO zaposlenici VALUES (3, 'Slavko');
INSERT INTO zaposlenici VALUES (4, 'Marijana');
INSERT INTO zaposlenici VALUES (5, 'Dražen');

DECLARE
    zamjena Varchar2(150);
BEGIN
    zamjena := 'UPDATE zaposlenici SET ime = :new_name 
    WHERE ime = :old_name ';
    --novo ime mora biti prvo, zatim ide staro
    EXECUTE IMMEDIATE zamjena USING 'Ljubica','Ivana';   
END;
/
select * from zaposlenici;

--bulk collect sa dynamic SQL-om

DECLARE
    TYPE ut_kupci IS TABLE OF VARCHAR2 (50);
    kupci ut_kupci;
    upit VARCHAR2 (150);
BEGIN
    upit := 'SELECT ime_kupca FROM KUPCI';
    EXECUTE IMMEDIATE upit BULK COLLECT INTO kupci;
    FOR idx IN 1..kupci.COUNT
    LOOP
        DBMS_OUTPUT.PUT_LINE(idx || ' - ' || kupci(idx));
    END LOOP;
END;

--APSTRAKCIJA
--daje najmanji broj niza

DECLARE
    TYPE tablica IS TABLE OF number; 
    var_nt tablica := tablica (17, 22, 5, 97, -25, 55, 3, 200);
    broj number := binary_double_infinity;
BEGIN
    FOR b1 IN var_nt.FIRST..var_nt.COUNT
    LOOP
        IF (var_nt(b1) < broj) THEN
        broj := var_nt(b1);
        --DBMS_OUTPUT.PUT_LINE( 'Najeći broj je  ' || broj);
        END IF;
    END LOOP;
    DBMS_OUTPUT.PUT_LINE( 'Najmanji broj niza je  ' || broj);
END;
/

--razdvaja uneseni broj 

DECLARE
    broj NUMBER:= -1210;
    modul NUMBER;
    k NUMBER := 0;
BEGIN
    IF (broj = 0) THEN
        k := 1;
        DBMS_OUTPUT.PUT_LINE('Broj je ' || broj);
    ELSIF (broj < 0) THEN 
        WHILE broj < 0 LOOP
            modul := MOD(broj, 10);
            DBMS_OUTPUT.PUT_LINE('Ostatak unesenog broja ' || broj || ' je ' || modul );
            broj := (broj-modul)/10;
            DBMS_OUTPUT.PUT_LINE('Drugi broj je ' || broj);
            k :=  k + 1;
        END LOOP;
    ELSE 
         WHILE broj > 0 LOOP
            modul := MOD(broj, 10);
            DBMS_OUTPUT.PUT_LINE('Ostatak unesenog broja ' || broj || ' je ' || modul );
            broj := (broj-modul)/10;
            DBMS_OUTPUT.PUT_LINE('Drugi broj je ' || broj);
            k :=  k + 1;
        END LOOP;
    END IF;
    DBMS_OUTPUT.PUT_LINE('Broj znakova je ' || k);
END;
/

--sortiranje niza brojeva

DECLARE
    TYPE tab_brojevi IS TABLE OF NUMBER;
    l_tab_brojevi tab_brojevi := tab_brojevi(34, 15, 10, 999, 40, 100);
    b1 NUMBER;
    b2 NUMBER;
    te NUMBER;
BEGIN
    FOR b1 IN l_tab_brojevi.FIRST..l_tab_brojevi.LAST LOOP
        FOR b2 IN l_tab_brojevi.FIRST..l_tab_brojevi.LAST LOOP
            IF l_tab_brojevi(b1) > l_tab_brojevi(b2) THEN
                te := l_tab_brojevi(b1);
                l_tab_brojevi(b1) :=  l_tab_brojevi(b2);
                l_tab_brojevi(b2) := te;
            END IF;
        END LOOP;
    END LOOP;
 
    FOR cc IN l_tab_brojevi.FIRST..l_tab_brojevi.LAST LOOP
        DBMS_OUTPUT.PUT_LINE('Broj sa indexom ' || cc || ' je ' || l_tab_brojevi(cc));
    END LOOP;
END;
/

--izracunavanje faktorijela

DECLARE
    broj NUMBER := 4;
    rez NUMBER := 1;
BEGIN
    IF (broj > 0) THEN 
        FOR r IN 2..broj LOOP
            rez := rez * r;
        END LOOP;
        DBMS_OUTPUT.PUT_LINE(rez);
    ELSE 
        DBMS_OUTPUT.PUT_LINE('Uneseni broj ne smije biti 0 ili manji!!');
    END IF;
END;
/

--fibonacijev niz

DECLARE
    a number := 0;
    b number := 1;
    temp number;
    n number := 10;
BEGIN
    FOR r IN 1..n LOOP
        temp := a + b;
        dbms_output.put_line(temp);
        a := b;
        b := temp;
    END LOOP;
END;
/

--***************************************************
--ZADACI ZA VJEŽBU

--Napisati pl/sql blok koji će generirati koliko proizvoda nema najveću ili najmanju vrijednost 

DECLARE
    cur SYS_REFCURSOR;
    naziv_proizvoda PROIZVODI.naziv%TYPE;
    cijena_proizvoda PROIZVODI.cijena%TYPE;
    brojac NUMBER := 0;
BEGIN
    OPEN cur FOR SELECT naziv, cijena FROM PROIZVODI
        WHERE cijena != (SELECT MAX(cijena) FROM PROIZVODI) AND cijena != (SELECT MIN(cijena) FROM PROIZVODI);
        LOOP
            FETCH cur INTO naziv_proizvoda, cijena_proizvoda;
            EXIT WHEN cur%NOTFOUND;
            DBMS_OUTPUT.PUT_LINE('Naziv proizvoda ' || naziv_proizvoda);
            brojac := brojac + 1;
        END LOOP;
        DBMS_OUTPUT.PUT_LINE('Ukupan broj proizvoda koji nemaju niti najveću niti najmanju vrijednost je ' || brojac);
    CLOSE cur;
END;
/

--zadaci pl/sql task answers

DECLARE
    ID_PRO PROIZVODI.idProizvod%TYPE := 1;
    NAZIV PROIZVODI.naziv%TYPE;
    CIJ PROIZVODI.cijena%TYPE;
    postotak NUMBER := 0.5;
BEGIN
    SELECT naziv, cijena 
    INTO NAZIV, CIJ
    FROM PROIZVODI
    WHERE idProizvod = ID_PRO;
    
    IF (CIJ < 5000) THEN
        UPDATE PROIZVODI
        SET cijena = cijena * postotak
        WHERE idProizvod = ID_PRO;
        DBMS_OUTPUT.PUT_LINE('Proizvod ' || naziv || ' sada ima cijenu ' || CIJ * postotak);
    ELSE 
        DBMS_OUTPUT.PUT_LINE('Cijena proizvoda je veća od 5000 kn i nije ažurirana');
    END IF;
END;
/

--zadatak 2

DECLARE
    ID_PRO PROIZVODI.idProizvod%TYPE := 1;
    NAZIV PROIZVODI.naziv%TYPE;
    CIJ PROIZVODI.cijena%TYPE;
    bonus NUMBER;
    godisnja_cijena NUMBER;
BEGIN
    SELECT cijena INTO CIJ FROM PROIZVODI WHERE idProizvod = ID_PRO;
    
    godisnja_cijena := CIJ * 12;
    DBMS_OUTPUT.PUT_LINE ('Godišnja cijena je ' || godisnja_cijena || ' kn.');
    
    IF godisnja_cijena > 30000 THEN
        bonus := 10000;
    ELSE 
        bonus := 5000;
    END IF;
    
    DBMS_OUTPUT.PUT_LINE('Bonus na godisnju cijenu je ' || bonus);
END;
/

--zadatak 3

DECLARE
    CURSOR c_narudzbe IS SELECT idNarudzba, datumNar FROM NARUDZBE;
    datum DATE := '29-FEB-20';
    IDn NARUDZBE.idNarudzba%TYPE;
    dat NARUDZBE.datumNar%TYPE;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Svi datumi narudžne poslje ' || datum);
    OPEN c_narudzbe;
    LOOP
        FETCH c_narudzbe INTO IDn, dat;
        EXIT WHEN c_narudzbe%NOTFOUND;
        IF (dat > datum) THEN
            DBMS_OUTPUT.PUT_LINE('Datum narudzbe: ' || dat || ' ID Narudzbe ' || IDn);
        END IF;
    END LOOP;
    CLOSE c_narudzbe;
END;
/

DECLARE
    CURSOR c_narudzbe IS SELECT n.idNarudzba, n.datumNar, n.idKupac as idnk, k.idKupac as idkk, k.ime_kupca 
    FROM NARUDZBE n INNER JOIN KUPCI k ON n.idKupac = k.idKupac;
    datum DATE := '29-FEB-20';
BEGIN
    DBMS_OUTPUT.PUT_LINE('Svi datumi narudžne poslje ' || datum);
    FOR r IN c_narudzbe LOOP
        IF (r.datumNar > datum) THEN
            DBMS_OUTPUT.PUT_LINE('Kupac: ' || r.ime_kupca || ' napravio/la je narudzbu datuma: ' || r.datumNar || 
            ' ID Narudzbe ' || r.idNarudzba);
        END IF;
    END LOOP;
END;
/

--zadatak 4

DECLARE
    CURSOR c_proizvodi IS SELECT * FROM PROIZVODI WHERE idProizvod < 6;
    brojac BINARY_INTEGER := 0;
    
    TYPE n_idProizvod IS TABLE OF PROIZVODI.idProizvod%TYPE INDEX BY BINARY_INTEGER;
    n_IDp n_idProizvod;
    
    TYPE n_naziv IS TABLE OF PROIZVODI.naziv%TYPE INDEX BY BINARY_INTEGER;
    n_naz n_naziv;
    
    i BINARY_INTEGER := 0;
BEGIN
    FOR r IN c_proizvodi
    LOOP
        i := i + 1;
        n_IDp(i) := r.idProizvod;
        n_naz(i) := r.naziv;
        DBMS_OUTPUT.PUT_LINE('ID: ' || n_IDp(i) || ' Naziv: ' || n_naz(i));
        brojac := brojac + 1;
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('Broj: ' || brojac);
END;
/

--zadatak 5

DECLARE
    NAZ PROIZVODI.naziv%TYPE;
    CIJ PROIZVODI.cijena%TYPE;
    KOL DETALJINAR.kolicina%TYPE;
    e_iznimka EXCEPTION;
BEGIN
    SELECT p.naziv, p.cijena, d.kolicina
    INTO NAZ, CIJ, KOL
    FROM PROIZVODI p INNER JOIN DETALJINAR d
    ON p.idProizvod = d.idProizvod
    WHERE idDetalji = 1;
    
    IF (CIJ < 6000 AND KOL < 5) THEN
        DBMS_OUTPUT.PUT_LINE(NAZ);
    ELSE 
        RAISE e_iznimka;
    END IF;
    
    EXCEPTION WHEN e_iznimka THEN
        DBMS_OUTPUT.PUT_LINE('Neštno nije u redu!!');
END;
/

--zadatak 6

CREATE OR REPLACE PROCEDURE add_supplier (
    idD DOBAVLJACI.idDobavljac%TYPE,
    ime DOBAVLJACI.ime_dobavljaca%TYPE
)
IS
BEGIN
    INSERT INTO DOBAVLJACI(idDobavljac, ime_dobavljaca)
    VALUES (idD, ime);
    
    COMMIT;
END;
/

--zadatak 7

CREATE OR REPLACE PROCEDURE upd_supplier (
    idD DOBAVLJACI.idDobavljac%TYPE,
    ime DOBAVLJACI.ime_dobavljaca%TYPE
)
IS
BEGIN
    UPDATE DOBAVLJACI
    SET ime_dobavljaca = ime
    WHERE idDobavljac = idD;
    
    IF sql%NOTFOUND THEN
        RAISE_APPLICATION_ERROR(-20001, 'Unjeli ste ID koji se ne koristi!!');
    ELSE
        COMMIT;
    END IF;
END;
/

--zadatak 8

CREATE OR REPLACE PROCEDURE get_supplier (idD DOBAVLJACI.idDobavljac%TYPE)
IS
    ime DOBAVLJACI.ime_dobavljaca%TYPE;
BEGIN
    SELECT ime_dobavljaca INTO ime
    FROM DOBAVLJACI 
    WHERE idDobavljac = idD;
    
    DBMS_OUTPUT.PUT_LINE('Ime dobavljaca pod ID-m ' || idD || ' je ' || ime);
    
    EXCEPTION 
		WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Upisali ste ID koji se vec koristi -- ' || SQLERRM);
END;
/

--zadatak 9

CREATE OR REPLACE FUNCTION get_city (idK KUPCI.idKupac%TYPE)
RETURN KUPCI.grad%TYPE
IS
    city KUPCI.grad%TYPE;
BEGIN
    SELECT grad INTO city
    FROM KUPCI
    WHERE idKupac = idK;
    
    RETURN city;
END;
/

--zadatak 10

CREATE OR REPLACE FUNCTION get_summer_disscount (
    cij PROIZVODI.cijena%TYPE,
    postotak NUMBER)
RETURN NUMBER
IS
BEGIN
    RETURN cij * postotak;
END;
/

SELECT naziv, cijena AS "Stara cijenaaa", get_summer_disscount(cijena, 0.5) AS cijena_sa_popustom
FROM PROIZVODI
WHERE idProizvod = 2;

--zadatak 11

CREATE OR REPLACE PROCEDURE add_product (
    idP PROIZVODI.idProizvod%TYPE,
    naz PROIZVODI.naziv%TYPE,
    cij PROIZVODI.cijena%TYPE,
    idD PROIZVODI.idDobavljac%TYPE
)
IS
BEGIN
    IF(valid_dobvID(idD) = TRUE) THEN
        INSERT INTO PROIZVODI (idProizvod, naziv, cijena, idDobavljac)
        VALUES (idP, naz, cij, idD);
        
        COMMIT;
    ELSE
        RAISE_APPLICATION_ERROR (-20004, 'Pogrešan ID dobavljaca na koji se referencira, pokušajte ponovo!!');
    END IF;
    
    EXCEPTION 
		WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Upisali ste ID koji se vec koristi -- ' || SQLERRM);
END;
/


CREATE OR REPLACE FUNCTION valid_dobvID ( idD DOBAVLJACI.idDobavljac%TYPE)
RETURN BOOLEAN 
IS
    dummy BINARY_INTEGER;
BEGIN
    SELECT 1
    INTO dummy
    FROM DOBAVLJACI
    WHERE idDobavljac = idD;
    
    RETURN TRUE;
    
    EXCEPTION 
    WHEN NO_DATA_FOUND THEN
    RETURN FALSE;
END;
/

--zadatak 12

CREATE OR REPLACE PACKAGE pkg_supplier IS
    PROCEDURE add_supplier (
        idD DOBAVLJACI.idDobavljac%TYPE,
        ime DOBAVLJACI.ime_dobavljaca%TYPE
    );
    PROCEDURE upd_supplier (
        idD DOBAVLJACI.idDobavljac%TYPE,
        ime DOBAVLJACI.ime_dobavljaca%TYPE
    );
    PROCEDURE get_supplier (
        idD DOBAVLJACI.idDobavljac%TYPE
    );
    FUNCTION get_city (idK KUPCI.idKupac%TYPE)
        RETURN KUPCI.grad%TYPE;
END pkg_supplier;
/

--**********************

CREATE OR REPLACE PACKAGE BODY pkg_supplier IS
    PROCEDURE add_supplier (
        idD DOBAVLJACI.idDobavljac%TYPE,
        ime DOBAVLJACI.ime_dobavljaca%TYPE
    )
    IS
    BEGIN
        INSERT INTO DOBAVLJACI(idDobavljac, ime_dobavljaca)
        VALUES (idD, ime);
        
        COMMIT;
    END;
    
    PROCEDURE upd_supplier (
    idD DOBAVLJACI.idDobavljac%TYPE,
    ime DOBAVLJACI.ime_dobavljaca%TYPE
    )
    IS
    BEGIN
        UPDATE DOBAVLJACI
        SET ime_dobavljaca = ime
        WHERE idDobavljac = idD;
        
        IF sql%NOTFOUND THEN
            RAISE_APPLICATION_ERROR(-20001, 'Unjeli ste ID koji se ne koristi!!');
        ELSE
            COMMIT;
        END IF;
    END;
    
    PROCEDURE get_supplier (idD DOBAVLJACI.idDobavljac%TYPE)
    IS
        ime DOBAVLJACI.ime_dobavljaca%TYPE;
    BEGIN
        SELECT ime_dobavljaca INTO ime
        FROM DOBAVLJACI 
        WHERE idDobavljac = idD;
        
        DBMS_OUTPUT.PUT_LINE('Ime dobavljaca pod ID-m ' || idD || ' je ' || ime);
        
        EXCEPTION 
    		WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Upisali ste ID koji se vec koristi -- ' || SQLERRM);
    END;
    
    FUNCTION get_city (idK KUPCI.idKupac%TYPE)
    RETURN KUPCI.grad%TYPE
    IS
        city KUPCI.grad%TYPE;
    BEGIN
        SELECT grad INTO city
        FROM KUPCI
        WHERE idKupac = idK;
        
        RETURN city;
    END;
END pkg_supplier;
/

EXECUTE pkg_supplier.get_supplier(3);




