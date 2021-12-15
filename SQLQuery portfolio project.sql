select *
From [Portfolio Project]..['covid deaths#xls$']
order by 3,4

--select *
--From [Portfolio Project]..['covid vaccination#xls$']
--order by 3,4

Select Location,date,total_cases, new_cases, total_deaths,population
From [Portfolio Project]..['covid deaths#xls$']
order by 1,2

--totalcases vs total death

select location,population,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as Deathpercentage
from [Portfolio Project]..['covid deaths#xls$']
where location like '%states%'
order by 1,2

--total cases vs population
select location,date,population,total_cases,total_deaths,(total_cases/population)*100 as percentpopulationinfected
from [Portfolio Project]..['covid deaths#xls$']
where location like '%states%'
order by 1,2

--highest infection rate vs population

select location,population,MAX(total_cases) as highestinfectionrate,MAX((total_cases/population))*100 as percentpopulationinfected
from [Portfolio Project]..['covid deaths#xls$']
--where location like '%states%'
group by population, location
order by percentpopulationinfected desc

--countries with highest deathcount per population

select location,MAX(cast(total_deaths as int)) as totaldeathcount
from [Portfolio Project]..['covid deaths#xls$']
--where location like '%states%'
where continent is not null
group by population, location
order by totaldeathcount desc


--Break by continent

--select location,MAX(cast(total_deaths as int)) as totaldeathcount
--from [Portfolio Project]..['covid deaths#xls$']
----where location like '%states%'
--where continent is null
--group by location
--order by totaldeathcount desc

select continent,MAX(cast(total_deaths as int)) as totaldeathcount
from [Portfolio Project]..['covid deaths#xls$']
--where location like '%states%'
where continent is not null
group by continent
order by totaldeathcount desc

--Global Numbers


select sum(new_cases) as total_cases ,sum(cast(new_deaths as int )) as totaldeaths,sum(cast(new_deaths as int ))/sum(new_cases)*100 as deathpercentage
from [Portfolio Project]..['covid deaths#xls$']
--where location like '%states%'
where continent is not null
order by 1,2

--looking at total population vs vaccination
--use CTE

with popvsvac (contienent,location,date,population,rollingpeoplevaccinated,new_vaccinations)
as
(
select dea.location, dea.date,dea.continent,dea.population,vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location,dea.date) as rollingpeoplevaccinated
from [Portfolio Project]..['covid deaths#xls$'] dea
join [Portfolio Project]..['covid vaccination#xls$'] vac
        on dea.location = vac.location 
		 and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (rollingpeoplevaccinated/population)*100
from popvsvac

--temp table

drop table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)

Insert into #percentpopulationvaccinated
select dea.location, dea.date,dea.continent,dea.population,vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
from [Portfolio Project]..['covid deaths#xls$'] dea
join [Portfolio Project]..['covid vaccination#xls$'] vac
        on dea.location = vac.location 
		 and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *, (rollingpeoplevaccinated/population)*100
from #percentpopulationvaccinated


--creating views

create view percentpopulationvaccinated as
select dea.location, dea.date,dea.continent,dea.population,vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
from [Portfolio Project]..['covid deaths#xls$'] dea
join [Portfolio Project]..['covid vaccination#xls$'] vac
        on dea.location = vac.location 
		 and dea.date = vac.date
where dea.continent is not null
order by 2,3


