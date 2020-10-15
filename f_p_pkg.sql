--FUNKCIJA (ZADATAK: NAPISATI FUNKCIJU KOJA UPISOM PARAMETRA VRAĆA KOLIKO KOJI DOBAVLJAC IMA PROIZVODA)

CREATE OR REPLACE FUNCTION analitika
RETURN VARCHAR2 IS
    dobavljac VARCHAR2(30);
BEGIN
    SELECT ime_dobavljaca INTO dobavljac FROM (
        SELECT dobavljaci.ime_dobavljaca, count(PROIZVODI.naziv) AS broj FROM dobavljaci, proizvodi
        WHERE dobavljaci.idDobavljac = proizvodi.idDobavljac
        GROUP BY dobavljaci.ime_dobavljaca ORDER BY broj DESC
        )
    WHERE ROWNUM = 1;
    RETURN dobavljac;
END;
/
BEGIN
DBMS_OUTPUT.PUT_LINE('Najviše je prodano uređaja marke: '||analitika());
END;

--primjer 2

CREATE OR REPLACE FUNCTION MATEMATIKA (broj1 NUMBER, broj2 NUMBER)
RETURN NUMBER IS
    broj NUMBER;
BEGIN
    broj := broj1 + broj2;
    RETURN broj;
END;
/

BEGIN
    DBMS_OUTPUT.PUT_LINE(MATEMATIKA(10, 5));
END;
/

--primjer 3 (funkcija koja vraća sve proizvode i cijene od dobavljaca kojeg smo unjeli)

CREATE OR REPLACE FUNCTION dobavljac_proizvodi (dobavljac DOBAVLJACI.ime_dobavljaca%TYPE)
RETURN SYS_REFCURSOR IS
    c_proizvodi SYS_REFCURSOR;
BEGIN
    OPEN c_proizvodi FOR 
    SELECT PROIZVODI.naziv, PROIZVODI.cijena, PROIZVODI.idDobavljac
    FROM PROIZVODI, DOBAVLJACI
    WHERE PROIZVODI.idDobavljac = DOBAVLJACI.idDobavljac
    AND DOBAVLJACI.ime_dobavljaca = dobavljac;
    
    RETURN c_proizvodi;
END;
/

DECLARE
    moj_cursor SYS_REFCURSOR;
    naziv PROIZVODI.naziv%TYPE;
    cijena PROIZVODI.cijena%TYPE;
    idP PROIZVODI.idDobavljac%type;
BEGIN
    moj_cursor := dobavljac_proizvodi('Lenovo');
    LOOP
        FETCH moj_cursor INTO naziv, cijena, idP;
        EXIT WHEN moj_cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('Naziv: ' || naziv || ' cijena: ' || cijena || 'kn.');
    END LOOP;
END;
/

--primjer 4

CREATE OR REPLACE FUNCTION kupac_bez_narudzbe
RETURN SYS_REFCURSOR IS
    c_kupci SYS_REFCURSOR;
BEGIN
    OPEN c_kupci FOR
    SELECT KUPCI.idKupac FROM KUPCI 
    WHERE KUPCI.idKupac NOT IN (SELECT DISTINCT NARUDZBE.idKupac FROM NARUDZBE
    WHERE NARUDZBE.idKupac IS NOT NULL);
    
    RETURN c_kupci;
END;
/

DECLARE 
    moj_cursor SYS_REFCURSOR;
    idK KUPCI.idKupac%TYPE;
BEGIN
    moj_cursor := kupac_bez_narudzbe;
    LOOP
        FETCH moj_cursor INTO idK;
        EXIT WHEN moj_cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('Kupac sa id: ' || idK);
    END LOOP;
END;
/

--primjer 5 (funkcija koja vraca prvi slobodan id)

CREATE OR REPLACE FUNCTION vrati_id 
RETURN NUMBER IS
    brojac NUMBER;
    moj_cursor SYS_REFCURSOR;
    idK KUPCI.idKupac%TYPE;
BEGIN
    OPEN moj_cursor FOR SELECT idKupac FROM KUPCI;
        LOOP
            FETCH moj_cursor INTO idK;
            EXIT WHEN moj_cursor%NOTFOUND;
            --dbms_output.put_line(idK);
        END LOOP;
        brojac := idk + 1;
        --dbms_output.put_line('da ' || brojac);
    CLOSE moj_cursor;
    
    RETURN brojac;
END;
/

