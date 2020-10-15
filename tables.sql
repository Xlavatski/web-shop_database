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