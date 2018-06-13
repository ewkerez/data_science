

select count(1), status
from wnioski
  JOIN analizy_wnioskow a ON wnioski.id = a.id_wniosku
where status = 'zaakceptowany' OR status = 'odrzucony'
GROUP BY 2;
----------
SELECT  stan_wniosku, count(1)
FROM wnioski
GROUP BY 1;
-- liczymy z tego procent
SELECT  stan_wniosku, count(1) policz, sum(count(1)) over(),
  round(count(1)/sum(count(1)) OVER() *100,2)
FROM wnioski
GROUP BY 1
ORDER BY 2 DESC ;

SELECT to_char(data_utworzenia, 'YYYY-MM') data_utw, stan_wniosku, count(1)
FROM wnioski
GROUP BY 1, 2
;
-----------------------------------------------------------------------------------------------------------------------------------------------------
-- 35---------------------------------------------------------------------------------------------------------------------------------------------
-- Jaki jest % stosunek typu wniosków?
SELECT typ_wniosku, count(1), sum(count(1)) OVER (),
  round(count(1)/sum(count(1)) OVER () *100, 2)
from wnioski
GROUP BY 1
ORDER BY 2 DESC ;
-- * A JAK ROZKŁADA SIĘ TO WCZASIE ?
SELECT to_char(data_utworzenia, 'YYYY-MM') data_utw, typ_wniosku, count(1)
FROM wnioski
GROUP BY 1, 2
;

-- select count(w.id) wszystkie,
-- count(a.id) ocenione,
-- count(a.id)/count(w.id)::numeric procent_ocenionych,
-- count(case when a.status = 'zaakceptowany' then a.id end)/count(w.id)::numeric proc_zaakc,
-- count(case when a.status = 'zaakceptowany' then a.id end)/count(a.id)::numeric
-- proc_zaakc_z_ocenionych
-- from wnioski w
-- left join analizy_wnioskow a ON w.id = a.id_wniosku;   -- pomocniczo przykład z zajęć




-- JD8- 7.
-- % zależność między kwotami 250/400/600 ////////jak sie ukalda w czasie???
-- najpierwsz zaleznosci procentowe miedzy kwotami ile ich jest w ogole
SELECT kwota, count(1), sum(count(1)) OVER (),
  round(count(1)/ sum(count(1)) over() *100, 2)
from szczegoly_rekompensat
where kwota in (250,400,600)
GROUP BY 1;


-- IV------------------------------
with dane_opoznienie as(
SELECT DISTINCT
 opoznienie,
 count(1)                               wszystkie,
 count(CASE WHEN status_odp != 'zaakceptowany'
   THEN w.id END)                       odrzucone,
 (count(CASE WHEN status_odp != 'zaakceptowany'
   THEN w.id END) / count(1) :: NUMERIC)*100 proc_odrzuc,
 count(CASE WHEN status_odp = 'zaakceptowany'
   THEN w.id END)                       zaakceptowane,
 (count(CASE WHEN status_odp = 'zaakceptowany'
   THEN w.id END) / count(1) :: NUMERIC)*100 proc_zaakc
FROM wnioski w
 JOIN analiza_operatora ao ON ao.id_wniosku = w.id
GROUP BY 1
ORDER BY 1)

select *
FROM dane_opoznienie ;


-- 42(Information value) Która ze zmiennych ma największy wpływa na odp od operatora?
with dane_opoznienie as(
SELECT  DISTINCT opoznienie, count(1) wszystkie,
  count(CASE when status_odp != 'zaakceptowany' THEN w.id End ) odrzucone,
  count(CASE when status_odp = 'zaakceptowany' THEN w.id END) zaakceptowane
from wnioski w
JOIN analiza_operatora ao ON ao.id_wniosku = w.id
GROUP BY 1
ORDER BY 1),
statystyka AS (
SELECT *,
  round(odrzucone/sum(odrzucone) OVER ():: NUMERIC, 6) DB,
  round(zaakceptowane/sum(zaakceptowane) OVER ():: NUMERIC, 6 )DG,
  ln((zaakceptowane/sum(zaakceptowane) OVER ():: NUMERIC)/(odrzucone/sum(odrzucone) OVER ():: NUMERIC)) WOE
FROM dane_opoznienie
)

