--Looking at Total Cases vs Total Deaths
SELECT location, date, total_cases, total_deaths,population, 
  (total_deaths/total_cases)*100 as death_percentage
FROM myportfolio-386108.covid19_dataset.covid_deaths
WHERE location LIKE "United States"
ORDER BY 1,2 DESC


--Looking at countries with highest infection rate compared to population
SELECT location, population, 
  MAX((total_cases/population)*100) as PercentInfectedPopulation, 
  MAX(total_cases) as HighestInfectedCount
FROM myportfolio-386108.covid19_dataset.covid_deaths
GROUP BY location, population
ORDER BY PercentInfectedPopulation DESC


--Looking at Highest Death Count per Population
SELECT location, MAX(CAST(total_deaths AS INT64)) as TotalDeathCount
FROM myportfolio-386108.covid19_dataset.covid_deaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC


--Showing Continents with Highest Death Count
SELECT continent, 
  MAX(CAST(total_deaths AS INT64)) as TotalDeathCount
FROM myportfolio-386108.covid19_dataset.covid_deaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC

--Calculating  Global Numbers
SELECT  
  SUM(new_cases)as total_cases, 
  SUM(new_deaths) as total_deaths, 
  (SUM(new_deaths)/SUM(new_cases))*100 AS DeathPercentage
FROM myportfolio-386108.covid19_dataset.covid_deaths
WHERE continent is not null AND new_cases>0
ORDER BY 1,2

--Total Population vs Vaccinations
WITH PopvsVac AS  
(
SELECT  dea.continent, dea.location, dea.date, dea.population, new_vaccinations, 
  SUM(CAST (new_vaccinations as int64)) OVER (PARTITION BY dea.location  ORDER BY dea.date, dea.location) AS AccumVaccinations
FROM myportfolio-386108.covid19_dataset.covid_deaths dea 
  INNER JOIN myportfolio-386108.covid19_dataset.covid_vaccinations vac
  ON dea.location= vac.location AND
  dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3
)
Select *, ((AccumVaccinations)/population)*100 as VacPercent
From PopvsVac

--TEMP TABLE
--DROP TABLE if exists PercentPopulationVaccinated
CREATE OR REPLACE TEMP TABLE PercentPopulationVaccinated
(
  continent string,
  location string,
  date datetime,
  population int64,
  new_vaccinations int64,
  AccumVaccinations int64
);
INSERT INTO PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, new_vaccinations, 
  SUM(CAST (new_vaccinations as int64)) OVER (PARTITION BY dea.location  ORDER BY dea.date, dea.location) AS AccumVaccinations
FROM myportfolio-386108.covid19_dataset.covid_deaths dea 
  INNER JOIN myportfolio-386108.covid19_dataset.covid_vaccinations vac
  ON dea.location= vac.location AND
  dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3;

Select *, ((AccumVaccinations)/population)*100 as VacPercent
From PercentPopulationVaccinated