Select *
From PortifolioProject..CovidDeaths
Where continent is not NULL
Order By 3,4

--Select *
--From PortifolioProject..CovidVaccinations
--Order By 3,4
Select location,date,total_cases,new_cases,population
From PortifolioProject..CovidDeaths
Order By 1,2

Alter Table PortifolioProject..CovidDeaths
Alter column total_deaths float
Go
--Looking at total cases vs Total Deaths
Select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 As DeathPercentage
From PortifolioProject..CovidDeaths
Where location like '%states%'
Order By 1,2
---looking at total_cases vs location
Select location,population,MAX(total_cases) AS HighestInfecCount,MAX((total_cases/population))*100 AS 
InfectedPopulation
from PortifolioProject..CovidDeaths
Group BY location,population
--Where location like '%states%'
Order By InfectedPopulation desc

--Highest Death Count
Select location,MAX(total_deaths) AS DeathCount
from PortifolioProject..CovidDeaths
Where continent is not NULL
Group BY location
--Where location like '%states%'
Order By DeathCount desc
-----BY CONTINENT DEATH RATE
Select continent,MAX(total_deaths) AS DeathCount
from PortifolioProject..CovidDeaths
Where continent is not NULL
Group BY continent
--Where location like '%states%'
Order By DeathCount desc


--Showing continets with highest death count
Select continent,MAX(total_deaths) AS DeathCount
from PortifolioProject..CovidDeaths
Where continent is not NULL
Group BY continent
--Where location like '%states%'
Order By DeathCount desc
--Gloabal Numbers
Select SUM(new_cases) AS TotalNewCases,SUM(new_deaths),Sum(new_deaths)/SUM(new_cases)*100 As DeathPercentage
From PortifolioProject..CovidDeaths
--Where location like '%states%'
--Group by date
Order By 1,2

---USE CTE
With PopvsVac(continent ,location, date, population, new_vaccinations,RollingPeopleVaccinated)
as
(
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,Sum(Convert(float,vac.new_vaccinations )) OVER(partition by dea.location Order by
dea.location,dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/dea.population)
From PortifolioProject..CovidDeaths dea
JOIN PortifolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date 
Where dea.continent is not null
--ORDER BY 2,3
)	

Select * ,(RollingPeopleVaccinated/population)
From PopvsVac

----USE Temp Table
DROP Table If Exists #PercentPopulationVaccinated
CREATE Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,Sum(Convert(float,vac.new_vaccinations )) OVER(partition by dea.location Order by
dea.location,dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/dea.population)
From PortifolioProject..CovidDeaths dea
JOIN PortifolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date 
--Where dea.continent is not null
--ORDER BY 2,3

Select * ,(RollingPeopleVaccinated/population)
From #PercentPopulationVaccinated

---Creating Views
DROP VIEW IF EXISTs PercentPopulationVaccinated
CREATE VIEW PercentPopulationVaccinated AS
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,Sum(Convert(float,vac.new_vaccinations )) OVER(partition by dea.location Order by
dea.location,dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/dea.population)
From PortifolioProject..CovidDeaths dea
JOIN PortifolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date 
Where dea.continent is not null
--ORDER BY 2,3

Select *
From PercentPopulationVaccinated 