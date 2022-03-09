--KOLEKCIJE(NIZOVI)

DECLARE
    TYPE tablica IS TABLE OF number; 
    var_nt tablica := tablica (17, 22, 5, 29, 7);
BEGIN
    FOR r IN 1..var_nt.COUNT
    LOOP
        DBMS_OUTPUT.PUT_LINE(r|| '. element tablice je ' || var_nt(r));
    END LOOP;
END;

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

--sortiranje brojeva iz tablice

CREATE TYPE tab_brojevi IS TABLE OF NUMBER;
/

DECLARE
    l_tab_brojevi tab_brojevi := tab_brojevi(34, 15, 999, 102, 22, 500);
    l_index NUMBER;
BEGIN
    SELECT CAST ( MULTISET (SELECT * 
                FROM TABLE(l_tab_brojevi)
                ORDER BY 1
                ) AS tab_brojevi)
        INTO l_tab_brojevi
        FROM DUAL;
    
    l_index := l_tab_brojevi.FIRST;
    LOOP
        DBMS_OUTPUT.PUT_LINE(l_tab_brojevi(l_index));
        l_index := l_tab_brojevi.NEXT(l_index);
        EXIT WHEN l_index IS NULL;
    END LOOP;
END;
/

--blok koji puni sve torke iz tablice kupci

DECLARE
    TYPE d_projekt IS TABLE OF KUPCI%ROWTYPE INDEX BY BINARY_INTEGER;
    tabela d_projekt;
    i BINARY_INTEGER := 0;
BEGIN
    FOR r IN (SELECT * FROM KUPCI) 
    LOOP
        tabela(i) := r;
        i := i + 1;
    END LOOP;
    i := tabela.FIRST;
    WHILE i<= tabela.LAST LOOP
        DBMS_OUTPUT.PUT_LINE('Ime kupca ' || tabela(i).ime_kupca);
        DBMS_OUTPUT.PUT_LINE('grad: ' || tabela(i).grad);
        i := tabela.NEXT(i);
    END LOOP;
END;
/

--primjer 2(varray)

DECLARE 
    TYPE inBlock IS VARRAY (5) OF NUMBER;
    var_obj inBlock := inBlock(null, null, 10, null, null);
BEGIN
    FOR i IN 1..var_obj.LIMIT
    LOOP 
        var_obj(i) := 10*var_obj(i);
        DBMS_OUTPUT.PUT_LINE(var_obj(i));
        var_obj(i) := 10*i;
        DBMS_OUTPUT.PUT_LINE(var_obj(i));
    END LOOP;
END;

--primjer 3(tablica kupci)

DECLARE
    CURSOR c_kupci IS
        SELECT ime_kupca FROM KUPCI;
    TYPE c_list IS TABLE OF KUPCI.ime_kupca%TYPE;
    ime_liste c_list := c_list();
    brojac INTEGER := 0;
BEGIN
    FOR n IN c_kupci LOOP
        brojac := brojac + 1;
        ime_liste.extend;
        ime_liste(brojac) := n.ime_kupca;
        dbms_output.put_line('Kupac('||brojac||'):'||ime_liste(brojac));
    END LOOP;
END;

--asocijativni niz

DECLARE
    TYPE knjiga IS TABLE OF VARCHAR2(50)
        INDEX BY BINARY_INTEGER;
    isbn knjiga;
    broj BINARY_INTEGER;
BEGIN
    isbn(1001) := 'Uvod u SQL';
    isbn(2032) := 'Zlocin i kazna';
    isbn(3500) := 'Patnje mladog Vertera';
    DBMS_OUTPUT.PUT_LINE('Naslov knjige je ' || isbn(1001));
    
    broj := isbn.FIRST;
    DBMS_OUTPUT.PUT_LINE('Ključ je ' || broj);
    
    WHILE (broj IS NOT NULL)
    LOOP
        DBMS_OUTPUT.PUT_LINE('Ključ je ' || broj || ' dok je vrijednost: ' || isbn(broj));
     broj := isbn.NEXT (broj);
    END LOOP;
END;
/

--primjer 2 (asocijativni niz sa cursorom)

