
create table test_partije (
    id number generated always as identity primary key,
    iban_broj varchar2(200) not null,
    vazi_do date,
    status_valute number
); 

select * from test_partije;

insert into test_partije(iban_broj, vazi_do, status_valute) VALUES ('HR555',date '2022-01-14', 5);
insert into test_partije(iban_broj, vazi_do, status_valute) VALUES ('HR555', date '2022-01-14', 5);

insert into test_partije(iban_broj, vazi_do, status_valute) VALUES ('HR333',null, 5);
insert into test_partije(iban_broj, vazi_do, status_valute) VALUES ('HR3333', null, 6);


insert into test_partije(iban_broj, vazi_do, status_valute) VALUES ('HR3333',date '2022-01-14', 5);
insert into test_partije(iban_broj, vazi_do, status_valute) VALUES ('HR333', null, 6);

insert into test_partije(iban_broj, vazi_do, status_valute) VALUES ('HR1234',date '2022-01-14', 6);
insert into test_partije(iban_broj, vazi_do, status_valute) VALUES ('HR1234', null, 5);

--finalni
with podaci as (
    SELECT
    id, 
    iban_broj,
    vazi_do,
    status_valute,
    case 
        when vazi_do is null and status_valute = 6 then 'jedan'
        when vazi_do is not null and status_valute = 6 then 'dva'
        when vazi_do is null and status_valute <> 6 then 'tri'
        when vazi_do is not null and status_valute <> 6 then 'cetri'
    end test
FROM test_partije
where iban_broj = 'HR3333'
)
select * from 
(
    select podaci.iban_broj, podaci.vazi_do, podaci.status_valute, podaci.test 
    from podaci
)
pivot 
(
    count(test)
    for test in('jedan', 'dva', 'tri', 'cetri')
)
--group by iban_broj
;



SET SERVEROUTPUT ON;
--https://stackoverflow.com/questions/21286245/extract-email-from-field-using-oracle-regexp
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

--funkije za pronalaženje grešaka

when others then
  Dbms_Output.put_line ( DBMS_UTILITY.FORMAT_ERROR_STACK() );
  Dbms_Output.put_line ( DBMS_UTILITY.FORMAT_ERROR_BACKTRACE() );

--skripta za čitanje i pisanje excal file-a 

declare
    -- treba sigurno
    l_file_out varchar2(100) := 'nova_lista_Dino' || to_number(to_char(systimestamp, 'hh24miss')) || '.csv';
    l_file_in varchar2(100) := 'ticket_skripta.csv';
    f_log utl_file.file_type;
    f_load utl_file.file_type;
    
    --možda i ne treba nešto
    type t_array is table of varchar2(200) index by binary_integer;
    l_arr t_array;
    
    l_ulaz varchar2(4000);
    l_preskok number := 0;
    l_count number := 0;
    e_izlaz exception;
    
    --Polja
    t_maticni_broj number;
    
    t_tip_klijenta varchar2(1000);
    t_vazi_od date;
    t_vazi_do date;
    t_naziv_opcine varchar2(100);
    t_naziv_zupanije varchar2(100);
    t_naziv_drzave varchar2(100);
    
    --t_opis varchar2(1000);
    
    --Funkcija
    function split (p_in_string varchar2, p_delim varchar2) return t_array  
       is 
          i       number :=0; 
          pos     number :=0; 
          lv_str  varchar2(50) := p_in_string;    
          strings t_array;     
       begin 
          -- determine first chuck of string   
          pos := instr(lv_str,p_delim,1,1); 
          -- while there are chunks left, loop  
         while ( pos != 0) loop 
            -- increment counter  
            i := i + 1;    
            -- create array element for chuck of string  
            strings(i) := substr(lv_str,1,pos-1); 
            -- remove chunk from string  
            lv_str := substr(lv_str,pos+1,length(lv_str)); 
            -- determine next chunk  
            pos := instr(lv_str,p_delim,1,1); 
            -- no last chunk, add to array  
            if pos = 0 then 
               strings(i+1) := lv_str; 
            end if;    
         end loop;    
         -- return array  
         return strings;    
    end split;
