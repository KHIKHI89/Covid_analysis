select * from 
PortfolioProject..CovidDeaths$
order by 3,4
 
Select location , date , total_cases , new_cases , total_deaths , population from 
PortfolioProject..CovidDeaths$ 
order by 1,2

-- Total cases vs total deaths

select total_cases , total_deaths , location , date , (total_deaths/ total_cases)*100 as Death_percentage 
from PortfolioProject..CovidDeaths$
order by Death_percentage Desc

-- Total cases vs Population 

select  population ,location  ,max(total_cases) as highestinfectioncount, Max((total_cases/population)*100) as Cases_percentage 
from PortfolioProject..CovidDeaths$
--where location like  'Alg%'
group by population , location
order by Cases_percentage Desc

select   location , Max(cast(total_deaths as int )) as TotalDeath
from PortfolioProject..CovidDeaths$ 
where continent is not null 
group by location 
order by TotalDeath desc
 

-- continent with the highest death counts per population 


select continent , Max(cast(total_deaths as int )) as TotalDeath
from PortfolioProject..CovidDeaths$ 
where continent is not null 
group by continent 
order by 2 desc


-- Global Numbers 
select  date, Sum(new_cases) as total_cases , Sum(cast(new_deaths as int)) as total_deaths,
Sum(cast(new_deaths as int)) / sum(new_cases) *100
from PortfolioProject..CovidDeaths$
where continent is not null 
group by date
order by 2, 3 desc

select  Sum(new_cases) as total_cases , Sum(cast(new_deaths as int)) as total_deaths,
Sum(cast(new_deaths as int)) / sum(new_cases) *100
from PortfolioProject..CovidDeaths$
where continent is not null 
order by 2, 3 desc

-- Joining the two tables ---


-- looking for the total population vs the total vaccination 

Select dea.continent, dea.location, dea.date , dea.population  , vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location , dea.date)
from PortfolioProject..CovidDeaths$ as dea
join PortfolioProject..CovidVaccinations$ as vac
    On dea.location = vac.location
    and dea.date = vac.date
where vac.new_vaccinations is not null and dea.continent is not null

order by 2,3

-- using ETC ----

with Popvsvac ( continent , location , date , population ,new_vaccination , rollingeoplevaccinated)as
(
Select dea.continent, dea.location, dea.date , dea.population  , vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location , dea.date)
from PortfolioProject..CovidDeaths$ as dea
join PortfolioProject..CovidVaccinations$ as vac
    On dea.location = vac.location
    and dea.date = vac.date
where vac.new_vaccinations is not null and dea.continent is not null


)

select * , (rollingeoplevaccinated/population) * 100
from Popvsvac

-- second possibility: using temp_table ----
drop table if exists #vaccinatedpeople

Create table #vaccinatedpeople 
(
continent nvarchar(255),
location nvarchar(255),
date datetime ,
population numeric ,
new_vaccination numeric ,
roollingpeoplevaccinated numeric )

insert into #vaccinatedpeople
Select dea.continent, dea.location, dea.date , dea.population  , vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location , dea.date)
from PortfolioProject..CovidDeaths$ as dea
join PortfolioProject..CovidVaccinations$ as vac
    On dea.location = vac.location
    and dea.date = vac.date
where vac.new_vaccinations is not null and dea.continent is not null

select * , (roollingpeoplevaccinated / population) *100
from
#vaccinatedpeople


--Creating veiw ---

CREATE VIEW percentagepeoplevaccinated as 
Select dea.continent, dea.location, dea.date , dea.population  , vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location , dea.date) as rollingpeoplevaccinated
from PortfolioProject..CovidDeaths$ as dea
join PortfolioProject..CovidVaccinations$ as vac
    On dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null


select * from percentagepeoplevaccinated