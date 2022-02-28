-- TRUNCATE TABLE covid;

-- ALTER TABLE covid
-- ADD population int;

-- ALTER TABLE covid
-- ADD population_density float;


select * from vaccination
order by 3,4

-- select * from covid
-- order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from covid
order by 1,2


-- total cases vs total deaths
-- shows the likelihood of dying if you contract covid
select location , date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathpercentage
from covid
where location like '%mexico%' or location like '%states%'
order by 1,2

-- only mexico
select location , date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathpercentage
from covid
where location like '%mexico%'
order by 1,2

-- Total cases vs Population
-- shows what percentage of population got covid
select location , date, total_cases, population, (total_cases/population)*100 as casespercentage
from covid
order by 1,2

select location , date, total_cases, population, (total_cases/population)*100 as casespercentage
from covid
where location like '%mexico%'
order by 1,2

-- country with the highest infection rate
select location , date, max(total_cases) as highestinfection, population, max((total_cases/population)*100) as casespercentage
from covid
group by location, population
order by casespercentage desc

-- country with highest death count per population
select location , date, max(total_deaths) as total_deathscount
from covid
where continent != ''
group by location
order by total_deathscount desc


-- let's break things down by continent
-- continents with the highest death count per population
select continent, max(total_deaths) as total_deathscount
from covid
where continent != ''
group by continent
order by total_deathscount desc

-- percentage of gobal cases and deaths
select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(new_deaths)/SUM(new_Cases)*100 as DeathPercentage
from covid
-- Where location like '%states%'
where continent != ''
-- Group By date
order by 1,2


-- Join covid deaths and covid vaccination

select *
from covid dea
join vaccination vac
	on dea.location = vac.location
    and dea.date = vac.date


-- looking at total population vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from covid dea
join vaccination vac
	on dea.location = vac.location
    and dea.date = vac.date
where dea.continent != ''
order by 2,3



select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
from  covid dea
Join vaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (continent, location, date, population, new_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location, dea.Date) as RollingPeopleVaccinated
from covid dea
join vaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent != ''
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac


-- using temp table to perform calculation on partition by in previous query

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent varchar(255),
Location varchar(255),
Date datetime,
Population int,
New_vaccinations int,
RollingPeopleVaccinated int
)


insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
from covid dea
join vaccination vac
	On dea.location = vac.location
	and dea.date = vac.date

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



-- creating view to store data for later visualizations

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (partition by dea.Location order by dea.location, dea.Date) as RollingPeopleVaccinated
From covid dea
Join vaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent != ''
