--CURSORI

DECLARE
    CURSOR c_kupci (var_id_k NUMBER := 2)IS
    SELECT KUPCI.idKupac, KUPCI.ime_kupca, NARUDZBE.idNarudzba, NARUDZBE.datumNar FROM KUPCI, NARUDZBE 
    WHERE KUPCI.idKupac < var_id_k AND KUPCI.idKupac = NARUDZBE.idKupac
    ORDER BY KUPCI.ime_kupca;
BEGIN
    FOR r IN c_kupci(3) LOOP
        DBMS_OUTPUT.PUT_LINE(r.ime_kupca || ', ' || r.datumNar);
    END LOOP;
END;

--primjer 2

DECLARE
    CURSOR c_kupci IS SELECT * FROM kupci;
    CURSOR c_narudzbe IS SELECT * FROM narudzbe;
BEGIN
    FOR r IN c_kupci LOOP
        DBMS_OUTPUT.PUT_LINE('Ime kupca je: ' || r.ime_kupca || ' koji živi u ' || r.grad);
    END LOOP;
    
    FOR b IN c_narudzbe LOOP
        DBMS_OUTPUT.PUT_LINE('Datum narudžbe ' || b.idNarudzba || ' je ' || b.datumNar);
    END LOOP;
END;
/

--primjer 3 (ugnježdeni kursori)

DECLARE
    CURSOR c_dobavljaci IS 
        SELECT * FROM DOBAVLJACI;
    CURSOR c_proizvodi (glupost IN DOBAVLJACI.idDobavljac%TYPE)  IS 
        SELECT naziv, cijena, PROIZVODI.idDobavljac
        FROM PROIZVODI, DOBAVLJACI
        WHERE DOBAVLJACI.idDobavljac = glupost;
BEGIN
    FOR d IN c_dobavljaci
        LOOP
            DBMS_OUTPUT.PUT_LINE('DOBAVLJAC: ' || d.ime_dobavljaca);
            
            FOR p IN c_proizvodi(d.idDobavljac)
                LOOP
                    IF (p.idDobavljac = d.idDobavljac) THEN
                    DBMS_OUTPUT.PUT_LINE('PROIZVODI: ' || p.naziv || ' - ' || p.cijena);
                    END IF;
            END LOOP;
    END LOOP;
END;
/

--primjer 4 (gniježđenje)

DECLARE
    CURSOR c_kupci IS 
        SELECT * FROM KUPCI;
    CURSOR c_narudzbe (parametar1 IN KUPCI.idKupac%TYPE) IS
        SELECT n.idNarudzba, n.datumNar, n.idKupac
        FROM NARUDZBE n INNER JOIN KUPCI k 
        ON n.idKupac = k.idKupac
        WHERE k.idKupac = parametar1;
    CURSOR c_detaljiNar (parametar2 IN NARUDZBE.idNarudzba%TYPE) IS
        SELECT d.idDetalji, d.kolicina, d.idNarudzba, d.idProizvod
        FROM NARUDZBE n INNER JOIN DETALJINAR d
        ON n.idNarudzba = d.idNarudzba
        WHERE n.idNarudzba = parametar2;
    CURSOR c_proizvodi (parametar3 IN DETALJINAR.idProizvod%TYPE) IS
        SELECT DISTINCT p.idProizvod, p.naziv, p.cijena
        FROM PROIZVODI p INNER JOIN DETALJINAR d
        ON p.idProizvod = d.idProizvod
        INNER JOIN NARUDZBE n ON n.idNarudzba = d.idNarudzba 
        WHERE p.idProizvod = parametar3;
BEGIN
    FOR k IN c_kupci
    LOOP
        DBMS_OUTPUT.PUT_LINE('***************************************');
        DBMS_OUTPUT.PUT_LINE('Kupac: ' || k.ime_kupca);
        FOR n IN c_narudzbe(k.idKupac)
        LOOP
            DBMS_OUTPUT.PUT_LINE('Narudzbe kupca:');
            DBMS_OUTPUT.PUT_LINE('ID narudzbe je ' || n.idNarudzba || ' a datum narudzbe je ' || n.datumNar);
            FOR d IN c_detaljiNar(n.idNarudzba)
            LOOP
                DBMS_OUTPUT.PUT_LINE('Detalji narudzbe:');
                DBMS_OUTPUT.PUT_LINE('ID detalja narudzbe je ' || d.idDetalji || ' dok je kolicina ' || d.kolicina);
                FOR p IN c_proizvodi(d.idProizvod)
                LOOP
                    DBMS_OUTPUT.PUT_LINE('Naziv proizvoda je ' || p.naziv );
                END LOOP;
            END LOOP;
        END LOOP;
    END LOOP;
END;
/

--drugi primjer

DECLARE
    CURSOR c_detaljiNar IS
        SELECT * FROM DETALJINAR;
    CURSOR c_proizvodi(parametar1 IN DETALJINAR.idProizvod%TYPE) IS
        SELECT DISTINCT p.idProizvod, p.naziv, p.cijena, p.idDobavljac
        FROM PROIZVODI p INNER JOIN DETALJINAR d 
        ON p.idProizvod = d.idProizvod
        WHERE p.idProizvod = parametar1;
    CURSOR c_dobavljaci(parametar2 IN PROIZVODI.idDobavljac%TYPE) IS
        SELECT DISTINCT d.idDobavljac, d.ime_dobavljaca 
        FROM DOBAVLJACI d INNER JOIN PROIZVODI p
        ON d.idDobavljac = p.idDobavljac
        WHERE d.idDobavljac = parametar2;
