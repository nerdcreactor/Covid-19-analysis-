SELECT *
FROM
  project..covid_deaths
ORDER BY
  3, 4

--SELECT *
--FROM 
--  project..covid_vaccination
--ORDER BY
--  3, 4
SELECT 
  Location, date, total_cases, new_cases, total_deaths, population
FROM  
  project..covid_deaths
ORDER BY
  1, 2

-- looking at total_cases vs total_deaths
--shows likelihood of dying if you get covid positive 
SELECT 
  Location, total_cases, total_deaths, (total_deaths/total_cases)*100 AS percent_population_infected
FROM  
  project..covid_deaths
WHERE 
  location like '%india%'
GROUP BY
location, popu
ORDER BY
  1, 2

--looking at total_cases vs population
SELECT 
  Location, CAST(date AS DATE), total_cases, population, new_cases, total_deaths,((total_cases/population)*100) 
FROM  
  project..covid_deaths
WHERE 
  location like '%india%'
ORDER BY
  1, 2

-- looking at countries having higest infection rate compared to population
SELECT 
  Location, MAX(total_cases) AS highest_infection_count, population, MAX((total_cases/population))*100 AS percentage_population_infected
FROM  
  project..covid_deaths
--WHERE 
  --location like '%india%'
GROUP BY
  location, population
ORDER BY
  percentage_population_infected DESC
-- looking at countries having highest death rate and death count compared to population
SELECT 
  Location, MAX(CAST(total_deaths AS INT)) AS total_death_count, MAX(((total_deaths/population))*100) AS percentage_population_died
FROM  
  project..covid_deaths
WHERE 
  continent IS NOT NULL
GROUP BY
  location, population
ORDER BY
  total_death_count DESC

-- Let's break things down by continent 
SELECT 
   continent, MAX(CAST(total_deaths AS INT)) AS total_death_count, MAX(((total_deaths/population))*100) AS percentage_population_died
FROM  
  project..covid_deaths
WHERE 
  continent IS NOT NULL
GROUP BY
  continent
ORDER BY
  total_death_count DESC


-- Global Numbers
SELECT 
  date, SUM(new_cases) AS total_cases, SUM(CAST (new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS death_percentage
FROM
  project..covid_deaths
WHERE continent IS NOT NULL
GROUP BY 
  date
ORDER BY
  1, 2


-- Looking at total vaccination vs population
WITH popvsvac(date, location, continent, Population, RolllinPeopleVaccinated, new_vaccinations)
AS
(
SELECT
dea.date, dea.location, dea.continent, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS INT)) OVER(PARTITION BY dea.location, CAST(dea.date AS DATE) ORDER BY dea.date) AS RollingPeopleVaccinated
FROM
  project..covid_deaths dea
JOIN
  project..covid_vaccination vac
ON 
  dea.location = vac.location
AND 
  dea.date = vac.date
WHERE 
  dea.continent IS NOT NULL
)
SELECT *, (RolllinPeopleVaccinated/population)*100 AS RolllingVaccinationspercentage
FROM popvsvac


-- TO check which country was the first to give a vaccine shot
SELECT 
dea.location, dea.date, vac.new_vaccinations
FROM
  project..covid_deaths dea
JOIN
  project..covid_vaccination vac
ON 
  dea.location = vac.location
AND 
  dea.date = vac.date
WHERE
  vac.new_vaccinations IS NOT NULL AND new_vaccinations != 0 AND dea.continent IS NOT NULL

ORDER BY
  dea.date
LIMIT 1;

--TEMP TABLE
DROP TABLE IF EXISTS #percent_population_vaccinated
CREATE TABLE #percent_population_vaccinated
(
Continent nvarchar(255),
location nvarchar(255),
Date nvarchar(255),
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO 
  #percent_population_vaccinated
SELECT
  dea.date, dea.location, dea.continent, dea.population, vac.new_vaccinations,
  SUM(CAST(vac.new_vaccinations AS INT)) OVER(PARTITION BY dea.location, CAST(dea.date AS DATE) ORDER BY dea.date) AS RollingPeopleVaccinated
FROM
  project..covid_deaths dea
JOIN
  project..covid_vaccination vac
ON 
  dea.location = vac.location
AND 
  dea.date = vac.date
--WHERE 
  --dea.continent IS NOT NULL

  SELECT *, (RollingPeopleVaccinated/population)*100
  FROM #percent_population_vaccinated


-- creating view to store data for later visualizations
 
CREATE VIEW 
   percecent_population_vaccinated AS
 
SELECT
  dea.date, dea.location, dea.continent, dea.population, vac.new_vaccinations,
  SUM(CAST(vac.new_vaccinations AS INT)) OVER(PARTITION BY dea.location, CAST(dea.date AS DATE) ORDER BY dea.date) AS RollingPeopleVaccinated
FROM
  project..covid_deaths dea
JOIN
  project..covid_vaccination vac
ON 
  dea.location = vac.location
AND 
  dea.date = vac.date
WHERE 
  dea.continent IS NOT NULL



SELECT *
FROM percent_population_vaccinated