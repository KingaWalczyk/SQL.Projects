/*COVID-19 data explorations for further visualizations. 
Utilizing Aggregate Functions, Converting Data Types, Join, Windows Functions, CTE's.

*/

SELECT *
From PortfolioProject..CovidDeaths$
WHERE continent IS not null 
ORDER BY 3,4

-- Selecting Data 

SELECT Location, Date, Population, total_cases AS TotalCases, new_cases AS NewCases, total_deaths AS TotalDeaths
FROM PortfolioProject..CovidDeaths$
WHERE continent IS not null 
ORDER BY 1,2

-- Total Cases vs Total Deaths
-- Likelihood of Dying if You Contracted COVID-19 in Your Country

SELECT Location, Date, total_cases AS TotalCases,  total_deaths AS TotalDeaths, ROUND ((total_deaths/total_cases)*100,2) AS DeathPercentage
FROM PortfolioProject..CovidDeaths$
WHERE location = 'Poland' AND continent IS not null 
ORDER BY 1,2

-- Total Cases vs Population
-- Percentage of Population that Contracted COVID-19 in Your Country

SELECT Location, Date, Population, total_cases AS TotalCases, ROUND ((total_cases/population)*100,2) AS InfectedPercentage
FROM PortfolioProject..CovidDeaths$
--WHERE location = 'Poland'
WHERE continent IS not null 
ORDER BY 1,2

-- Countries with Highest Infection Rate compared to Population

SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount, ROUND(MAX(total_cases/population)*100,2) AS PopulationInfectedPercentage
FROM PortfolioProject..CovidDeaths$
WHERE continent IS not null 
--WHERE location = 'Poland'
GROUP BY population, location
ORDER BY PopulationInfectedPercentage DESC

-- Countries with Highest Death Count per Population 

SELECT Location, MAX(CAST(total_deaths as bigint)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths$
WHERE continent IS not null 
--WHERE location = 'Poland' 
GROUP BY location
ORDER BY TotalDeathCount DESC

-- ANALYZING DATA BY CONTINENT

-- Continents with Highest Death Count per Population 

SELECT Continent, MAX(CAST(total_deaths as bigint)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths$
WHERE Continent IS not null  
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- GLOBAL DATA

-- Percentage of Population Infected with COVID-19 by Given Date

SELECT Date, SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths AS bigint)) AS TotalDeaths, ROUND(SUM(CAST(new_deaths AS bigint))/SUM(New_Cases)*100,2) AS DeathPercentage
FROM PortfolioProject..CovidDeaths$
WHERE continent IS not null 
--WHERE location = 'Poland' 
GROUP BY date
HAVING SUM(new_cases) IS not null
ORDER BY 1,2

-- Total Population vs Vaccinations
-- Percentage of Population That has Recieved at Least One Shot of COVID-19 Vaccine

SELECT dea.Continent, dea.Location, dea.Date, dea.Population, vac.new_vaccinations AS NewVaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS not null
ORDER BY 2,3

-- Using CTE to Perform Calculation on Partition By in Previous Query

WITH PopulationVaccinated (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.Continent, dea.Location, dea.Date, dea.Population, vac.new_vaccinations AS NewVaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
)
SELECT *, (RollingPeopleVaccinated/Population)*100 AS PercentagePeopleVaccinated
FROM PopulationVaccinated

-- Creating View to Store Data for Later Visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.Continent, dea.Location, dea.Date, dea.Population, vac.new_vaccinations AS NewVaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS not null
