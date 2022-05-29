USE portfolio_project;
-- Select data we are going to be using
-- Likelyhood of dying if you contract covid per Location - e.g Africa
SELECT 
		Location,
        date,
        total_cases,
        new_cases,
        total_deaths,
        population
FROM coviddeaths
ORDER BY 1,2
-- Looking at Total Cases vs Total Deaths
SELECT 
		Location,
        date,
        total_cases,
        total_deaths,
        (total_deaths/total_cases)*100 AS Death_Percentage 
FROM coviddeaths
WHERE Location LIKE '%Africa%'
-- Looking at the Total Cases vs the Population
-- Shows what percentage of population got covid

SELECT
	Location,
    date,
    population,
    total_cases,
    (total_cases/population)*100 AS 'Percentage of Population Infected'
FROM coviddeaths
ORDER BY 1,2

-- Looking at countries with high infection rates compared to population
SELECT
	Location,
    population,
   MAX( total_cases) AS 'Highest_ Infection_Count',
    MAX((total_cases/population))*100 AS Percent_of_Population_Infected
FROM coviddeaths
GROUP BY location,population
ORDER BY Percent_of_Population_Infected DESC

-- Showing countries with highest death count per Population
-- Use Signed to convert a string data type to integer in Mysql
SELECT
	Location,
 MAX(cast(total_deaths as signed))  AS Total_Death_Count
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY Total_Death_Count DESC

-- Showing continents with the highest death count per population
SELECT
	 continent,
     MAX(cast(total_deaths as signed))  AS Death_per_continent
FROM  coviddeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY Death_per_continent DESC
-- Global Numbers
SELECT
	date, SUM(new_cases) as total_cases,SUM(cast(new_deaths as signed)) as total_deaths,SUM(cast(new_deaths as signed))/SUM(new_cases)*100 AS Death_Percentage
FROM coviddeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2 
-- Working with the second table - Covid Vaccinations 
-- Return all the data from covid vaccinations table
SELECT *
FROM covidvaccinations

-- Looking at the Total Population vs Vaccinations
SELECT 
	 dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
     SUM(cast(vac.new_vaccinations as signed)) OVER (Partition by dea.location order by dea.location,dea.date)as Rollingpeoplevaccinated
FROM coviddeaths dea
JOIN covidvaccinations vac
ON dea.location=vac.location
and dea.date = vac.date
WHERE  dea.continent is not null
ORDER BY 2,3
-- USE CTE
with PopvsVac(continent,location,date,population,new_vaccinations,Rollingpeoplevaccinated)
as
(
SELECT 
	 dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
     SUM(cast(vac.new_vaccinations as signed)) OVER (Partition by dea.location order by dea.location,dea.date)as Rollingpeoplevaccinated
FROM coviddeaths dea
JOIN covidvaccinations vac
ON dea.location=vac.location
and dea.date = vac.date
WHERE  dea.continent is not null
-- ORDER BY 2,3
)
SELECT *,(Rollingpeoplevaccinated/population)*100
FROM PopvsVac
-- Creating a table
DROP Table if exists PercentPopulationVaccinated
CREATE TABLE PercentPopulationVaccinated
(
Continent varchar(255),
Date date,
Location varchar (255),
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into PercentPopulationVaccinated
SELECT 
	 dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
     SUM(CAST(vac.new_vaccinations as signed )) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
     
FROM coviddeaths dea
JOIN covidvaccinations vac
ON dea.location=vac.location
and dea.date = vac.date
-- WHERE  dea.continent is not null
-- WHERE  dea.continent is not null
Select *, (RollingPeopleVaccinated/Population)*100
From PercentPopulationVaccinated
-- Creating view to store data for later visualizations
Create View PercentPopulationVaccinated as
SELECT 
	 dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
     SUM(CAST(vac.new_vaccinations as signed )) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
     
FROM coviddeaths dea
JOIN covidvaccinations vac
ON dea.location=vac.location
and dea.date = vac.date
where dea.continent is not null 
