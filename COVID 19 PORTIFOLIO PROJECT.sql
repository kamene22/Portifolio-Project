
Select *
From [Portifolio Project]..[CovidDeaths]
where continent is not null
Order by 3,4



--Select *
--From [Portifolio Project]..[CovidVaccinations]
--Order by 3,4

-- Select data that we are going to be using 

Select Location, date, total_cases, new_cases, total_deaths,population
From [Portifolio Project]..[CovidDeaths]
Order by 1,2


--Total cases vs total deaths
 --Shows the likehood of dying if you contract covid


Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [Portifolio Project]..[CovidDeaths]
where  location like '%Kenya%'
Order by 1,2


--TOTAL CASES VS POPULATION
--Shows percentage of the population that got Covid


Select location, date, total_cases, population, (total_cases/population)*100 as PercentagePopulationInfected
From [Portifolio Project]..[CovidDeaths]
where  location like '%Kenya%'
Order by 1,2


--COUNTRIES WITH HIGHEST INFECTION RATE

Select location,population,  MAX(total_cases) as Highestinfectioncount,MAX((total_cases/population))*100 as PercentagePopulationInfected
From [Portifolio Project]..[CovidDeaths]
--where  location like '%Kenya%'
Group by population, location
Order by PercentagePopulationInfected DESC


--COUNTRIES WITH THE HIGHEST DEATH COUNT

Select location,MAX(cast(total_deaths as int)) as TotalDeathCount
From [Portifolio Project]..[CovidDeaths]
--where  location like '%Kenya%'
where continent is not null
Group by location
Order by  TotalDeathCount DESC

--LET'S BREAK THINGS BY CONTINENT

--SHOWING CONTINENTS WITH HIGHEST DEATH COUNT PER POPULATION

Select location,MAX(cast(total_deaths as int)) as TotalDeathCount
From [Portifolio Project]..[CovidDeaths]
--where  location like '%Kenya%'
where continent is null
Group by location
Order by  TotalDeathCount DESC


--GLOBAL NUMBERS

Select date, SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths ,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From [Portifolio Project]..[CovidDeaths]
--where  location like '%Kenya%'
where continent is  not null
Group by date
Order by 1,2 


Select SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths ,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From [Portifolio Project]..[CovidDeaths]
--where  location like '%Kenya%'
where continent is  not null
Order by 1,2 




Select * 
From  [Portifolio Project]..[CovidDeaths] dea 
Join   [Portifolio Project]..[CovidVaccinations] vac 
ON  dea.location = vac.location
AND dea.date = vac.date




--TOTAL  POPULATION VS VACCINATION
Select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated

From  [Portifolio Project]..[CovidDeaths] dea 
Join   [Portifolio Project]..[CovidVaccinations] vac 
     ON  dea.location = vac.location
     AND dea.date = vac.date
where dea.continent is not null
order by 2,3



--USING A CTE

With PopvsVac(continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated

--(RollingPeopleVaccinated/population)*100

From  [Portifolio Project]..[CovidDeaths] dea 
Join   [Portifolio Project]..[CovidVaccinations] vac 
     ON  dea.location = vac.location
     AND dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac


--TEMP TABLE 

IF OBJECT_ID('tempdb..#PercentPopulationVaccinated') IS NOT NULL
    DROP TABLE #PercentPopulationVaccinated;

Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated

Select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated

--(RollingPeopleVaccinated/population)*100

From  [Portifolio Project]..[CovidDeaths] dea 
Join   [Portifolio Project]..[CovidVaccinations] vac 
     ON  dea.location = vac.location
     AND dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select *,(RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated



--CREATING VIEW TO STORE DATA FOR VISUALIZATION

Create View PercentagePopulationVaccinated as
Select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated

--(RollingPeopleVaccinated/population)*100

From  [Portifolio Project]..[CovidDeaths] dea 
Join   [Portifolio Project]..[CovidVaccinations] vac 
     ON  dea.location = vac.location
     AND dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
FROM PercentagePopulationVaccinated


