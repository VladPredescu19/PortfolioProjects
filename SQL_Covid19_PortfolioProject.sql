
SELECT *
FROM CovidDeaths$
WHERE continent is not null
ORDER BY 3,4

-- 

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths$
WHERE continent is not null
ORDER BY 1,2

-- Looking at Total Cases vs Total deaths

SELECT Location, date, total_cases, total_deaths, (TOtal_deaths/Total_cases)*100 AS DeathPercentage
FROM CovidDeaths$
WHERE Location like '%Romania'
ORDER BY 1,2

-- Looking at Total Cases vs Population

SELECT Location, date, Population, total_cases,  (total_cases/population)*100 AS ContractionPercentage
FROM CovidDeaths$
WHERE Location like '%Germany'
ORDER BY 1,2

-- Location/country with Highest infection rate compared to Population

SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount,  MAX((total_cases/population))*100 AS PercentPopulation
FROM CovidDeaths$
--WHERE Location like '%Germany'
GROUP BY Location, population
ORDER BY 4 DESC

-- Showing Countries with the highest death count per population

SELECT Location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM CovidDeaths$
WHERE continent is not null
--WHERE Location like '%Germany'
GROUP BY Location
ORDER BY 2 DESC

-- now by continent

SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM CovidDeaths$
WHERE continent is null
--WHERE Location like '%Germany'
GROUP BY location
ORDER BY 2 DESC

-- Showing the continents with the highest death count per pop

SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM CovidDeaths$
WHERE continent is null
--WHERE Location like '%Germany'
GROUP BY continent
ORDER BY 2 DESC

-- Global numbers of cases, deaths and percetange of death by day/date

SELECT date, SUM(new_cases) AS NewCases, SUM(CAST(new_deaths as int)) AS NewDeaths, SUM(CAST(New_deaths as int))/SUM(New_cases)*100 AS Deathpercetange
FROM CovidDeaths$
--WHERE Location like '%Romania'
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

-- Global numbers until 2021

SELECT SUM(new_cases) AS NewCases, SUM(CAST(new_deaths as int)) AS NewDeaths, SUM(CAST(New_deaths as int))/SUM(New_cases)*100 AS Deathpercetange
FROM CovidDeaths$
--WHERE Location like '%Romania'
WHERE continent is not null
ORDER BY 1,2

-- Looking at total population vs vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS CumulativePeopleVaccinated
FROM CovidDeaths$ dea
JOIN CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date= vac.date
WHERE dea.continent is not null
ORDER by 2,3

-- USE CTE because we cannot do an arithmetic operation with a column that you created (CumulativePeopleVaccinated), so we will use CTE/TempTable

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, CumulativePeopleVaccinated)
AS (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS CumulativePeopleVaccinated
FROM CovidDeaths$ dea
JOIN CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date= vac.date
WHERE dea.continent is not null
--ORDER BY 2,3 <- ORDER BY cannot be used in CTEs
)
SELECT *, (CumulativePeopleVaccinated/Population)*100 AS VaccinatedPeopleByPopulation
From PopvsVac

-- TEMP TABLE
DROP Table IF Exists #PercentPopulationVaccinated
CREATE Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
CumulativePeopleVaccinated numeric)


INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS CumulativePeopleVaccinated
FROM CovidDeaths$ dea
JOIN CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date= vac.date
--WHERE dea.continent is not null
--ORDER BY 2,3 <- ORDER BY cannot be used in CTEs

SELECT *, (CumulativePeopleVaccinated/Population)*100 AS VaccinatedPeopleByPopulation
From #PercentPopulationVaccinated

-- Creating View of Data for later data visualization

Create View PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS CumulativePeopleVaccinated
FROM CovidDeaths$ dea
JOIN CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date= vac.date
WHERE dea.continent is not null
--ORDER BY 2,3 <- ORDER BY cannot be used in CTEs