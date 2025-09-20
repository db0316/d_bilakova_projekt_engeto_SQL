WITH avg_payroll_max_date AS 
	(SELECT 
		round(avg(dbprimar.average_wages)::NUMERIC, 2) AS avg_payroll_max_date -- pro zjednoduseni avg za vsechna obvetvi (nemam k dispozici hodnotu NULL)
	FROM 
		t_Daniela_Bilakova_project_SQL_primary_final AS dbprimar
	WHERE 
		payroll_year IN 
		(SELECT 
			max(payroll_year)
		FROM t_Daniela_Bilakova_project_SQL_primary_final AS dbprimar
		)
		AND payroll_quarter = 4
		),
avg_payroll_min_date AS
	(SELECT 
		round(avg(dbprimar.average_wages)::NUMERIC, 2) AS avg_payroll_min_date -- pro zjednoduseni avg za vsechna obvetvi (nemam k dispozici hodnotu NULL)
	FROM 
		t_Daniela_Bilakova_project_SQL_primary_final AS dbprimar
	WHERE 
		payroll_year IN 
		(SELECT 
			min(payroll_year)
		FROM t_Daniela_Bilakova_project_SQL_primary_final AS dbprimar
		)
		AND payroll_quarter = 1
	),
food_category_price_min_date AS
	(SELECT 
		food_category
		, price AS price_min_date
		, price_measured_to AS prices_measured_min_date
	FROM t_Daniela_Bilakova_project_SQL_primary_final AS dbprimar
	WHERE 
		price_measured_to IN 
		(SELECT 
			min(price_measured_to)
		FROM t_Daniela_Bilakova_project_SQL_primary_final AS dbprimar
		)
		AND 
		(food_category LIKE 'Mléko%'
		OR food_category LIKE 'Chléb%'
		)
		AND industry LIKE 'Kulturní, zábavní a rekr%'
		AND payroll_quarter = 1	
	),
food_category_price_max_date AS
	(SELECT 
		food_category
		, price AS price_max_date
		, price_measured_to AS prices_measured_max_date
	FROM t_Daniela_Bilakova_project_SQL_primary_final AS dbprimar
	WHERE 
		price_measured_to IN 
		(SELECT 
			max(price_measured_to)
		FROM t_Daniela_Bilakova_project_SQL_primary_final AS dbprimar
		)
		AND 
		(food_category LIKE 'Mléko%'
		OR food_category LIKE 'Chléb%'
		)
		AND industry LIKE 'Kulturní, zábavní a rekr%'
		AND payroll_quarter = 4
	)
SELECT 
	fcmin.food_category
	, fcmin.price_min_date
	, avgmin.avg_payroll_min_date
	, round((avgmin.avg_payroll_min_date / fcmin.price_min_date)::NUMERIC, 2) AS pocet_min_date 
	, fcmax.price_max_date
	, avgmax.avg_payroll_max_date
	, round((avgmax.avg_payroll_max_date / fcmax.price_max_date)::NUMERIC, 2) AS pocet_max_date 
FROM 
	avg_payroll_max_date AS avgmax 
	, avg_payroll_min_date AS avgmin
	, food_category_price_min_date AS fcmin
JOIN 
	food_category_price_max_date AS fcmax
	ON fcmin.food_category = fcmax.food_category
;