SELECT * ,
  dg-db as "dg-db" , (dg-db)*WOE as "(dg-db)*WOE ", sum((dg-db)*WOE) OVER () as SUM_IV
From statystyka
;


with dane_operator as(
SELECT  coalesce(s2.identyfikator_operator_operujacego, s2.identyfikator_operatora) as operator,
  count(1) wszystkie,
  count(CASE when status_odp != 'zaakceptowany' THEN w.id End ) odrzucone,
  count(CASE when status_odp = 'zaakceptowany' THEN w.id END) zaakceptowane
from wnioski w
JOIN analiza_operatora ao ON ao.id_wniosku = w.id
JOIN podroze p ON w.id = p.id_wniosku
JOIN szczegoly_podrozy s2 ON p.id = s2.id_podrozy
GROUP BY 1
ORDER BY 2 DESC ),
statystyka AS (
SELECT *,
  round(odrzucone/sum(odrzucone) OVER ():: NUMERIC, 6) DB,
  round(zaakceptowane/sum(zaakceptowane) OVER ():: NUMERIC, 6 )DG,
  ln((zaakceptowane/sum(zaakceptowane) OVER ():: NUMERIC)/(odrzucone/sum(odrzucone) OVER ():: NUMERIC)) WOE
FROM dane_operator
)
SELECT * ,
  dg-db as "dg-db" , (dg-db)*WOE as "(dg-db)*WOE ", sum((dg-db)*WOE) OVER () as SUM_IV
From statystyka
;

with dane_operator as(
SELECT  coalesce(s2.identyfikator_operator_operujacego, s2.identyfikator_operatora) as operator,
 count(1)                               wszystkie,
 count(CASE WHEN status_odp != 'zaakceptowany'
   THEN w.id END)                       odrzucone,
 (count(CASE WHEN status_odp != 'zaakceptowany'
   THEN w.id END) / count(1) :: NUMERIC)*100 proc_odrzuc,
 count(CASE WHEN status_odp = 'zaakceptowany'
   THEN w.id END)                       zaakceptowane,
 (count(CASE WHEN status_odp = 'zaakceptowany'
   THEN w.id END) / count(1) :: NUMERIC)*100 proc_zaakc
FROM wnioski w
 JOIN analiza_operatora ao ON ao.id_wniosku = w.id
  JOIN podroze p ON w.id = p.id_wniosku
JOIN szczegoly_podrozy s2 ON p.id = s2.id_podrozy
GROUP BY 1
ORDER BY 2 DESC )

select *
FROM dane_operator ;



with dane_kanal as(
SELECT  kanal,
  count(1) wszystkie,
  count(CASE when status_odp != 'zaakceptowany' THEN w.id End ) odrzucone,
  count(CASE when status_odp = 'zaakceptowany' THEN w.id END) zaakceptowane
from wnioski w
JOIN analiza_operatora ao ON ao.id_wniosku = w.id
JOIN podroze p ON w.id = p.id_wniosku
JOIN szczegoly_podrozy s2 ON p.id = s2.id_podrozy
WHERE s2.czy_zaklocony = TRUE
GROUP BY 1
ORDER BY 1),
statystyka AS (
SELECT *,
  round(odrzucone/sum(odrzucone) OVER ():: NUMERIC, 6) DB,
  round(zaakceptowane/sum(zaakceptowane) OVER ():: NUMERIC, 6 )DG,
  ln((zaakceptowane/sum(zaakceptowane) OVER ():: NUMERIC)/(odrzucone/sum(odrzucone) OVER ():: NUMERIC)) WOE
FROM dane_kanal
)
SELECT * ,
  dg-db as "dg-db" , (dg-db)*WOE as "(dg-db)*WOE ", sum((dg-db)*WOE) OVER () as SUM_IV
From statystyka
;