BEGIN
    FOR d IN c_detaljiNar 
    LOOP
        dbms_output.put_line(d.idDetalji ||' Detalji narudzbe su ' || d.kolicina || ' -- ' || d.idProizvod );
        FOR p in c_proizvodi(d.idProizvod) 
        LOOP
            dbms_output.put_line(p.naziv);
            FOR g IN c_dobavljaci(p.idDobavljac)
            LOOP
                dbms_output.put_line('Dobavljac je ' || g.ime_dobavljaca);
            END LOOP;
        END LOOP;
    END LOOP;
END;
/

--REF_CURSOR

DECLARE
    TYPE my_RefCur IS REF CURSOR RETURN PROIZVODI%ROWTYPE;
    cur_var my_RefCur;
    rec PROIZVODI%ROWTYPE;
BEGIN
    OPEN cur_var FOR SELECT * FROM PROIZVODI WHERE idProizvod = 2;
    FETCH cur_var INTO rec;
    CLOSE cur_var;
    DBMS_OUTPUT.PUT_LINE('Proizvod: ' || rec.naziv || ' košta: ' || rec.cijena || ' kn.');
END;
/

--slabi REF_CURSOR

DECLARE
    TYPE ref_cur IS REF CURSOR;
    cur_var ref_cur;
    
    ime KUPCI.ime_kupca%TYPE;
BEGIN
    OPEN cur_var FOR SELECT ime_kupca FROM KUPCI WHERE idKupac = 2;
    FETCH cur_var INTO ime;
    CLOSE cur_var;
    DBMS_OUTPUT.PUT_LINE(ime);
END;
/

--SYS_REFCURSOR

DECLARE
    cur_var SYS_REFCURSOR;
    ime KUPCI.ime_kupca%TYPE;
BEGIN
    OPEN cur_var FOR SELECT ime_kupca FROM KUPCI WHERE idKupac = 2;
    FETCH cur_var INTO ime;
    CLOSE cur_var;
    DBMS_OUTPUT.PUT_LINE(ime);
END;
/

--primjer 2

DECLARE
    cur_var SYS_REFCURSOR;
    ime KUPCI.ime_kupca%TYPE;
    grad KUPCI.grad%TYPE;
    naziv PROIZVODI.naziv%TYPE;
    cijena PROIZVODI.cijena%TYPE;
BEGIN
    OPEN cur_var FOR SELECT ime_kupca, grad FROM KUPCI;
        LOOP
            FETCH cur_var INTO ime, grad;
            EXIT WHEN cur_var%NOTFOUND;
            DBMS_OUTPUT.PUT_LINE('Ime kupca je: ' || ime || ', živi u ' || grad);
        END LOOP;
    CLOSE cur_var;
    
    OPEN cur_var FOR SELECT naziv, cijena FROM PROIZVODI;
        LOOP
            FETCH cur_var INTO naziv, cijena;
            EXIT WHEN cur_var%NOTFOUND;
            DBMS_OUTPUT.PUT_LINE('Model laptopa ' || naziv || ' košta ' || cijena || 'kn.');
        END LOOP;
    CLOSE cur_var;
END;
/

--primjer 3 (ugnježdeni sys_refcursor)

DECLARE
    gur SYS_REFCURSOR;
    cur SYS_REFCURSOR;
    idD DOBAVLJACI.idDobavljac%TYPE;
    imeD DOBAVLJACI.ime_dobavljaca%TYPE;
    
    idP PROIZVODI.idProizvod%TYPE;
    naz PROIZVODI.naziv%TYPE;
    cij PROIZVODI.cijena%TYPE;
    v_idD PROIZVODI.idDobavljac%TYPE;
BEGIN
    OPEN cur FOR SELECT idDobavljac, ime_dobavljaca FROM DOBAVLJACI;
        LOOP
            FETCH cur INTO idD, imeD;
            EXIT WHEN cur%NOTFOUND;
            DBMS_OUTPUT.PUT_LINE('DOBAVLJAC: ' || imeD);
            
            OPEN gur FOR SELECT idProizvod, naziv, cijena, PROIZVODI.idDobavljac 
            FROM PROIZVODI, DOBAVLJACI WHERE PROIZVODI.idDobavljac = DOBAVLJACI.idDobavljac;
                LOOP
                    FETCH gur INTO idP, naz, cij, v_idD;
                    EXIT WHEN gur%NOTFOUND;
                        IF (idD = v_idD) THEN
						DBMS_OUTPUT.PUT_LINE('PROIZVODI: ' || naz || ' CIJENA: ' || cij || 'KN. ');
                        END IF;
                END LOOP;
            CLOSE gur;
        END LOOP;
    CLOSE cur;
END;
/

--primjer 4 (ispisuje se zadnji id broj + 1)

DECLARE 
    moj_cursor SYS_REFCURSOR;
    idK KUPCI.idKupac%TYPE;
    brojac NUMBER := 0;
BEGIN
    OPEN moj_cursor FOR SELECT idKupac FROM KUPCI;
        LOOP
            FETCH moj_cursor INTO idK;
            EXIT WHEN moj_cursor%NOTFOUND;
            --dbms_output.put_line(idK);
        END LOOP;
        brojac := idk + 1;
        dbms_output.put_line(brojac);
    CLOSE moj_cursor;
END;
/