BEGIN
    dbms_output.put_line(vrati_id);
END;
/

--primjer 6 (funkcija vraca današnji datum te provjerava dali je veci od upisanog datuma)

CREATE OR REPLACE FUNCTION vrati_danasnji_datum 
RETURN DATE IS
    datum DATE;
BEGIN
    datum := SYSDATE;
    return datum;
END;
/

BEGIN
    DBMS_OUTPUT.PUT_LINE(vrati_danasnji_datum);
    
    IF ('29-JUN-20' < vrati_danjasnji_datum) THEN
        DBMS_OUTPUT.PUT_LINE('Datum je prošao');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Još nije prošao');
    END IF;
END;
/

--PROCEDURA

CREATE OR REPLACE PROCEDURE pro_cijena (pro_id NUMBER, pro_postotak NUMBER)
IS 
BEGIN
    UPDATE PROIZVODI SET cijena = cijena * pro_postotak WHERE idProizvod = pro_id;
END pro_cijena;
/

EXECUTE pro_cijena(8, 1.30);

--primjer 2

CREATE OR REPLACE PROCEDURE povecanje_cijene (plata NUMBER, pro_postotak NUMBER)
IS 
    CURSOR c_proizvodi IS
        SELECT * FROM proizvodi 
        FOR UPDATE;
BEGIN
    FOR r IN c_proizvodi LOOP
--deklariranjem varijabli iz kursora uvijek moramo naznačiti ključno slovo r.ime 
        IF r.cijena > plata THEN
            UPDATE PROIZVODI SET cijena = cijena * pro_postotak
            WHERE CURRENT OF c_proizvodi;
            DBMS_OUTPUT.PUT_LINE(r.naziv || ' se povecao');--TO_CHAR
        ELSE
            DBMS_OUTPUT.PUT_LINE(r.naziv || ' se nije povecao');
        END IF;
    END LOOP;
END povecanje_cijene;
/

SELECT * FROM proizvodi;

EXECUTE povecanje_cijene(5000, 1.50);

--primjer 3

CREATE OR REPLACE PROCEDURE dodaj_kupca (
    p_idKupac IN KUPCI.idKupac%TYPE,
    p_ime_kupca IN KUPCI.ime_kupca%TYPE,
    p_grad IN KUPCI.grad%TYPE)
IS
BEGIN
    INSERT INTO KUPCI (idKupac, ime_kupca, grad)
    VALUES (p_idKupac, p_ime_kupca, p_grad);
    COMMIT;
    
    EXCEPTION 
		WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Upisali ste ID koji se vec koristi -- ' || SQLERRM);

END;
/

--primjer 4

CREATE OR REPLACE PROCEDURE izbrisi_kupca (
    p_id IN KUPCI.idKupac%TYPE
)
IS
BEGIN
    DELETE FROM KUPCI WHERE idKupac=p_id;
    
    IF SQL%ROWCOUNT = 0 THEN
        RAISE_APPLICATION_ERROR(-20001 ,'Kupac ' || p_id || ' ne postoji');
    END IF;
    
    COMMIT;
    
    EXCEPTION 
		WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Upisali ste ID Kupca koji se referencira na neku narudžbu '|| SQLERRM);
END;
/

execute izbrisi_kupca(7);

--primjer 5 (procedura koja radi sa funkcijom kupac_bez_narudzbe)

CREATE OR REPLACE PROCEDURE izbrisi_kupca
IS
    moj_cursor SYS_REFCURSOR;
    idK KUPCI.idKupac%TYPE;
BEGIN
    moj_cursor := kupac_bez_narudzbe;
    LOOP
        FETCH moj_cursor INTO idK;
        EXIT WHEN moj_cursor%NOTFOUND;
        DELETE FROM KUPCI WHERE idKupac = idK;
    END LOOP;
    
    COMMIT;
END;
/
EXECUTE izbrisi_kupca;

--primjer 6 (procedura dodaj kupca koja se referencira na funkciju vradi_id i dodaje kupca)

CREATE OR REPLACE PROCEDURE dodaj_kupca (
    p_ime_kupca IN KUPCI.ime_kupca%TYPE,
    p_grad IN KUPCI.grad%TYPE)
IS
p_idKupac KUPCI.idKupac%TYPE;
BEGIN
    p_idKupac := vrati_id;
    INSERT INTO KUPCI (idKupac, ime_kupca, grad)
    VALUES (p_idKupac, p_ime_kupca, p_grad);
    COMMIT;
    
    EXCEPTION 
		WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Pogreška !! ' || SQLERRM);