with dane_kanal as(
SELECT  kanal,
 count(1)                               wszystkie,
 count(CASE WHEN status_odp != 'zaakceptowany'
   THEN w.id END)                       odrzucone,
 (count(CASE WHEN status_odp != 'zaakceptowany'
   THEN w.id END) / count(1) :: NUMERIC)*100 proc_odrzuc,
 count(CASE WHEN status_odp = 'zaakceptowany'
   THEN w.id END)                       zaakceptowane,
 (count(CASE WHEN status_odp = 'zaakceptowany'
   THEN w.id END) / count(1) :: NUMERIC)*100 proc_zaakc
FROM wnioski w
 JOIN analiza_operatora ao ON ao.id_wniosku = w.id
  JOIN podroze p ON w.id = p.id_wniosku
JOIN szczegoly_podrozy s2 ON p.id = s2.id_podrozy
  where s2.czy_zaklocony = TRUE
GROUP BY 1
ORDER BY 1 )

select *
FROM dane_kanal ;




-- ROZWIĄZANIE PIOTRA
 with moje_dane as (
  select
    coalesce(s2.identyfikator_operator_operujacego, s2.identyfikator_operatora),
--     w.opoznienie,
--     w.kanal,
  count(1),
  count(case when ao.status_odp ilike 'odrzucony%' then w.id end) bad,
  count(case when ao.status_odp ilike 'zaakceptowany' then w.id end) good,
  count(case when ao.status_odp ilike 'odrzucony%' then w.id end) / sum(count(case when ao.status_odp ilike 'odrzucony%' then w.id end)) over()::numeric bad_pct,
  count(case when ao.status_odp ilike 'zaakceptowany' then w.id end) / sum(count(case when ao.status_odp ilike 'zaakceptowany' then w.id end)) over()::numeric good_pct,
  ln(
      (count(case when ao.status_odp ilike 'zaakceptowany' then w.id end) / sum(count(case when ao.status_odp ilike 'zaakceptowany' then w.id end)) over()::numeric) /
      (count(case when ao.status_odp ilike 'odrzucony%' then w.id end) / sum(count(case when ao.status_odp ilike 'odrzucony%' then w.id end)) over()::numeric)
  ) woe,
  (
    count(case when ao.status_odp ilike 'zaakceptowany' then w.id end) / sum(count(case when ao.status_odp ilike 'zaakceptowany' then w.id end)) over()::numeric -
    count(case when ao.status_odp ilike 'odrzucony%' then w.id end) / sum(count(case when ao.status_odp ilike 'odrzucony%' then w.id end)) over()::numeric
  ) * ln(
      (count(case when ao.status_odp ilike 'zaakceptowany' then w.id end) / sum(count(case when ao.status_odp ilike 'zaakceptowany' then w.id end)) over()::numeric) /
      (count(case when ao.status_odp ilike 'odrzucony%' then w.id end) / sum(count(case when ao.status_odp ilike 'odrzucony%' then w.id end)) over()::numeric)
  ) iv
from wnioski w
join analiza_operatora ao on ao.id_wniosku = w.id
join podroze p ON w.id = p.id_wniosku
join szczegoly_podrozy s2 ON p.id = s2.id_podrozy
where s2.czy_zaklocony = true
group by 1
order by 2 desc
  )

select *, sum(iv) over() iv from moje_dane;

-- &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&        TESTY         &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&


---------------Liczba wniosków w zależności od operatora i czasu ---------------
-- Liczba wniosków w zależności od operatora (operator ale i operator operujący
-- UWAGA by nie wziąć operatora operującego w momencie gdy nie matakiego np NULL bedzie)
-- i czasu (najlepiej po miesiącach np. w styczniu sprzedaliśmy N wniosków od regio)---------------



---Obliczam liczbe wnioskow---

---Wynik liczbowy wnioskow wg operatora ---
  SELECT count(w.id),
  coalesce(identyfikator_operator_operujacego, identyfikator_operatora) operat_pkp
FROM wnioski w
JOIN podroze p ON w.id = p.id_wniosku
JOIN szczegoly_podrozy s2 ON p.id = s2.id_podrozy
GROUP BY 2
ORDER BY 1;
---------------------------------------------


---Rozkład procentowy wg. mieisęcy i operatora---

