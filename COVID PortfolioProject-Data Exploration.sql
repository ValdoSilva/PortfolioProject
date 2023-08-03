/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

SELECT *
from 
PortfolioProject..CovidDeaths

--change the data type to bigint
ALTER TABLE PortfolioProject.dbo.CovidDeaths
ALTER COLUMN new_cases DECIMAL


--total percentages death in each country (total death /total cases *100)
--total death vs total cases 
SELECT location,[date],total_cases, total_deaths, CAST((total_deaths * 100.0 / total_cases) AS DECIMAL(10, 2)) AS percentage_deaths
from 
dbo.CovidDeaths
WHERE [location] LIKE '%states%' --spesific location 
ORDER BY 1,2

-- show what persentage of population got virus
-- total cases vs population 
SELECT [location],[date],total_cases, population, (total_cases/population)*100 as PercentagePopInfected
from 
PortfolioProject..CovidDeaths
WHERE [location] LIKE '%United Kingdom%'
ORDER BY 1,2

-- Which country has the highest infection rate compare to population
SELECT [location], population,MAX(total_cases) as Highest_infection, MAX(total_cases/population)*100 as PercentPopulationInfected
From
PortfolioProject..CovidDeaths
GROUP BY [location],population
ORDER by PercentPopulationInfected DESC

-- which country has the highest death count per population

SELECT [location], MAX(total_deaths) as MaxTotalDeath
From
PortfolioProject..CovidDeaths
WHERE continent is not NULL
GROUP by [location]
ORDER by MaxTotalDeath DESC


--Break it down by continent (continent that has the highest death rate)

SELECT continent, MAX(total_deaths) as MaxTotalDeath
From
PortfolioProject..CovidDeaths
WHERE continent is not NULL
GROUP by continent
ORDER by MaxTotalDeath DESC


-- Global Numbers

SELECT 'World' as Global,MAX(date) as Date, SUM(total_cases) as Total_Cases, SUM(total_deaths) as Total_Deaths, (SUM(total_deaths)/SUM(total_cases))*100 as Death_Percentage
From
PortfolioProject..CovidDeaths
WHERE continent is not NULL
ORDER by 1,2

-- Global Number by date; use NULLIF(new_death,0) (new_deaths contains 0 when divide with total cases to avoid error) 

SELECT 'Around the World' as Global,dea.[date],SUM(dea.new_cases) as Total_New_Cases, SUM(dea.new_deaths) as Total_New_Deaths, SUM(nullif(new_deaths,0))/sum(dea.new_cases)*100 as Total_percentage
FROM
PortfolioProject..CovidDeaths dea
WHERE dea.continent is not NULL
group BY [date]
ORDER by 1,2


--Total new cases and new deaths around the world
SELECT 'Around the World' as Global,SUM(dea.new_cases) as Total_new_Cases, SUM(dea.new_deaths) as Total_new_Deaths, SUM(nullif(new_deaths,0))/sum(dea.new_cases)*100 as Total_percentage
FROM
PortfolioProject..CovidDeaths dea
WHERE dea.continent is not NULL
ORDER by 1,2


-- Looking at total population vs new vaccinations (continent and location) join two tables 

SELECT dea.continent, dea.[location], dea.[date], dea.population, vacc.new_vaccinations,
SUM(vacc.new_vaccinations) OVER (partition by dea.location order by dea.location, dea.date) as Rolling_people_vaccinated
FROM 
PortfolioProject..CovidVaccinations vacc
JOIN
PortfolioProject..CovidDeaths dea
on 
dea.[location] = vacc.[location]
and dea.[date] = vacc.[date]
WHERE dea.continent is not NULL AND vacc.new_vaccinations is not NULL
ORDER by 2,3


-- Use CTE to calculate how many percentage people are vaccinated based on Rolling_people_vaccinated

WITH
Total_Vaccinated_Each_country (continent, location,date, population, new_vaccinations,Rolling_people_vaccinated)
AS
(
SELECT dea.continent, dea.[location], dea.[date], dea.population, vacc.new_vaccinations,
SUM(vacc.new_vaccinations) OVER (partition by dea.location order by dea.location, dea.date) as Rolling_people_vaccinated
FROM 
PortfolioProject..CovidVaccinations vacc
JOIN
PortfolioProject..CovidDeaths dea
on 
dea.[location] = vacc.[location]
and dea.[date] = vacc.[date]
WHERE dea.continent is not NULL AND vacc.new_vaccinations is not NULL
--ORDER by 2,3
)

SELECT *,  (Rolling_people_vaccinated/cast(population as decimal))*100 as PercentagePeopleVaccinated
From
Total_Vaccinated_Each_country


-- Temp Table to calculate percentage of how many people vaccinated. 

DROP TABLE if EXISTS #PercentPopulationVaccinated -- if table needs multiple alteration 

CREATE TABLE #PercentPopulationVaccinated
(
    continent NVARCHAR (255),
    location NVARCHAR(255),
    date DATETIME,
    population NUMERIC,
    new_vaccinations NUMERIC,
    Rolling_people_vaccinated NUMERIC
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.[location], dea.[date], dea.population, vacc.new_vaccinations,
SUM(vacc.new_vaccinations) OVER (partition by dea.location order by dea.location, dea.date) as Rolling_people_vaccinated
FROM 
PortfolioProject..CovidVaccinations vacc
JOIN
PortfolioProject..CovidDeaths dea
on 
dea.[location] = vacc.[location]
and dea.[date] = vacc.[date]
WHERE dea.continent is not NULL AND vacc.new_vaccinations is not NULL
--ORDER by 2,3

SELECT *, (pop.Rolling_people_vaccinated/pop.population)*100 as PercentagePopulationVaccinated 
FROM #PercentPopulationVaccinated pop


-- Creating View for data visualisation 
drop VIEW if EXISTS PercentPopulationVaccinated -- delete view 

CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.[location], dea.[date], dea.population, vacc.new_vaccinations,
SUM(vacc.new_vaccinations) OVER (partition by dea.location order by dea.location, dea.date) as Rolling_people_vaccinated
FROM 
PortfolioProject..CovidVaccinations vacc
JOIN
PortfolioProject..CovidDeaths dea
on 
dea.[location] = vacc.[location]
and dea.[date] = vacc.[date]
WHERE dea.continent is not NULL AND vacc.new_vaccinations is not NULL
--ORDER by 2,3