END;
/

EXECUTE dodaj_kupca ('Joža Manolić', 'Čakovec');

--primjer 7 (upisom id-a dobavljaca ispisuje se koliko koji dobavljac ima proizvoda)

CREATE OR REPLACE PROCEDURE ispisi_proizvode (
    p_idDobavljac IN DOBAVLJACI.idDobavljac%TYPE)
IS
  TYPE tip IS RECORD(
    naziv DOBAVLJACI.ime_dobavljaca%TYPE,
    broj NUMBER);
    zapis tip; 
BEGIN
    SELECT DOBAVLJACI.ime_dobavljaca, count(*)
    INTO zapis FROM PROIZVODI 
    INNER JOIN DOBAVLJACI ON DOBAVLJACI.idDobavljac = PROIZVODI.idDobavljac
    WHERE DOBAVLJACI.idDobavljac = p_idDobavljac 
    GROUP BY DOBAVLJACI.ime_dobavljaca;
		IF (zapis.broj > 1) THEN
		DBMS_OUTPUT.PUT_LINE('Proizvođač: ' || zapis.naziv || ' ima u ponudi ' ||
		zapis.broj || ' uređaja.');
		ELSE
		DBMS_OUTPUT.PUT_LINE('Proizvođač: ' || zapis.naziv || ' ima u ponudi ' ||
		zapis.broj || ' uređaj.');
		END IF;
END;
/
BEGIN
    ispisi_proizvode(4);
END;

--primjer 8 (Upisom dobavljaca ispisuju se svi proizvode i cijene tog dobavljaca)

CREATE OR REPLACE PROCEDURE vrati_proizvode (dobavljac DOBAVLJACI.ime_dobavljaca%TYPE)
IS
    c_proizvodi SYS_REFCURSOR;
    naziv PROIZVODI.naziv%TYPE;
    cijena PROIZVODI.cijena%TYPE;
    idP PROIZVODI.idDobavljac%type;
BEGIN
    OPEN c_proizvodi FOR 
    SELECT PROIZVODI.naziv, PROIZVODI.cijena, PROIZVODI.idDobavljac
    FROM PROIZVODI, DOBAVLJACI
    WHERE PROIZVODI.idDobavljac = DOBAVLJACI.idDobavljac
    AND DOBAVLJACI.ime_dobavljaca = dobavljac;
    
    LOOP
        FETCH c_proizvodi INTO naziv, cijena, idP;
        EXIT WHEN c_proizvodi%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('Naziv: ' || naziv || ' cijena: ' || cijena || 'kn.');
    END LOOP;
END;
/

EXECUTE vrati_proizvode('HP');

--primjer 9 (upisom id-a dobavljaca procedura vraca koliko koji kupac ima narudzbi ili ako nema da ima 0)

CREATE OR REPLACE PROCEDURE ispisi_broj_narudzbe (p_idKupac KUPCI.idKupac%TYPE)
IS
    TYPE tip IS RECORD (
        ime KUPCI.ime_kupca%TYPE,
        gr KUPCI.grad%TYPE,
        broj NUMBER);
    zapis tip;
    
    moj_cursor SYS_REFCURSOR;
    idK KUPCI.idKupac%TYPE;
    ime KUPCI.ime_kupca%TYPE;
BEGIN
    OPEN moj_cursor FOR
    SELECT KUPCI.idKupac, KUPCI.ime_kupca FROM KUPCI 
    WHERE KUPCI.idKupac NOT IN (SELECT DISTINCT NARUDZBE.idKupac FROM NARUDZBE
    WHERE NARUDZBE.idKupac IS NOT NULL);
    LOOP
        FETCH moj_cursor INTO idK, ime;
        EXIT WHEN moj_cursor%NOTFOUND;
        IF (idK = p_idKupac) THEN
            DBMS_OUTPUT.PUT_LINE('Kupac: ' || ime || ' nije napravio/la niti jednu narudžbu.');
        END IF;
    END LOOP;

    SELECT ime_kupca, grad, count(idNarudzba)
    INTO zapis FROM KUPCI INNER JOIN NARUDZBE
    ON KUPCI.idKupac = NARUDZBE.idKupac
    WHERE KUPCI.idKupac = p_idKupac
    GROUP BY ime_kupca, grad;
    DBMS_OUTPUT.PUT_LINE('Kupac ' || zapis.ime || ' iz grada ' || zapis.gr || ' je naručio ' || zapis.broj || ' proizvoda.');
    
    EXCEPTION WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('Unjeli ste id kupca koji ne postoji');
