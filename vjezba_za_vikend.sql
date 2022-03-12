SET SERVEROUTPUT ON;

declare 
    cursor c_servis is select * 
    from all_source 
    where lower(text) like '%.nextval%';
    
    broj_tabova_do_nextvala number;
    tekst_bez_nextvala varchar2(1000);
    brojac_praznina number;
    broj_tabova_do_sekvence number;
    finalni varchar2(1000);
    
    broj_korekcije number;
    broj_korekcije_finalni number;
begin
    for r in c_servis loop
        
        broj_tabova_do_nextvala := instr(lower(r.text),'.nextval', 1,1);
        broj_korekcije := broj_tabova_do_nextvala - 1;
        tekst_bez_nextvala :=substr(lower(r.text), 1, broj_korekcije);
        brojac_praznina := REGEXP_COUNT (tekst_bez_nextvala, '[ ]');
        broj_tabova_do_sekvence := instr(lower(tekst_bez_nextvala),' ', brojac_praznina, 3);
        broj_korekcije_finalni := broj_tabova_do_sekvence + 1;
        finalni := substr(tekst_bez_nextvala, broj_korekcije_finalni, 100);
        
        dbms_output.put_line(finalni);
    end loop;
end;
/

select * from all_source where lower(text) like '%nextval%';
--prvi
select instr(lower('  select  ass_seq.nextval  '),'.nextval', 1,1) trazi from dual; --18
--znači od dobivene varijable po funkciji instr moramo imati -1
select substr('  select  ass_seq.nextval  ', 1, 17) nadi from dual;

select length('  select  ass_seq.nextval  ') broj_znakova from dual;

--drugi

select instr(lower('ibis.LOG_IZVODI_TEST_seq.nextval,  '),'.nextval', 1,1) trazi from dual; --25
--znači od dobivene varijable po funkciji instr moramo imati -1
select substr('ibis.LOG_IZVODI_TEST_seq.nextval,  ', 1, 24) nadi from dual;


--PRIMJERI

--'          VALUES (sq_id_cilja_kvartalni.NEXTVAL, idnovogcilja, rstk.kvartal, rstk.naziv, rstk.opis_cilja, rstk.ponder, rstk.mjera1, rstk.mjera2, rstk.mjera3, rstk.mjera4, rstk.mjera5,'

--'    return_value := TO_CHAR(prefix||sysdate_char||LPAD(PDA_IDENTIFIER_SEQ.nextval,15,'0')); '



--PROUČAVANJE ZA VIKEND: oracle utl_file excel format
