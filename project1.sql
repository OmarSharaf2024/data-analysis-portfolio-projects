select*
from PortfolioProject1..CovidDeaths$
order by 3,4

select*
from PortfolioProject1..vaccination$
order by 3,4

--select data that we are going to use

select location, date, population, total_cases, new_cases, total_deaths
from PortfolioProject1..CovidDeaths$
order by 1,2

--shows the probabilty of dying if anyone contracts covid in Egypt

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deaths_percentage
from PortfolioProject1..CovidDeaths$
where location = 'egypt' and total_cases is not null
order by 2

--looking at total cases vs population
select location, date, total_cases, population, (total_cases/population)*100 as cases_percentage
from PortfolioProject1..CovidDeaths$
where location = 'egypt' and total_cases is not null
order by 2

--looking at countries with highest infiction rate
select location, max(total_cases) as totalCasesCount, population, (max(total_cases)/population)*100 as cases_percentage
from PortfolioProject1..CovidDeaths$
group by location , population
order by 4 desc

--looking at countries with highest death rate
select location, max(cast(total_deaths as int)) as totalDeathsCount, population, (max(cast(total_deaths as int))/population)*100 as deaths_percentage
from PortfolioProject1..CovidDeaths$
where continent is not null
group by location , population
order by 4 desc

-- Global numbers
select date, sum(new_cases) as total_Cases, sum(cast(new_deaths as int)) as tatal_Deaths,  (sum(cast(new_deaths as int))/sum(new_cases))*100 as deaths_percintage
from PortfolioProject1..CovidDeaths$ 
where continent is Not null
group by date
order by 1,2

--looking at total population vs vaccination
select dea.location,dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location , dea.date)
as total_peoble_vaccinated
from PortfolioProject1..CovidDeaths$ dea
join PortfolioProject1..vaccination$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 1,2


-- use cte

with PopvsVac (location, date, population, new_vaccinations, total_peoble_vaccinated)
as
(
select dea.location,dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location , dea.date)
as total_peoble_vaccinated
from PortfolioProject1..CovidDeaths$ dea
join PortfolioProject1..vaccination$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
)
select*, total_peoble_vaccinated/population*100 as peoble_vacc_percintage
from PopvsVac


--create temp table

drop table if exists #peoble_vacc_percintage
create table #peoble_vacc_percintage
(
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
total_peoble_vaccinated numeric
)
insert into #peoble_vacc_percintage
select dea.location,dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location , dea.date)
as total_peoble_vaccinated
from PortfolioProject1..CovidDeaths$ dea
join PortfolioProject1..vaccination$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

select*, total_peoble_vaccinated/population*100 as peoble_vacc_percintage
from #peoble_vacc_percintage
order by 1,2


--creating view to store for later visualization

create view peoble_vacc_percintage as
select dea.location,dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location , dea.date)
as total_peoble_vaccinated
from PortfolioProject1..CovidDeaths$ dea
join PortfolioProject1..vaccination$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null