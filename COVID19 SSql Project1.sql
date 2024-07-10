select* from MySSqlPortfolioProject1..['covid deaths$'] order by 3,4


--select* from MySSqlPortfolioProject1..['covid vaccinations$'] order by 3,4

--selects data that we will be using the order by 3,4 returns an excel like display

select Location, date, total_cases, new_cases, total_deaths, population
from MySSqlPortfolioProject1..['covid deaths$']
where continent is not null order by 1,2

--Total cases vs Total deaths and Mortality_rate

select Location, date, total_cases, total_deaths,
(cast(total_deaths as float)/cast(total_cases as float)) as Mortality_rate
from MySSqlPortfolioProject1..['covid deaths$']
where location like 'k%%ya' order by 1,2

--The cast ____ as datatype fn converts the deaths and cases into float where we can apply the divide operand, the where ___ like returns our suitable output

--Total_cases vs population and rate of contraction

select Location, date, total_cases, population,
(cast(total_cases as float)/cast(population as float)) as Contaction_rate 
from MySSqlPortfolioProject1..['covid deaths$']
where location like 'k%%ya' order by 1,2

--looking for countries with highest Contraction_rate
select Location, Population, max(cast(total_cases as float)) as HighestInfected, 
(cast(max(total_cases) as float)/cast(population as float)) as Contaction_rate from MySSqlPortfolioProject1..['covid deaths$'] where continent is not null group by location, population order by Contaction_rate desc

----The above code selects location,population of a country and the highest no of cases recorded among all the days and divides with the popolation to find the contraction rate, rearranges in descent

--Showing countries with highest death toll
select Location, Population, max(cast(total_deaths as float)) as TotaldeathCount 
from MySSqlPortfolioProject1..['covid deaths$'] where continent is not null
group by location, population order by TotaldeathCount desc



					--ANALYSING CONTINENTS COVID STATS


select  location, population, max(cast(total_deaths as float)) as TotaldeathCount 
from MySSqlPortfolioProject1..['covid deaths$'] where continent is null
group by location,population order by TotaldeathCount desc

select  continent, max(cast(total_deaths as float)) as TotaldeathCount from MySSqlPortfolioProject1..['covid deaths$']
where continent is not null group by continent order by TotaldeathCount desc

--though the right code but datawise inaccurate


--GLOBAL NUMBERS

select sum(new_cases) as totalcases, sum(new_deaths) as totaldeaths,
(sum(new_deaths)/sum(new_cases)) as GlobalMortality from MySSqlPortfolioProject1..['covid deaths$']
where continent is not null order by 1, 2 

--global mortality per day


---Total population vs vaccination 

select* from MySSqlPortfolioProject1..['covid deaths$'] dea 
join MySSqlPortfolioProject1..['covid vaccinations$'] vac 
on dea.location = vac.location and dea.date = vac.date

select dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location, dea.date)
as Rollingpeoplevaccinated from MySSqlPortfolioProject1..['covid deaths$'] dea 
join MySSqlPortfolioProject1..['covid vaccinations$'] vac on dea.location = vac.location 
and dea.date = vac.date where dea.continent is not null order by 2 ,3


--using CTE's to create a vaccination_rate parameter colulmn since using the rolling%%vac%%nated/totalppltn gives an error

with PopvsVac (continent, location, date, population, new_vaccinations, Rollingpeoplevaccinated) as
(select dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location, dea.date)
as Rollingpeoplevaccinated from MySSqlPortfolioProject1..['covid deaths$'] dea 
join MySSqlPortfolioProject1..['covid vaccinations$'] vac on dea.location = vac.location
and dea.date = vac.date where dea.continent is not null) select* ,
(Rollingpeoplevaccinated/population) as VaccinationRate from PopvsVac 

--using temptable
drop table if exists #VaccinationRate 
create table #VaccinationRate (continent nvarchar(255), location nvarchar(255),
date datetime, population numeric,new_vaccination numeric, Rollingpeoplevaccinated numeric) 
insert into #VaccinationRate select dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location, dea.date) 
as Rollingpeoplevaccinated from MySSqlPortfolioProject1..['covid deaths$'] dea 
join MySSqlPortfolioProject1..['covid vaccinations$'] vac 
on dea.location = vac.location and dea.date = vac.date where dea.continent is not null
select* , (Rollingpeoplevaccinated/population) as VaccinationRate from #VaccinationRate  


--create view to store data for later visualisation
create view Vaccination_Rate as 
select dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as float))
over (partition by dea.location order by dea.location, dea.date)
as Rollingpeoplevaccinated 
from MySSqlPortfolioProject1..['covid deaths$'] dea 
join MySSqlPortfolioProject1..['covid vaccinations$'] vac 
	on dea.location = vac.location
	and dea.date = vac.date 
where dea.continent is not null 
--order by 2 ,3 

select*
from Vaccination_Rate