begin
    -- u begin bloku – otvaranje excela
    f_log := utl_file.fopen('PL_OUT', l_file_out, 'W'); -- write (novi excel)
    f_load := utl_file.fopen('PL_IN', l_file_in, 'R'); -- read
    
    --ako ne radi ovo makni
    utl_file.put_line(f_log,'TIP_KLIJENTA '||';'||'DATUM_AKTIVACIJE '||';'|| 'DATUM_DEAKTIVACIJE ' ||';'|| 'NAZIV_OPCINE '||';'|| 'NAZIV_ZUPANIJE '||';'|| 'NAZIV_DRZAVE');
    loop 
        utl_file.get_line(f_load, l_ulaz);
        if l_preskok = 0 then
            l_preskok := 1;
            continue;
        end if;
        l_arr := split(l_ulaz, ';');
        --Polja iz file-a 
        t_maticni_broj := to_number(l_arr(1));
        
        --dbms_output.put_line(t_maticni_broj);
         begin
            select count(*) into l_count
            from klijenti k
            where k.maticni_broj = t_maticni_broj;
            --za log
            if l_count = 0 then
                --dbms_output.put_line('Nepoznat klijent: ' || t_maticni_broj);
                utl_file.put_line(f_log,'Nepoznat klijent;' || t_maticni_broj);--Navesti polja za log
                continue;
            elsif l_count > 1 then
                --dbms_output.put_line('Vise od 1: ' || t_maticni_broj);
                utl_file.put_line(f_log,'Vise od 1;' || t_maticni_broj);--Navesti polja za log
                continue;
                --else 
                --dbms_output.put_line('Učitan ' || t_maticni_broj);
            end if;
            
            begin
                select 
                    k.tip_klijenta || ' - ' || (select opis from cg_ref_codes_v where naziv = 'TIP KLIJENTA' and vrijednost = k.tip_klijenta )tip_klijenta, 
                    k.vazi_od datum_aktivacije, 
                    k.vazi_do datum_deaktivacije, 
                    og.naziv naziv_opcine, 
                    z.naziv naziv_zupanije,
                    d.naziv naziv_drzave
                into t_tip_klijenta, t_vazi_od, t_vazi_do, t_naziv_opcine, t_naziv_zupanije, t_naziv_drzave
                from klijenti k join klijenti_adrese ad on k.id = ad.kli_id
                join adrese a on a.id = ad.ade_id
                join mjesta m on a.mje_id = m.id
                join drzave d on k.drz_id = d.id
                join opcine_gradovi og on og.id = m.opg_id
                join zupanije z on z.id = og.zup_id
                where k.maticni_broj = t_maticni_broj AND ad.tip_adrese = 91 and ad.vazi_do is null;
                
                exception
                when others then
                    utl_file.put_line(f_log,'ERR;'||sqlerrm || t_maticni_broj);--Navesti polja za log
                    --dbms_output.put_line('ERR;'||sqlerrm || t_maticni_broj);
                    continue;
            end;
            
            -- pisanje jednog retka
            utl_file.put_line(f_log,t_tip_klijenta||';'||t_vazi_od||';'|| t_vazi_do ||';'||commons.f_cro_alpha_converter(t_naziv_opcine)||';'||commons.f_cro_alpha_converter(t_naziv_zupanije)||';'|| commons.f_cro_alpha_converter(t_naziv_drzave));
            --dbms_output.put_line(t_tip_klijenta||';'||t_vazi_od||';'|| t_vazi_do ||';'||t_naziv_opcine||';'||t_naziv_zupanije||';'||t_naziv_drzave);
            /*exception 
            when others then
                dbms_output.put_line('Nema podataka za;' || t_maticni_broj ||':::'||DBMS_UTILITY.FORMAT_ERROR_STACK||'-'||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
                --utl_file.put_line(f_log,'Nema podataka za;' || t_maticni_broj ||':::'||DBMS_UTILITY.FORMAT_ERROR_STACK||'-'||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);--Navesti polja za log
         continue;*/ 
        end;
        end loop;
    -- na kraju programa zatavaranje oba
    utl_file.fclose(f_load);
    utl_file.fclose(f_log);
    exception
     when no_data_found then null ;
     when others then 
     dbms_output.put_line(SQLERRM);   
       utl_file.fclose(f_load);
       utl_file.fclose(f_log);
end;
/

