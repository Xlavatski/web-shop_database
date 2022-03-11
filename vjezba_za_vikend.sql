SET SERVEROUTPUT ON;

declare
    cursor c_stavke is 
    select name ,text
    from all_source 
    where lower(text) like '%nextval%'
    and lower(text) like '%forma%';
        
begin
    for stavke in c_stavke 
    loop
    dbms_output.put_line('Text ' || stavke.name);
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