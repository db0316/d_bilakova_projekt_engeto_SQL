CREATE TABLE t_Daniela_Bilakova_project_SQL_secondary_final AS
(SELECT 
	e.*
	, c.continent
FROM economies AS e
JOIN
	countries AS c 
	ON c.country = e.country
	AND c.continent = 'Europe'
	AND e.gdp IS NOT NULL
ORDER BY
	country ASC
	, "year" ASC
)
;