DECLARE
    CURSOR c_proizvodi IS
        SELECT PROIZVODI.idProizvod, PROIZVODI.naziv, PROIZVODI.cijena, DOBAVLJACI.ime_dobavljaca
        FROM PROIZVODI, DOBAVLJACI WHERE PROIZVODI.idDobavljac = DOBAVLJACI.idDobavljac;
    TYPE asortiman IS TABLE OF VARCHAR(100)
        INDEX BY BINARY_INTEGER;
    asor asortiman;
BEGIN
    FOR i IN c_proizvodi LOOP
        asor(i.idProizvod) := i.naziv || ', dok je cijena ' || i.cijena || ' -- naziv dobavljaca: ' || i.ime_dobavljaca; 
        DBMS_OUTPUT.PUT_LINE('Naziv proizvoda je '|| asor(i.idProizvod));
    END LOOP;
END;
/

--Metode kolekcije(delete)

DECLARE
    TYPE moj_niz2 IS TABLE OF NUMBER;
    niz moj_niz2 := moj_niz2 (2, 4, 5, 6, 9, 1, 7, 11);
BEGIN
    niz.DELETE(2, 4);
    FOR i IN 1..niz.LAST LOOP
        IF niz.EXISTS(i) THEN
            DBMS_OUTPUT.PUT_LINE('Broj indeksa je: ' || i || ' dok je vrijednost: ' || niz(i));
        END IF;
    END LOOP;
END;

--Višeslojne kolekcijie (dvodimenzionalna polja)

DECLARE
    --deklaracija i primjena konstante 
    broj CONSTANT INTEGER := 4;
    TYPE tip_1 IS VARRAY(broj) OF INTEGER;
    TYPE tip_2 IS VARRAY(3) OF tip_1;
    v1 tip_1 := tip_1();
    v2 tip_2 := tip_2();
    
    suma INTEGER;
BEGIN
    v1 := tip_1(10, 5);
    v2.EXTEND;
    v2(1) := v1;
    v1 := tip_1(30, 40, 10);
    v2.EXTEND;
    v2(2) := v1;
    v1 := tip_1(2, 7, 6, 50);
    v2.EXTEND;
    v2(3) := v1;
    FOR i IN 1 .. v2.LAST() LOOP
        DBMS_OUTPUT.PUT_LINE('Vanjski element - ' || i);
        suma := 0;
            FOR j IN 1 .. v2(i).LAST() LOOP
                DBMS_OUTPUT.PUT_LINE('Element ('||i||','||j||') - '||v2(i)(j));
                suma := suma + v2(i)(j);
            END LOOP;
            DBMS_OUTPUT.PUT_LINE('Suma brojeva je ' || suma);
    END LOOP;
    dbms_output.put_line('ja sam');
END;
/

--******************************************************************
--ZAPIS(RECORD)

--skripta stvara kolekciju (varray) i puni tablicu kolekcija_kupci

CREATE TABLE kolekcija_kupci ( 
    id INTEGER, 
    ime VARCHAR2(200), 
    city VARCHAR2(200), 
    CONSTRAINT pk_k PRIMARY KEY (id) 
);

DECLARE 
    TYPE rec_k IS RECORD( 
        kup_id KUPCI.idKupac%TYPE, 
        kup_ime KUPCI.ime_kupca%TYPE, 
        kup_grad KUPCI.grad%TYPE 
    ); 
     
    --rec rec_k; 
     
    TYPE rec_tablica IS VARRAY(120) OF rec_k;  
      
    rec_t rec_tablica := rec_tablica();  
BEGIN 
    rec_t.EXTEND(5); 
     
    rec_t(1) := rec_k(20, 'Petar Horvat', 'Rijeka'); 
    rec_t(2) := rec_k(30, 'Marija Perić', 'Dubrovinik'); 
    rec_t(3) := rec_k(40, 'Ivo Ivić', 'Zadar'); 
    rec_t(4) := rec_k(50, 'Ivana Žac', 'Zagreb'); 
    rec_t(5) := rec_k(55, 'Marko Marić', 'Osijek'); 
     
    FOR i IN rec_t.FIRST..rec_t.LAST  
    LOOP 
        INSERT INTO kolekcija_kupci (id, ime, city) 
        VALUES ( 
            rec_t(i).kup_id, 
            rec_t(i).kup_ime, 
            rec_t(i).kup_grad 
        ); 
    END LOOP; 
