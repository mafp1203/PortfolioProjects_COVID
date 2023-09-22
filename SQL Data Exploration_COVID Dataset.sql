-- SELECT * FROM portfolioproject.coviddeaths
-- WHERE continent IS NOT NULL
-- ORDER BY 3,4;

-- SELECT * FROM portfolioproject.covidvaccinations
-- ORDER BY 3,4;

-- Select Data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population 
FROM portfolioproject.coviddeaths
WHERE continent IS NOT NULL
ORDER BY 1,2;

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM portfolioproject.coviddeaths
WHERE location LIKE '%states%' 
AND continent IS NOT NULL
ORDER BY 1,2;

-- Looking at Total Cases vs Population
-- Shows what percentage of population got covid

SELECT location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
FROM portfolioproject.coviddeaths
-- WHERE location LIKE '%states%' 
WHERE continent IS NOT NULL
ORDER BY 1,2;

-- Looking at Countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM portfolioproject.coviddeaths
-- WHERE location LIKE '%states%' 
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentPopulationInfected desc;

-- Showing the countries with Highest Death Count per Population

SELECT location, MAX(total_deaths) as TotalDeathCount
FROM portfolioproject.coviddeaths
-- WHERE location LIKE '%states%' 
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount desc;

-- LET'S BREAK THINGS DOWN BY CONTINENT

SELECT continent, MAX(total_deaths) as TotalDeathCount
FROM portfolioproject.coviddeaths
-- WHERE location LIKE '%states%' 
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount desc;

-- Showing continents with the Highest death count per population

SELECT continent, MAX(total_deaths) as TotalDeathCount
FROM portfolioproject.coviddeaths
-- WHERE location LIKE '%states%' 
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount desc;

-- GLOBAL NUMBERS

SELECT SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, (SUM(new_deaths)/SUM(new_cases))*100 as DeathPercentage
FROM portfolioproject.coviddeaths
-- WHERE location LIKE '%states%' 
WHERE continent IS NOT NULL
-- GROUP BY date
ORDER BY 1,2;

-- Looking at total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
FROM portfolioproject.coviddeaths dea
JOIN portfolioproject.covidvaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3;

-- USE CTE

WITH PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
FROM portfolioproject.coviddeaths dea
JOIN portfolioproject.covidvaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
-- ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac;

-- TEMP TABLE

DROP TABLE IF EXISTS PercentPopulationVaccinated;
CREATE TABLE PercentPopulationVaccinated (
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric);

INSERT INTO PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
FROM portfolioproject.coviddeaths dea
JOIN portfolioproject.covidvaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;
-- ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population)*100
FROM PercentPopulationVaccinated;

-- Creating view to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated_two as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
FROM portfolioproject.coviddeaths dea
JOIN portfolioproject.covidvaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;
-- ORDER BY 2,3

SELECT * FROM PercentPopulationVaccinated_two;
