SELECT DISTINCT(location)
FROM CovidDeaths
WHERE continent IS NOT NULL -- Eliminate data where location is the continent

--SELECT *
--FROM CovidVaccinations
--ORDER BY 3,4


-- SELECT DATA TO BE USED

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2


-- TOTAL CASES VS TOTAL DEATHS
-- SHOWS PROBABILLITY/RATE OF DEATH IF CONTRACTED COVID-19

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathRate
FROM CovidDeaths
WHERE location = 'Malaysia'
ORDER BY 1, 2


-- TOTAL CASES VS POPULATION
-- SHOWS COVID-19 INFECTION PROBABILITY/RATE

SELECT location, date, population, total_cases, (total_cases/population)*100 AS InfectionRate
FROM CovidDeaths
WHERE location = 'Malaysia'
ORDER BY 1, 2


-- COUNTRIES WITH THE HIGHEST INFECTION RATE COMPARED TO POPULATION

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population)*100) AS HighestInfectionRate
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY HighestInfectionRate DESC


-- COUNTRIES WITH THE HIGHEST DEATH COUNT

SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC


-- CONTINENT WITH THE HIGHEST DEATH COUNT

SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount -- Alternative query
FROM CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

SELECT continent, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- GLOBAL TOTAL

SELECT SUM(TotalCD.TotalCases), SUM(TotalCD.TotalDeaths), (SUM(TotalCD.TotalDeaths)/SUM(TotalCD.TotalCases))*100 AS DeathPercentage
FROM (SELECT location, MAX(total_cases) AS TotalCases, MAX(CAST(total_deaths AS int)) AS TotalDeaths
	  FROM CovidDeaths
	  WHERE continent IS NOT NULL
	  GROUP BY location) AS TotalCD

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths, (SUM(CAST(new_deaths AS int))/SUM(new_cases))*100 as DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL

SELECT location, total_cases		-- Data checking 
FROM CovidDeaths
WHERE continent IS NOT NULL
	  AND location = 'Afghanistan'
ORDER BY date


-- TOTAL POPULATION VS VACCINATIONS

SELECT 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations, 
	SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS CummulativePeopleVaccinated
FROM 
	CovidDeaths AS dea
JOIN 
	CovidVaccinations AS vac
		ON dea.location = vac.location
		AND dea.date = vac.date 
WHERE 
	dea.continent IS NOT NULL
ORDER BY 
	dea.location, 
	dea.date

-------- CTE

WITH PopvsVac AS (
SELECT 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations, 
	SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS CummulativePeopleVaccinated
FROM 
	CovidDeaths AS dea
JOIN 
	CovidVaccinations AS vac
		ON dea.location = vac.location
		AND dea.date = vac.date 
WHERE 
	dea.continent IS NOT NULL
--ORDER BY 
--	dea.location, 
--	dea.date
)
SELECT *, (CummulativePeopleVaccinated/population)*100 AS CummulativeVaccinationRate
FROM PopvsVac
ORDER BY 
	location, 
	date

-------- CTE (WITHOUT DATE, WITH TOTAL VACCINATION)

WITH PopvsVac AS (
SELECT 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations, 
	SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS CummulativePeopleVaccinated
FROM 
	CovidDeaths AS dea
JOIN 
	CovidVaccinations AS vac
		ON dea.location = vac.location
		AND dea.date = vac.date 
WHERE 
	dea.continent IS NOT NULL
)
SELECT location, population, MAX(CummulativePeopleVaccinated) AS TotalPeopleVaccinated, (MAX(CummulativePeopleVaccinated)/population)*100 AS TotalVaccinationRate
FROM PopvsVac
GROUP BY location, population
ORDER BY 
	 TotalVaccinationRate DESC, location

-------- TEMP TABLE

DROP TABLE IF EXISTS #PopvsVac
CREATE TABLE #PopvsVac
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
CummulativePeopleVaccinated numeric,
)

INSERT INTO #PopvsVac
SELECT 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations, 
	SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS CummulativePeopleVaccinated
FROM 
	CovidDeaths AS dea
JOIN 
	CovidVaccinations AS vac
		ON dea.location = vac.location
		AND dea.date = vac.date 
WHERE 
	dea.continent IS NOT NULL

SELECT *, (CummulativePeopleVaccinated/Population)*100 AS CummulativeVaccinationRate
FROM #PopvsVac
ORDER BY 
	Location, 
	Date

-------- data checking

SELECT CovidDeaths.location, CovidDeaths.date, CovidDeaths.population, CovidVaccinations.total_vaccinations 
FROM CovidVaccinations
JOIN CovidDeaths
	ON CovidDeaths.location = CovidVaccinations.location
	AND CovidDeaths.date = CovidVaccinations.date
WHERE CovidDeaths.location LIKE 'Gibra%'
ORDER BY 1, 2


-- CREATE VIEW TO STORE DATA FOR VISUALIZATIONS

CREATE VIEW PercentPopulationVaccinated AS
SELECT 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations, 
	SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS CummulativePeopleVaccinated
FROM 
	CovidDeaths AS dea
JOIN 
	CovidVaccinations AS vac
		ON dea.location = vac.location
		AND dea.date = vac.date 
WHERE 
	dea.continent IS NOT NULL
--ORDER BY 
--	dea.location, 
--	dea.date

SELECT *
FROM PercentPopulationVaccinated