END; 

SELECT * FROM kolekcija_kupci;

--drugi primjer bez varray-a

DECLARE
    TYPE rec_k IS RECORD (
        kup_id kolekcija_kupci.id%TYPE,
        kup_ime kolekcija_kupci.ime%TYPE,
        kup_city kolekcija_kupci.city%TYPE
    );
    
    rec1 rec_k;
    rec2 rec_k;
BEGIN
    rec1 := rec_k(20, 'Petar Horvat', 'Rijeka'); 
    rec2 := rec_k(30, 'Marija Perić', 'Dubrovinik'); 
     
        INSERT INTO kolekcija_kupci (id, ime, city) 
        VALUES ( 
            rec1.kup_id, 
            rec1.kup_ime, 
            rec1.kup_city 
        ); 
        
        INSERT INTO kolekcija_kupci (id, ime, city) 
        VALUES ( 
            rec2.kup_id, 
            rec2.kup_ime, 
            rec2.kup_city 
        );
END;
/

SELECT * FROM kolekcija_kupci;

CREATE TABLE kolekcija_kupci ( 
    id INTEGER, 
    ime VARCHAR2(200), 
    city VARCHAR2(200), 
    CONSTRAINT pk_k PRIMARY KEY (id) 
);

--primjer 1

DECLARE
    TYPE tip IS RECORD(
    naziv DOBAVLJACI.ime_dobavljaca%TYPE,
    broj NUMBER);
    zapis tip;
BEGIN
    SELECT DOBAVLJACI.ime_dobavljaca, count(*)
    INTO zapis FROM PROIZVODI 
    JOIN DOBAVLJACI ON DOBAVLJACI.idDobavljac = PROIZVODI.idDobavljac
    --Promijenom id-a uvijet if se modificira.
    WHERE DOBAVLJACI.idDobavljac = 4 
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

--primjer 2 (zapis temeljen na tablici)

DECLARE
    red PROIZVODI%ROWTYPE;
BEGIN
    SELECT * INTO red 
    FROM PROIZVODI WHERE idProizvod = 1;
    DBMS_OUTPUT.PUT_LINE('Naziv proizvoda je: ' || red.naziv || ' ,dok je cijena proizvoda: ' || red.cijena);
END;

--primjer 3 (zapis temeljen na kursoru)

DECLARE
    CURSOR kursor IS
       SELECT KUPCI.ime_kupca, COUNT(NARUDZBE.idNarudzba) AS broj 
       FROM KUPCI, NARUDZBE
       WHERE KUPCI.idKupac = NARUDZBE.idKupac
       GROUP BY KUPCI.ime_kupca
       ORDER BY broj DESC;
    zapis kursor%ROWTYPE;
BEGIN
    FOR r IN kursor LOOP
        zapis := r;
        DBMS_OUTPUT.PUT_LINE('Kupac ' || zapis.ime_kupca || ' je ' || zapis.broj || ' puta napravio narudžbu.');
    END LOOP;
END;
/

--primjer 4 (korisnički definiran zapis kao i primjer 3 samo sa sys_refcursorom)

DECLARE
    TYPE tip IS RECORD (
        ime KUPCI.ime_kupca%TYPE,
        broj NUMBER);
    zapis tip;
    moj_kursor SYS_REFCURSOR;
BEGIN
    OPEN moj_kursor FOR SELECT KUPCI.ime_kupca, COUNT(NARUDZBE.idNarudzba) AS broj 
           FROM KUPCI, NARUDZBE
           WHERE KUPCI.idKupac = NARUDZBE.idKupac
           GROUP BY KUPCI.ime_kupca
           ORDER BY broj DESC;
        LOOP
            FETCH moj_kursor INTO zapis;
            EXIT WHEN moj_kursor%NOTFOUND;
            DBMS_OUTPUT.PUT_LINE('Kupac ' || zapis.ime || ' je ' || zapis.broj || ' puta napravio narudžbu.');
        END LOOP;
    CLOSE moj_kursor;
END;
/