END;
/

EXECUTE ispisi_broj_narudzbe(7);

--primjer 10 (ispis imena dobavljaca ciji smo id unjeli, te ispisivanje svih proizvoda i cijena tog dobavljaca)

CREATE OR REPLACE PROCEDURE get_supplier (idD DOBAVLJACI.idDobavljac%TYPE)
IS
    c_proizvodi SYS_REFCURSOR;
    c_dobavljaci SYS_REFCURSOR;
    
    ime DOBAVLJACI.ime_dobavljaca%TYPE;
    naz PROIZVODI.naziv%TYPE;
    cij PROIZVODI.cijena%TYPE;
BEGIN
    OPEN c_dobavljaci FOR
    SELECT ime_dobavljaca 
    FROM DOBAVLJACI
    WHERE idDobavljac = idD;

    OPEN c_proizvodi FOR
    SELECT d.ime_dobavljaca, p.naziv, p.cijena 
    FROM DOBAVLJACI d INNER JOIN PROIZVODI p
    ON d.idDobavljac = p.idDobavljac
    WHERE d.idDobavljac = idD;
    
    FETCH c_dobavljaci INTO ime;
    DBMS_OUTPUT.PUT_LINE('Ime dobavljaca je ' || ime);
    LOOP
        FETCH c_proizvodi INTO ime, naz, cij;
        EXIT WHEN c_proizvodi%NOTFOUND;
            DBMS_OUTPUT.PUT_LINE('Ime dobavljaca pod ID-m ' || idD || ' je ' || ime || ' - ' ||  naz || ' cijena ' || cij);
    END LOOP;
    
    EXCEPTION 
		WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Upisali ste ID koji se vec koristi -- ' || SQLERRM);
END;
/

EXECUTE get_supplier(4);

--PAKETI

CREATE OR REPLACE PACKAGE prvi_paket IS 
    FUNCTION analitika RETURN VARCHAR2;
    PROCEDURE pro_cijena (pro_id NUMBER, pro_postotak NUMBER);
END prvi_paket;
/

CREATE OR REPLACE PACKAGE BODY prvi_paket IS
    --FUNKCIJA
    FUNCTION analitika RETURN VARCHAR2 IS
    dobavljac VARCHAR2(30);
	BEGIN
		SELECT ime_dobavljaca INTO dobavljac FROM (
			SELECT dobavljaci.ime_dobavljaca, count(PROIZVODI.naziv) AS broj FROM dobavljaci, proizvodi
			WHERE dobavljaci.idDobavljac = proizvodi.idDobavljac
			GROUP BY dobavljaci.ime_dobavljaca ORDER BY broj DESC
			)
		WHERE ROWNUM = 1;
		RETURN dobavljac;
	END analitika;
    --PROCEDURA
    PROCEDURE pro_cijena (pro_id NUMBER, pro_postotak NUMBER)
    IS 
    BEGIN
        UPDATE PROIZVODI SET cijena = cijena * pro_postotak WHERE idProizvod = pro_id;
    END pro_cijena;
    
END prvi_paket;
/

BEGIN
DBMS_OUTPUT.PUT_LINE('Najviše je prodano uređaja marke: '||prvi_paket.analitika);
END;

EXECUTE prvi_paket.pro_cijena(1, 1.50);

-- primjer 2 (paket koji briše kupce koji nisu napravili niti jednu narudzbu)

CREATE OR REPLACE PACKAGE pkg_izbrisi_kupca IS
    PROCEDURE izbrisi_kupca;
END pkg_izbrisi_kupca;
/

CREATE OR REPLACE PACKAGE BODY pkg_izbrisi_kupca IS
    FUNCTION kupac_bez_narudzbe
    RETURN SYS_REFCURSOR IS
        c_kupci SYS_REFCURSOR;
    BEGIN
        OPEN c_kupci FOR
        SELECT KUPCI.idKupac FROM KUPCI 
        WHERE KUPCI.idKupac NOT IN (SELECT DISTINCT NARUDZBE.idKupac FROM NARUDZBE
        WHERE NARUDZBE.idKupac IS NOT NULL);
        
        RETURN c_kupci;
    END kupac_bez_narudzbe;
    
    PROCEDURE izbrisi_kupca
    IS
        moj_cursor SYS_REFCURSOR;
        idK KUPCI.idKupac%TYPE;
    BEGIN
        moj_cursor := kupac_bez_narudzbe;
        LOOP
            FETCH moj_cursor INTO idK;
            EXIT WHEN moj_cursor%NOTFOUND;
            DELETE FROM KUPCI WHERE idKupac = idK;
        END LOOP;
    
        COMMIT;
    END izbrisi_kupca;