WITH operator_czas as (   ----dajemy WITH by ładnie sobie wyświetlić wartości po miesiącach
SELECT to_char(w.data_utworzenia, 'YYYY-MM') miesiecznie, --wybieram daty po miesiącach i latach (numerycznie) tego nie będzie w finałowej wersji
  to_char(w.data_utworzenia, 'YYYY Month') rok_miesiac,--wybieram daty po miesiącach (nazwy miesięcy słownie) i latach (numerycznie) co będzie służyło finalnie w tabeli finalnej
    coalesce(identyfikator_operator_operujacego, identyfikator_operatora) operat_pkp, --scalam kolemnę w ten sposób by IOO(identyfikator_operator_operujacego) jest operatorem który wiezie pasażerów a IO(identyfikator_operatora) nie zawsze jest operatorem wożącym pasażerów.
    count(w.id) liczba_w, --liczę wnioski
  sum(count(4)) OVER (PARTITION BY to_char(w.data_utworzenia, 'YYYY-MM')) suma_mieieczna, --tu mam sumę wniosków tylko by sobie sprawdzić
  count(4)/sum(count(4)) OVER (PARTITION BY to_char(w.data_utworzenia, 'YYYY-MM'))procent_miesiecznie --wartość procentowa rozkłądu wnjiosków operatora na miesiąc
FROM wnioski w
JOIN podroze p ON w.id = p.id_wniosku
JOIN szczegoly_podrozy s2 ON p.id = s2.id_podrozy
GROUP BY 1, 2, 3
ORDER BY 1)
  SELECT rok_miesiac, operat_pkp, liczba_w, procent_miesiecznie --wyświetlam tabelkę finalną bez pól które nie są obowiżakowe
FROM operator_czas;

--  TTEST
select
  to_char(data_utworzenia, 'YYYY-MM'), -- będe szukała zależności pomiędzy kolejnymi miesiącami
  COUNT(CASE WHEN kanal = 'bezposredni' then id END ) wnioskibezposrednie, --obliczam sumę wniosków bezposrednich
  count(CASE WHEN kanal = 'posredni' then id END ) wnioskiposrednie -- obliczam sumę wniosków bezpośrednich
from wnioski
GROUP BY 1 ;-- grupuje po dacie
--reszte zadania obsługuje excel



--  AKTYWNOŚĆ AGENTÓW

-- liczba odrzuconych / zaakceptowanych / wniosków
with wniosekagenta as(
select id_agenta, count(w.id),
  count(CASE WHEN aw.status = 'odrzucony' then w.id END ) wnioski_odrzucone,
  count(CASE WHEN aw.status = 'zaakceptowany' then w.id END ) wnioski_zaakceptowane
from wnioski w
JOIN analizy_wnioskow aw ON w.id = aw.id_wniosku
GROUP BY 1
),
  --liczba zapytań o dokumenty
  dokumentyagenta as(
  SELECT agent_id, count(1) oczekiwane_dokumenty
  FROM dokumenty
    GROUP BY 1
  ),
  --- liczba przeprocesowanych odpowiedzi linii
  procesowanelinie AS (
  SELECT agent_id,
    count(CASE WHEN status_odp='zaakceptowany' then id_wniosku end) odpowiedz_pozytywna,
    count(CASE WHEN status_odp='odrzucony nieslusznie' then id_wniosku end) odpowiedz_odrz_niesl,
    count(CASE WHEN status_odp='odrzucony slusznie' then id_wniosku end) odpowiedz_odrz_slusz
    from analiza_operatora
    GROUP BY 1
  ),
  -- liczba analiz prawniczych
  analizyprawnicze AS (
  SELECT agent_id,
    COUNT(CASE WHEN status_sad='zaakceptowany' then id_wniosku end) zaakceptowanesad,
    COUNT(CASE WHEN status_sad='przegrany' then id_wniosku end) przegranesad
    FROM analiza_prawna
    GROUP BY 1
  )

--wyswietlenie wszystkich wymaganych kolumn,laczenie podzapytan
select wa.*,da.oczekiwane_dokumenty,odpowiedz_pozytywna,odpowiedz_odrz_niesl,odpowiedz_odrz_slusz,
  zaakceptowanesad,przegranesad
from wniosekagenta wa
LEFT JOIN dokumentyagenta da on da.agent_id=wa.id_agenta
LEFT JOIN procesowanelinie pl on pl.agent_id=wa.id_agenta
LEFT JOIN analizyprawnicze ap on ap.agent_id=wa.id_agenta
ORDER BY 2 DESC;
