select *
from PortfolioProfil..CovidDeaths
where continent is not null 
order by 1,2


--select Data that we are going to be using 
select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProfil..CovidDeaths
order by 1,2


--looking at Total Cases vs Total Deaths
--shows likelyhood of dying if you cintract covid in these countries

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProfil..CovidDeaths
Where location like '%tunisia%'
order by 1,2

-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProfil..CovidDeaths
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc

--Looking at the Total Cases vs Population 
--Shows what percentage that got Covid

select location, date, total_cases, total_deaths, population, (total_cases/population)*100 as DeathPercentage
from PortfolioProfil..CovidDeaths
Where location in ('tunisia', 'algeria','mauritania','morocco', 'libya' )
order by 1,2

--Change Column total_deaths from Narchar to Numeric
ALTER TABLE PortfolioProfil..CovidDeaths
ALTER COLUMN total_deaths NUMERIC(10,2);

select location,sum(total_deaths)
from PortfolioProfil..CovidDeaths
Where location in ('tunisia', 'algeria','mauritania','morocco', 'libya' )
group by location



--Looking at Countries with the highest Infection Rate compared to Population
select location, population,date, Max(total_cases)as HighestInfectionCount ,  Max((total_cases/population))*100 as PercentofPopulationInfected
from PortfolioProfil..CovidDeaths
--where continent like' Africa'
--Where location like 'tunisia'
group by population,location,date
order by PercentofPopulationInfected desc

--Showing Countries with Higest Death Count per Population 

select location, Max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProfil..CovidDeaths
--Where location like 'tunisia'
where continent is not null 
group by location
order by TotalDeathCount desc

--LETS BREAK THINGS DOWN BY CONTINENT 

select continent, Max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProfil..CovidDeaths
--Where location like 'tunisia'
where continent is not null 
group by continent
order by TotalDeathCount desc


 --GLOBAL NUMBERS

 select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total , sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProfil..CovidDeaths
where continent is not null
group by date 
order by 1,2

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total , sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProfil..CovidDeaths
where continent is not null
--group by date 
order by 1,2

--LOOKING AT TOTAL POPULATION VS VACCINATIONS

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, ISNULL(vac.new_vaccinations, 0))) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Rollingpeoplevaccinated
from PortfolioProfil..CovidDeaths dea
join PortfolioProfil..CovidVaccinations vac
on dea.location = vac.location
and dea.date= vac.date
where dea.continent is not null 
order by 2,3


--USE CTE

with PopvsVac (continent, location, date, population,new_vaccinations, Rollingpeoplevaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, ISNULL(vac.new_vaccinations, 0))) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Rollingpeoplevaccinated
from PortfolioProfil..CovidDeaths dea
join PortfolioProfil..CovidVaccinations vac
on dea.location = vac.location
and dea.date= vac.date
where dea.continent is not null 
--order by 2,3
)
select *, (Rollingpeoplevaccinated/population)*100
from PopvsVac

--TEMP TABLE

IF OBJECT_ID('tempdb..#PercentPopulationVaccinated', 'U') IS NOT NULL
DROP TABLE #PercentPopulationVaccinated;


create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Rollingpeoplevaccinated numeric 
)


insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, ISNULL(vac.new_vaccinations, 0))) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Rollingpeoplevaccinated
from PortfolioProfil..CovidDeaths dea
join PortfolioProfil..CovidVaccinations vac
on dea.location = vac.location
and dea.date= vac.date
where dea.continent is not null 
--order by 2,3

select*, (Rollingpeoplevaccinated/population)*100
from #PercentPopulationVaccinated





--CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS

create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, ISNULL(vac.new_vaccinations, 0))) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Rollingpeoplevaccinated
from PortfolioProfil..CovidDeaths dea
join PortfolioProfil..CovidVaccinations vac
on dea.location = vac.location
and dea.date= vac.date
where dea.continent is not null 
--order by 2,3