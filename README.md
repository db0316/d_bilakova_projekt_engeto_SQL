# d_bilakova_projekt_engeto_SQL
## Zadání projektu ##
Projekt simuluje situaci, kdy našemu analytickému oddělení nezávislé společnosti, která se zabývá životní úrovní občanů, pomáhám odpovědět pár definovaných výzkumných otázek, které adresují dostupnost základních potravin široké veřejnosti. Vydefinované základní otázky a odpovědi na ně budou předány tiskovému oddělení, jež bude data prezentovat na konferenci zaměřené na tuto oblast. Mým úkolem je připravit robustní datové podklady, ve kterých bude možné vidět porovnání dostupných potravin na základě průměrných příjmů za určité časové období. 

Jako dodatečný materiál mám za úkol připravit rovněž i tabulku s HDP, GINI koeficientem a populací dalších evropských států ve stejném období, jako primární přehled pro ČR. 

Primární data vychází z veřejně dostupných zdrojů, které již moji kolegové připravili do tabulek v databázi.


## Hlavní a sekundární tabulka ##
Veškeré dotazy jsou volány z hlavní a sekundární tabulky. Sekundární tabulka obsahuje data platná pouze pro evropské země, přičemž protože se ptáme na HDP, jsou výsledky omezeny pouze na hodnoty obsahující tuto inforamci.

Hlavní tabulka spojuje v zásadě dva primární zdroje informací (czechia_price a czechia_payroll), přičemž párovací znak je společné datum, kdy máme data k dispozici (tj. 1Q/2006 - 4Q/2018). Výsledná tabulka je dále omezena (ne)znalostí názvů jednotlivých kategorií potravin. Průměrné ceny potravin jsou pak brány za celou republiku (tedy hodnota v části kraj je NULL). U průměrných mezd pak beru hodnoty za jednotlivá odvětví, takže průměrná mzda (v primární tabulce je u odvětví hodnota NULL), se v mé hlavní tabulce neobjevuje. V SQL dotazech tedy průměrnou mzdu počítám jako prostý aritmetický průměr za všechna odvětví; tato hodnota se od průměrné mzdy v primární tabulce mírně liší.

POZOR - V jednotlivých obdobích ale není stejný počet záznamů, a to z následujících důvodů:

1.  V průběhu analyzovaného období se měnila metrika cen potravin. Za  období 2006 až 2008 včetně jsou data na týdenní bázi. V letech 2009 a 2010 jsou k dispozici data jednou za 14 dní a od roku 2011 se měří pouze 1x měsíčně.
2. U kategorie kapr živý se jedná o sezónní prodej (období Vánoc), proto nejsou k dispozici data za celý rok.
3. U kategorie jakostní víno bílé jsou data o cenách k dispozici pouze za období 2015-2018.

## Otázky a jejich řešení ##
### 1. úloha ###
Otázka: 
Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?

Zvolený postup: 
Pomocí funkce LAG zjišťuji meziroční rozdíl průměrných mezd v jednotlivých odvětvích. Případům, kdy došlo k poklesu, je dán příznak 1, nepravda je označena 0 (diff_flag). Nakonec vyhledám ty případy, kde suma všech těchto příznaků je 0 pro zjištění odvětví, kde v průběhu analyzovaného období nenastal pokles mezd. 

Odpověď: 
Za analyzované období mzdy kontinuálně rostly pouze ve třech odvětvích:
1. Ostatní činnosti, 
2. Zdravotní a sociální péče,
3. Zpracovatelský průmysl.

Ve všech ostatních odvětvích došlo alespoň jednou k meziročnímu poklesu mezd v rámci celého sledovaného období.


### 2. úloha ###
Otázka:
Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?

Zvolený postup:
Pro zjištění průměrných mezd v prvním a posledním srovnatelném období používám prostý aritmetický průměr hodnot v daném období za všechna odvětví. Hledané období volám přes funkce max a min. U vybraných kategorií potravin pak hodnoty za zvolené období zjišťuji opět přes použití funkce max a min s tím, že přidávám dále omezení pouze na jeden kvartál a odvětví. Hledaný počet litrů mléka / kilogramů chleba pak zjišťuji jako podíl vypočtené průměrné mzdy a průměrné jednotkové ceny potraviny.

Odpověď: 
Při zohlednění průměrných mezd za všechna odvětví (prostý aritmetický průměr) bylo možné v 1Q/2006 koupit 1.402,53 l mléka a 1.342,33 kg chleba. Na konci analyzovaného období (tj. 4Q/2018) bylo možné díky výrazně vyššímu růstu mezd za průměrnou mzdu pořídit 1.795,58 l mléka a 1.418,90 kg chleba.