END pkg_izbrisi_kupca;
/

EXECUTE pkg_izbrisi_kupca.izbrisi_kupca;

--primjer 3 (paket koji dodaje novog kupca bez upisivanja id-a)

CREATE OR REPLACE PACKAGE pkg_dodaj_kupca IS
    PROCEDURE dodaj_kupca (
        p_ime_kupca IN KUPCI.ime_kupca%TYPE,
        p_grad IN KUPCI.grad%TYPE);
END pkg_dodaj_kupca;
/

CREATE OR REPLACE PACKAGE BODY pkg_dodaj_kupca IS 
    FUNCTION vrati_id 
    RETURN NUMBER IS
        brojac NUMBER;
        moj_cursor SYS_REFCURSOR;
        idK KUPCI.idKupac%TYPE;
    BEGIN
        OPEN moj_cursor FOR SELECT idKupac FROM KUPCI;
            LOOP
                FETCH moj_cursor INTO idK;
                EXIT WHEN moj_cursor%NOTFOUND;
            END LOOP;
            brojac := idk + 1;
        CLOSE moj_cursor;
    
        RETURN brojac;
    END vrati_id;
    
    PROCEDURE dodaj_kupca (
        p_ime_kupca IN KUPCI.ime_kupca%TYPE,
        p_grad IN KUPCI.grad%TYPE)
        IS
        p_idKupac KUPCI.idKupac%TYPE;
    BEGIN
        p_idKupac := vrati_id;
        INSERT INTO KUPCI (idKupac, ime_kupca, grad)
        VALUES (p_idKupac, p_ime_kupca, p_grad);
        COMMIT;
        
        EXCEPTION 
    		WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Pogreška !! ' || SQLERRM);

    END dodaj_kupca;
END pkg_dodaj_kupca;
/

EXECUTE pkg_dodaj_kupca.dodaj_kupca('Jadranko Ivić', 'Rijeka');

--primjer 4 (paket koji dodaje novu narudzbu)

CREATE OR REPLACE PACKAGE pkg_nova_narudzba IS
    PROCEDURE nova_narudzba (
        idK IN NARUDZBE.idKupac%TYPE
    );
END pkg_nova_narudzba;
/

CREATE OR REPLACE PACKAGE BODY pkg_nova_narudzba IS
    FUNCTION vrati_id_n 
    RETURN NUMBER IS
        brojac NUMBER;
        moj_cursor SYS_REFCURSOR;
        idN NARUDZBE.idNarudzba%TYPE;
    BEGIN
        OPEN moj_cursor FOR SELECT idNarudzba FROM NARUDZBE;
            LOOP 
                FETCH moj_cursor INTO idN;
                EXIT WHEN moj_cursor%NOTFOUND;
            END LOOP;
            brojac := idN + 1;
        CLOSE moj_cursor;
        
        RETURN brojac;
    END vrati_id_n;
    
    FUNCTION vrati_danasnji_datum 
    RETURN DATE IS
        datum DATE;
    BEGIN
        datum := SYSDATE;
        return datum;
    END vrati_danasnji_datum;
    
    PROCEDURE nova_narudzba (idK IN NARUDZBE.idKupac%TYPE)
    IS
        f_idNarudzba NARUDZBE.idNarudzba%TYPE;
        f_datumNar NARUDZBE.datumNar%TYPE;
    BEGIN
        f_idNarudzba := vrati_id_n;
        f_datumNar := vrati_danasnji_datum;
        INSERT INTO NARUDZBE (idNarudzba, datumNar, idKupac)
        VALUES (f_idNarudzba, f_datumNar, idK);
        COMMIT;
        
        EXCEPTION 
    		WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Pogreška !! ' || SQLERRM);
    END nova_narudzba;
END pkg_nova_narudzba;
/

EXECUTE pkg_nova_narudzba.nova_narudzba(1);

