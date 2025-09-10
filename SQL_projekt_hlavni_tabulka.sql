CREATE TABLE t_Daniela_Bilakova_project_SQL_primary_final AS
(SELECT
    cpc.name AS food_category
    , cp.value AS price
    , cpib.name AS industry
    , cpay.value AS average_wages
    , TO_DATE(TO_CHAR(cp.date_from, 'YYYY-MM-DD'), 'YYYY-MM-DD') AS price_measured_from
    , TO_DATE(TO_CHAR(cp.date_to, 'YYYY-MM-DD'), 'YYYY-MM-DD') AS price_measured_to
    , cpay.payroll_year
    , cpay.payroll_quarter
FROM
    czechia_price AS cp
JOIN czechia_payroll AS cpay
    ON date_part('year', cp.date_from) = cpay.payroll_year
    AND cpay.value_type_code = 5958
    AND cpay.calculation_code = 200 -- omezeni na pouze prepocteny pocet zamestnancu
    AND cp.region_code IS NULL
JOIN czechia_price_category AS cpc
    ON cp.category_code = cpc.code
JOIN czechia_payroll_industry_branch AS cpib    
    ON cpay.industry_branch_code = cpib.code
)
;