
-- Data Ref: https://ourworldindata.org/covid-deaths


--Select the data
Select Location, Date, total_cases, new_cases, total_deaths ,(total_deaths/total_cases), population
From PortfolioProject..Covid_Deaths
order by 1,2



-- Looking at Total Cases vs Total Death from latest complete information (2023-08-09)(y-m-d)
Select t1.Location, t1.Date, t1.total_cases, t1.total_deaths, round((cast(t1.total_deaths as float)*100/t1.total_cases),2) as PercentDeaths
From PortfolioProject..Covid_Deaths As t1
Inner join (
	Select Location,Max(Date) as Max_Date
	From PortfolioProject..Covid_Deaths
	where total_cases is not null and total_deaths is not null and continent is not null
	group by Location
) as t2 on t1.Location = t2.Location And t1.Date = t2.Max_Date
where t1.Location like '%Thai%'



-- Looking at Total Cases vs Population
-- Showing Percentage of population got COVID-19
Select t1.Location, t1.Date, t1.total_cases, t1.population, round((cast(t1.total_cases as float)*100/t1.population),2) as PercentInfected
From PortfolioProject..Covid_Deaths As t1
Inner join (
	Select Location,Max(Date) as Max_Date
	From PortfolioProject..Covid_Deaths
	where total_cases is not null and total_deaths is not null and population is not null and continent is not null
	group by Location
) as t2 on t1.Location = t2.Location And t1.Date = t2.Max_Date
where t1.Location like '%Thai%'



-- Looking at Countries with Highest Infection Rate compared to Population
Select t1.Location, MAX(t1.total_cases) as HighestInfectionCount, t1.population, round(Max((cast(t1.total_cases as float)*100/t1.population)),2) as PercentInfected
From PortfolioProject..Covid_Deaths As t1
Inner join (
	Select Location,Max(Date) as Max_Date
	From PortfolioProject..Covid_Deaths
	where total_cases is not null and total_deaths is not null and population is not null and continent is not null
	group by Location
) as t2 on t1.Location = t2.Location And t1.Date = t2.Max_Date
Group by t1.Location, t1.Population
Order by 4 Desc



--Showing Countries with Highest Death per Population
Select t1.Location, MAX(t1.total_deaths) as HighestDeathCount, t1.population, round(Max((cast(t1.total_deaths as float)*100/t1.population)),2) as PercentDeaths
From PortfolioProject..Covid_Deaths As t1
Inner join (
	Select Location,Max(Date) as Max_Date
	From PortfolioProject..Covid_Deaths
	where total_cases is not null and total_deaths is not null and population is not null and continent is not null
	group by Location
) as t2 on t1.Location = t2.Location And t1.Date = t2.Max_Date
Group by t1.Location, t1.Population
Order by 2 Desc



--Group by Continent
--Showing Continent with Highest Death per Population
--There was some mistake in this data collection some Continent data store in location column
Select t1.location,t1.date,Max(cast(t1.total_deaths as int)) as HighestDeathCount
From PortfolioProject..Covid_Deaths As t1
Inner join (
	Select location,Max(Date) as Max_Date
	From PortfolioProject..Covid_Deaths
	where total_cases is not null and total_deaths is not null and population is not null and continent is null
	group by location
) as t2 on t1.location = t2.location And t1.date = t2.Max_Date
Where t1.location in ('Africa','Asia','Europe','North America','Oceania','South America')
Group by t1.location,t1.date
Order by 3 Desc
---

--Showing Continent with Highest Death per Population (Same as above but assume all continent store in Continent column)
Select t1.continent,t1.date,Max(cast(t1.total_deaths as int)) as HighestDeathCount
From PortfolioProject..Covid_Deaths As t1
Inner join (
	Select continent,Max(Date) as Max_Date
	From PortfolioProject..Covid_Deaths
	where total_cases is not null and total_deaths is not null and population is not null and continent is not null
	group by continent
) as t2 on t1.continent = t2.continent And t1.date = t2.Max_Date
Group by t1.continent,t1.date
Order by HighestDeathCount desc



--Use Temp Table to calculate Vaccinated_percent
With PopvsVac (Continent, Location,Date,Population, new_vaccinations, total_vaccinations)
as(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(vac.new_vaccinations) over (Partition by dea.Location order by dea.date) as total_vaccinations
From PortfolioProject..Covid_Deaths as dea
Join PortfolioProject..Covid_Vac as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
)
Select *,(cast(total_vaccinations as float)/population)*100 as Percent_vaccinated
From PopvsVac



--Creating View to store data for visualizations
Drop view dbo.PercentPopulationVaccinated

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(float,vac.new_vaccinations)) over (Partition by dea.Location order by dea.date) as total_vaccinations
From PortfolioProject..Covid_Deaths as dea
Join PortfolioProject..Covid_Vac as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null












