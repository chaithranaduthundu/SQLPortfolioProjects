select COUNT(*) from CovidProject.covid_deaths
order by 4;

select COUNT(*) from CovidProject.covid_vaccination
order by 3, 4;

-- Select data that we are going to be using
SELECT location, date, total_cases, new_cases, total_deaths, population 
FROM CovidProject.covid_deaths
ORDER BY 1,2;



-- Looking at total cases vs total deaths

SELECT location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage 
FROM CovidProject.covid_deaths
WHERE location like '%ermany'
ORDER BY 1,2;


-- Looking at total cases vs total population - What % of population got Covid
SELECT location, date, total_cases, new_cases, population, (total_cases/population)*100 AS TotalCase_Percentage 
FROM CovidProject.covid_deaths
WHERE location like 'Germ%%'
ORDER BY 1,2;




SELECT location, MAX(CAST(total_cases AS double)) AS HighestCaseCount, population,
Max((CAST(total_cases AS double)/population)) * 100 AS TotalCase_Percentage
FROM CovidProject.covid_deaths
GROUP BY location, population  
ORDER BY 4 DESC;



-- Countries with the highest death count per population

SELECT location, MAX(CAST(total_deaths AS double)) AS HighestDeathCount, population,
Max((CAST(total_deaths AS double)/population)) * 100 AS TotalDeathPercentage
FROM CovidProject.covid_deaths
WHERE continent NOT IN ("")
GROUP BY location, population  
ORDER BY 4 DESC;


-- death count by continent
SELECT continent, MAX(CAST(total_deaths AS double)) AS TotalDeathCount
FROM CovidProject.covid_deaths
WHERE continent NOT IN ("")
GROUP BY continent  
ORDER BY TotalDeathCount DESC;


-- Same death count by location where continent is null
SELECT location, MAX(CAST(total_deaths AS double)) AS TotalDeathCount
FROM CovidProject.covid_deaths
WHERE continent IN ("")
GROUP BY location  
ORDER BY TotalDeathCount DESC;


-- just test
SELECT *
FROM CovidProject.covid_deaths
WHERE continent IN ("")
AND location IN ('High income','Upper middle income', 'Lower middle income', 'Low income');
-- Test done



-- Global numbers
SELECT SUM(CAST(new_cases AS double)) AS total_cases, SUM(new_deaths) AS total_deaths, 
(SUM(new_deaths)/SUM(CAST(new_cases AS double)))*100 AS death_percentage 
FROM CovidProject.covid_deaths
WHERE continent NOT IN ("")
-- GROUP BY date
ORDER BY 1,2;



-- Let's explore our second table - vaccination
-- Looking at total population vs vaccination

Select dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS double)) OVER (partition by dea.location ORDER BY dea.location
, dea.date) AS rolling_people_vaccinated -- Order by otherwise it will Sum all location contineously
FROM CovidProject.covid_deaths dea
JOIN CovidProject.covid_vaccination vac
ON dea.location = vac.location
AND dea.date = vac.date
ORDER BY 1,2;




-- Using CTE

With PopvsVac (location, date, population, new_vaccinations, rolling_people_vaccinated)
AS 
(
Select dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS double)) OVER (partition by dea.location ORDER BY dea.location,
dea.date) AS rolling_people_vaccinated 
FROM CovidProject.covid_deaths dea
JOIN CovidProject.covid_vaccination vac
ON dea.location = vac.location
AND dea.date = vac.date
)
SELECT location, population, MAX((rolling_people_vaccinated/population)*100) AS percentage_of_people_vaccinated
FROM PopvsVac
GROUP BY 1,2;



-- Using Temp table
DROP TEMPORARY TABLE IF EXISTS PercentPopulationVaccinated;
CREATE TEMPORARY TABLE PercentPopulationVaccinated -- CREATE TEMPORARY TABLE IF NOT EXISTS
(
Location text,
Date datetime,
Population double,
New_vaccination text,
rolling_people_vaccinated float
);
Insert into PercentPopulationVaccinated
Select dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS double)) OVER (partition by dea.location ORDER BY dea.location,
dea.date) AS rolling_people_vaccinated 
FROM CovidProject.covid_deaths dea
JOIN CovidProject.covid_vaccination vac
ON dea.location = vac.location
AND dea.date = vac.date;

SELECT *, (rolling_people_vaccinated/population)*100 AS percentage_of_people_vaccinated
FROM PercentPopulationVaccinated;




-- Creating views for visualizations

CREATE VIEW PercentPopulationVaccinated AS
Select dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS double)) OVER (partition by dea.location ORDER BY dea.location,
dea.date) AS rolling_people_vaccinated 
FROM CovidProject.covid_deaths dea
JOIN CovidProject.covid_vaccination vac
ON dea.location = vac.location
AND dea.date = vac.date;



CREATE VIEW DeathPercentagePerLocation AS
SELECT location, MAX(CAST(total_deaths AS double)) AS HighestDeathCount, population,
Max((CAST(total_deaths AS double)/population)) * 100 AS TotalDeathPercentage
FROM CovidProject.covid_deaths
WHERE continent NOT IN ("")
GROUP BY location, population  
ORDER BY 4 DESC;


CREATE VIEW DeathcountPerContinent AS
SELECT continent, MAX(CAST(total_deaths AS double)) AS TotalDeathCount
FROM CovidProject.covid_deaths
WHERE continent NOT IN ("")
GROUP BY continent  
ORDER BY TotalDeathCount DESC;




