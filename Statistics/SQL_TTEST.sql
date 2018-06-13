-----------------------------------------------------------------------------------------------------------------
/*
  Która ze zmiennych ma największy wpływ na odpowiedź od operatora?
  Opóźnienie
  Linia lotnicza
  Kanał
  Jakie są wartości IV dla tych zmiennych?
  Którą z nich można uwzględnić przy analizie wpływu na akceptację wniosków?
  Której z nich nie można uwzględnić przy analizie wpływu na akceptację wniosków?
 */
 with moje_dane as (
  select
    --coalesce(s2.identyfikator_operator_operujacego, s2.identyfikator_operatora),
    --w.opoznienie,
    w.kanal,
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

-- opoznienie 0.1960792320467744644610048291333167736907 - srednio istotne, bierzemy pod uwage
-- linia lotnicza 1.1502074146890459201620677649085395604269, 0.9655332735256450845103730292629853218365 - zbyt mocno istotne, autokorelacja
-- kanal 0.0685644409026360614069272053856187269757 - bardzo slabo skorelowane, nie bierzemy pod uwage


----------------------------------------------------------------------------------------------------------------------------------
/*
  Czy istnieje znacząca różnica między acceptance rate operatora w pierwszym i ostatnim kwartałem 2017 roku?
  Kroki:
  Jakich kolumn potrzebujesz?
  Z jakich tabel weźmiesz dane?
  Jak policzysz acceptance rate dla Q1 2017?
  Jak policzysz acceptance rate dla Q4 2017?
  Po czym pogrupujesz?
  Jak skopiujesz dane do arkusza?
  Jak wykonasz ttest?
  tail?
  type?
  Jak zinterpretujesz wynik?
 */

 select
  coalesce(s2.identyfikator_operator_operujacego, s2.identyfikator_operatora),
  count(case when to_char(ao.data_odpowiedzi,'YYYYQ') = '20171' and ao.status_odp = 'zaakceptowany' then w.id end)/
    nullif(count(case when to_char(ao.data_odpowiedzi,'YYYYQ') = '20171' then w.id end),0)::numeric q1,
  count(case when to_char(ao.data_odpowiedzi,'YYYYQ') = '20174' and ao.status_odp = 'zaakceptowany' then w.id end)/
    nullif(count(case when to_char(ao.data_odpowiedzi,'YYYYQ') = '20174' then w.id end),0)::numeric q4
from wnioski w
join analiza_operatora ao on ao.id_wniosku = w.id
join podroze p ON w.id = p.id_wniosku
join szczegoly_podrozy s2 ON p.id = s2.id_podrozy
where s2.czy_zaklocony = true
group by 1
order by 2 desc;