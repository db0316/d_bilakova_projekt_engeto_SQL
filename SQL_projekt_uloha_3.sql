CREATE VIEW v_daniela_bilakova_avg_price_min_date_all AS
WITH avg_price_min_date AS
	(SELECT 
		DISTINCT food_category
		, payroll_year
		, round(avg(price)::NUMERIC, 2) AS avg_price_min_date
	FROM t_Daniela_Bilakova_project_SQL_primary_final
	WHERE 
		payroll_year IN 
		(SELECT 
			min(payroll_year)
		FROM t_Daniela_Bilakova_project_SQL_primary_final
		)
	GROUP BY
		food_category
		, payroll_year
	ORDER BY
		food_category
		, payroll_year
	),
avg_price_wine AS
	(SELECT 
		DISTINCT food_category
		, payroll_year
		, round(avg(price)::NUMERIC, 2) AS avg_price_min_date
	FROM t_Daniela_Bilakova_project_SQL_primary_final
	WHERE 
		payroll_year = 2015
		AND food_category LIKE 'Jakostní víno%'
	GROUP BY
		food_category
		, payroll_year
	ORDER BY
		food_category
		, payroll_year
	)
SELECT 
	avgmin.*
FROM 
	avg_price_min_date AS avgmin
UNION
SELECT 
	avw.*
FROM 
	avg_price_wine AS avw
;	

CREATE VIEW v_daniela_bilakova_avg_price_max_date_all AS	
WITH avg_price_max_date AS
	(SELECT 
		DISTINCT food_category
		, payroll_year
		, round(avg(price)::NUMERIC, 2) AS avg_price_max_date
	FROM t_Daniela_Bilakova_project_SQL_primary_final
	WHERE 
		payroll_year IN 
		(SELECT 
			max(payroll_year)
		FROM t_Daniela_Bilakova_project_SQL_primary_final
		)
	GROUP BY
		food_category
		, payroll_year
	ORDER BY
		food_category
		, payroll_year
	)
SELECT 
	avgmax.*
FROM 
	avg_price_max_date AS avgmax
;

SELECT 
	vavgmin.*
	, vavgmax.payroll_year
	, vavgmax.avg_price_max_date
	, round(((vavgmax.avg_price_max_date - vavgmin.avg_price_min_date) / vavgmin.avg_price_min_date) * 100, 2) AS dif_perpetual
FROM v_daniela_bilakova_avg_price_min_date_all AS vavgmin
JOIN 
	v_daniela_bilakova_avg_price_max_date_all AS vavgmax
	ON vavgmax.food_category = vavgmin.food_category
GROUP BY
	vavgmin.food_category
	, vavgmin.payroll_year
	, vavgmin.avg_price_min_date
	, vavgmax.payroll_year
	, vavgmax.avg_price_max_date
HAVING
	round(((vavgmax.avg_price_max_date - vavgmin.avg_price_min_date) / vavgmin.avg_price_min_date) * 100, 2) > 0
ORDER BY
	dif_perpetual ASC
LIMIT 1
;