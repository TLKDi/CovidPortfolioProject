---- DATA EXPLORATION COVID DEATHS ----

Select * 
From ProjectPortfolio..CovidDeaths
Where continent is not null
order by 3, 4

Select * 
From ProjectPortfolio..CovidVaccinations
Where continent is not null
order by 3, 4

--Select Data that we are going to be using
Select location, date, total_cases, new_cases, total_deaths, population 
From ProjectPortfolio..CovidDeaths
Where continent is not null -- where clause used to eliminate aggregated locations (e.g. world, EU, Asia ...)
order by 1, 2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
Select location, date, total_cases ,total_deaths, (CAST(total_deaths AS float)/CAST(total_cases AS float))*100 as DeathPercentage
From ProjectPortfolio..CovidDeaths
Where location like 'Germany'
order by 1, 2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got covid
Select location, date, total_cases ,population, (CAST(total_cases AS float)/CAST(population AS float))*100 as PercentPopulationInfected
From ProjectPortfolio..CovidDeaths
Where location like 'Germany' 
order by 1, 2

-- Looking at countries with highest infection Rate compared to population
Select location, population, Max(total_cases) as HighestInfectionCount, Max((CAST(total_cases AS float)/CAST(population AS float))*100) as PercentPopulationInfected
From ProjectPortfolio..CovidDeaths
where continent is not null
Group by location, population
order by PercentPopulationInfected desc

-- Showing the countries with the highest death count per population
Select location, Max(CAST(total_deaths AS float)) as TotalDeathCount
From ProjectPortfolio..CovidDeaths
where continent is not null
Group by location
order by TotalDeathCount desc

-------------------------------------------------

-- BREAK INFORMATION DOWN BY CONTINENT:

-- Showing the countries with the highest death count per population
Select continent, Max(CAST(total_deaths AS float)) as TotalDeathCount
From ProjectPortfolio..CovidDeaths
where continent is not null
Group by continent
order by TotalDeathCount desc

-------------------------------------------------

--GLOBAL NUMBERS

Select date, SUM(CAST(new_cases AS FLOAT)) as total_cases, SUM(CAST(new_deaths AS FLOAT))as total_deaths, (SUM(CAST(new_deaths AS float))/SUM(CAST(new_cases AS float)))*100 as DeathPercentage
From ProjectPortfolio..CovidDeaths
Where continent is not null
group by date
order by 1, 2

Select SUM(CAST(new_cases AS FLOAT)) as total_cases, SUM(CAST(new_deaths AS FLOAT))as total_deaths, (SUM(CAST(new_deaths AS float))/SUM(CAST(new_cases AS float)))*100 as DeathPercentage
From ProjectPortfolio..CovidDeaths
Where continent is not null
--group by date
order by 1, 2


---- DATA EXPLORATION COVID VACCINATIONS ----

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as Float)) OVER (Partition by dea.location order by dea.date) AS RollingPeopleVaccinated
From ProjectPortfolio..CovidDeaths dea
JOIN  ProjectPortfolio..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
Where dea.continent is not null
order by 2,3


--CTE

With PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
As
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as Float)) OVER (Partition by dea.location order by dea.date) AS RollingPeopleVaccinated
From ProjectPortfolio..CovidDeaths dea
JOIN  ProjectPortfolio..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)
Select * ,(RollingPeopleVaccinated/Population)*100 AS PercentageRollingPeopleVaccinated
FROM PopVsVac

--Temp Table

Drop table if exists #PercentPopulationVaccinated 
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255), 
Location nvarchar(255), 
Date datetime, 
Population numeric, 
New_Vaccinations numeric, 
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as Float)) OVER (Partition by dea.location order by dea.date) AS RollingPeopleVaccinated
From ProjectPortfolio..CovidDeaths dea
JOIN  ProjectPortfolio..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
Where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100 AS PercentageRollingPeopleVaccinated
FROM #PercentPopulationVaccinated

Create View PercentPopuationVaccinatedView as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as Float)) OVER (Partition by dea.location order by dea.date) AS RollingPeopleVaccinated
From ProjectPortfolio..CovidDeaths dea
JOIN  ProjectPortfolio..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
Where dea.continent is not null
--order by 2,3

Select * 
From PercentPopuationVaccinatedView