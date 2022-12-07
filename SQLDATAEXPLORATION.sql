--Data Exploration in SQL

-- Select data that will be used

Select *
From PortfolioProject..Deaths
order by 3,4

-- Rate of Death from Covid-19 for Each Country

Select Location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..Deaths
order by 1,2

-- Rate of Death from Covid-19 in Australia 2022

Select Location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..Deaths
where location = 'Australia' and date >= '2022-01-01'
order by 1,2

-- Total New Cases in Australia in 2022

With Aus2022 As (
Select Location, date, total_cases, new_cases, total_deaths
From PortfolioProject..Deaths
where location = 'Australia' and date >= '2022-01-01'
)
Select Sum(new_cases) as NewCases2022
From Aus2022

-- Australian population vs Number of Cases in Australia  

Select Location, date, total_cases, population, (total_cases/population)*100 as CasePercentage
From PortfolioProject..Deaths
where location = 'Australia' 
order by 2

-- Order of Countries by Percent of Population Infected

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..Deaths
where continent is not null
Group by Location, Population
order by PercentPopulationInfected desc

-- Order of Countries by Total Death Count

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..Deaths
Where continent is not null
Group by Location
order by TotalDeathCount desc

-- Total Death Count by Continent

With TotalDeathLocation as (
Select Location, continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..Deaths
Where continent is not null
Group by Location, continent
)
Select Continent, sum(TotalDeathCount) as TotalDeathContinent
From TotalDeathLocation
Group by continent
Order by 2 DESC

-- Global Rolling Cases and Rolling Deaths

With GlobalCasevsDeath as
(
Select date, sum(new_cases) as Global_new_cases, sum(cast(new_deaths as int)) as Global_new_deaths 
from PortfolioProject..Deaths
where continent is not null
group by date
)
Select*, sum(Global_new_cases) Over (order by date) as RollingGlobalCases, sum(Global_new_deaths) Over (order by date) as RollingGlobalDeaths
From GlobalCasevsDeath

-- Select Vaccination Data

Select *
From PortfolioProject..Vaccinations
order by 3,4

-- Looking at Total Population vs New Vaccinations vs Rolling People Vaccinated by Country

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(Cast(vac.new_vaccinations as bigint)) Over (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..Deaths dea
Join PortfolioProject..Vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

--Use CTE to Calculate Rolling Percentage of Vaccinations vs Population by Country 

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(Cast(vac.new_vaccinations as bigint)) Over (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..Deaths dea
Join PortfolioProject..Vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
)
Select*, (RollingPeopleVaccinated/population)*100 as RollingPeopleVaccinatedPercent
From PopvsVac
order by 2,3


-- Use Temp Table to Calculate Rolling Percentage of Vaccinations vs Population by Country 

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..Deaths dea
Join PortfolioProject..Vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100 as RollingPeopleVaccinatedPercent
From #PercentPopulationVaccinated

-- Creating View to Store Data for Visualizations

Create View RollingVaccinations as
With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(Cast(vac.new_vaccinations as bigint)) Over (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..Deaths dea
Join PortfolioProject..Vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
)
Select*, (RollingPeopleVaccinated/population)*100 as RollingPeopleVaccinatedPercent
From PopvsVac



-- THE END