### 3. úloha ###
Otázka:
Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)? 

Zvolený postup:
Porovnávám průměrnou cenu za jednotlivé kategorie potravin v prvním a posledním období, kdy mám data k dispozici. Vzhledem k tomu, že u jedné kategorie potravin (jakostní víno) jsou data k dispozici až od roku 2015, je hodnota za první známé období volána v samostatném pomocném výpočtu. Výsledná hodnota je tedy volána přes dvě view - průměrné ceny za první známé období a průměrné ceny za poslední známé období. Jelikož některé kategorie v průběhu let zlevnily, je výsledný dotaz omezen přes HAVING na pouze takové hodnoty, kde je percentuální nárůst kladný, data jsou následně seřazena vzestupně a omezena na první hodnotu.

Odpověď:
Za analyzované nejpomaleji zdražily banány (nárůst mezi lety 2006 a 2018 činí 7,36%).

### 4. úloha ###
Otázka:
Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?

Zvolený postup:
Vzhledem k tomu, že výpočet byl použit i pro úlohu č. 5, jsou data volána přes view. Meziroční vývoj cen potravin a mezd je zjišťován přes použití funkce LAG. Báze je roční (ORDER BY payroll_year), takže porovnávám průměrné hodnoty za celé období (prostý aritmetický průměr všech hodnot za zvolený rok).
V prvním kroku zjistím zvlášť meziroční vývoj cen potravit a mezd v procentech. Následně, protože předpokládám, že zadavatel chce ve skutečnosti znát rozdíl v procentních bodech, tyto hodnoty od sebe odečítám. K tomuto rozdílu dávám příznak, zda je hodnota větší jak 10. 

Odpověď:
Předpokládám, že zvýšení mělo být měřeno v procentních bodech (tedy zda je rozdíl dvou hodnot v procentech vyšší jak 10 bodů). Bylo zjištěno, že za analyzované období nedošlo k takto výrazně vyššímu nárůstu cen potravin oproti růstu mezd. 

### 5. úloha ###
Otázka:
Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin či mzdách ve stejném nebo následujícím roce výraznějším růstem?

-- pomocné - za výraznější růst považuji meziroční nárůst o 5%

Zvolený postup:
Pro zjištění vývoje cen potravin a mezd vycházím z view z úlohy 4. K tomu přidám view o vývoji HDP v České republice za potřebná období opět při použití funkce LAG. Vzhledem k tomu, že dotaz řeší vazbu HDP na vývoj v daném a následujícím roce, je období pro tabulku HDP zvoleno na 2003-2018. 

Dotaz nijak přesněji neurčuje, co se myslí pojmem výraznější růst. Zvolila jsem si tedy jako hranici 5 %. Výsledný dotaz je rozdělen opět do dvou kroků - nejříve zkoumám, zda vývoj HDP ovlivňuji hodnotu cen a mezd již v daném období. Druhý mezivýpočet zkoumá vazbu vývoje HDP z minulého roku na aktuální ceny potravin a mezd.

Odpověď:
Dá se vypozorovat určitá souvislost mezi výraznějším nárůstem mezd / cen potravin (myšleno o více jak 5 %) a výraznějším meziročním vývojem HDP. Obecně ale platí, že ceny potravin a mzdy reagují na dlouhodobější trendy v oblasti HDP a změny se promítají zejména v oblasti mezd s ninimálně ročním zpožděním. 

Provázanost vývoje cen potravin, mezd a HDP vidíme například na datech za roky 2007 a 2008. Nárůst cen potravin a mezd byl ovlivněn výrazným růstem HDP v období 2005-2007. Nižší nárůst HDP v roce 2008 se projevil až s ročním zpožděním v podobě zlevnění potravin a nižšího růstu mezd.
Na druhou stranu více jak 5% nárůst HDP v roce 2015 žádný výrazný dopad do vývoje cen potravin a mezd v daném období neměl. Důvodem je zřejmě skutečnost, že trhy vyčkávaly na další vývoj pro zjištění, zda se nejedná o mimořádnou výjimku. V roce 2017 již došlo ke skokovému nárůstu cen potravin i mezd (nárůst HDP v daném období byl rovněž více jak 5%, i když v roce 2016 nebyl tak výrazný). Na zpomalení růstu HPD v roce 2018 pružně zareagoval pouze trh potravin; mzdy naopak vzrostly ještě výrazněji než v předchozím období.