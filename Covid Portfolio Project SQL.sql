select *
from CovidDeaths
Where continent is Not Null
order by 3,4

--select *
--from CovidVaccinations
--order by 3,4

--select location,date,total_cases,new_cases,total_deaths,population
--from CovidDeaths
--order by 1,2

--Looking at Total Cases vs Total Deaths
--Shows liklihood of dying if you contarct Covid in your Country

select location,date,total_cases,total_deaths, ((total_deaths/total_cases)*100) as DeathPercentage
from CovidDeaths
where location like '%australia%'
and continent is Not Null
order by 1,2

--Looking at Total Cases vs Population
--Shows what percentage of Population got Covid

select location,date,population,total_cases, ((total_cases/population)*100) as PercentPopulationInfected
from CovidDeaths
--where location like '%australia%'
Where continent is Not Null
order by 1,2

--Looking at countries with highest Infection Rate compared to Population

select location,population,Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
from CovidDeaths
--where location like '%australia%'
where location like '%china%'
and continent is Not Null
group by location,population
order by 4 desc

--Showing countries with Highest death Count per Population

select location, Max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
--where location like '%china%'
where continent is Not Null
group by location,population
order by TotalDeathCount desc


--LET'S BREAK THINGS DOWN BY CONTINENT

select location, Max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
--where location like '%china%'
where continent is Null
group by location
order by TotalDeathCount desc

--Showing continent with highest death by population

select continent, Max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
--where location like '%china%'
where continent is not Null
group by continent
order by TotalDeathCount desc


--GLOBAL NUMBERS
select date,sum(new_cases) as TotalCases,sum(cast(new_deaths as int)) as TotalDeaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as DeathPercentage
from CovidDeaths
--where location like '%australia%'
where continent is Not Null
group by date
order by 1,2 desc

select sum(new_cases) as TotalCases,sum(cast(new_deaths as int)) as TotalDeaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as DeathPercentage
from CovidDeaths
--where location like '%australia%'
where continent is Not Null
--group by date
order by 1,2 desc

--Looking at Total Population vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from CovidDeaths dea
join CovidVaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is Not Null
 order by 2,3


-- USE CTE

with PopvsVac (continent, location, date, population, New_vaccinations, RollingPeopleVaccinated)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from CovidDeaths dea
join CovidVaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is Not Null
 --order by 2,3
)
select *,(RollingPeopleVaccinated/population)*100
from PopvsVac


-- TEMP Table

Drop table if exists #PercentagePopulationVaccinated
create table #PercentagePopulationVaccinated 
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentagePopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from CovidDeaths dea
join CovidVaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
 --where dea.continent is Not Null
 --order by 2,3
 
select *,(RollingPeopleVaccinated/population)*100
from #PercentagePopulationVaccinated


-- Creating view to store data for later Visualisations

Create View PercentagePopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from CovidDeaths dea
join CovidVaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is Not Null
 --order by 2,3

 select *
 from PercentagePopulationVaccinated