--World's Covid Data per 07-08-2023 by OurWorldInData.org--

--Covid Death and Cases Table
select * from [dbo].[CovidDeaths]

select continent, location, date, population, new_cases, total_cases, total_deaths 
from [dbo].[CovidDeaths]
order by 1,2 

--Look for daily total deaths vs total cases
select location, date, total_cases, total_deaths, (cast(total_deaths as float)/total_cases)*100 as DeathRate
from CovidDeaths
order by 1,2

--Looking at total deaths vs total cases in Indonesia
select location, date, total_cases, total_deaths, 
(cast(total_deaths as float)/total_cases)*100 as PersentaseKematianHarian
from CovidDeaths 
where location like 'indonesia'and continent is not null
order by PersentaseKematianHarian desc

--Covid total cases vs population in Indonesia
select location, date, population, total_cases,
(cast(total_cases as float)/population)*100 as PersentaseKasusHarian, total_deaths 
from CovidDeaths where location like 'indonesia'
order by 1,2

--Looking at the highest daily cases vs their population from highest to lowest
select location, population, max(total_cases) as infeksi_tertinggi,
Max(cast(total_cases as float)/population)*100 as PersentaseInfeksiHarian 
from CovidDeaths
where continent is not null 
group by location, population
order by PersentaseInfeksiHarian desc

--Looking at the country highest daily deaths vs their population from highest to lowest
select location, population, max(total_deaths) as KematianTertinggi,
Max(cast(total_deaths as float)/population)*100 as PersentaseKematianTertinggi 
from CovidDeaths
where continent is not null 
group by location, population
order by PersentaseKematianTertinggi desc

--Looking at which region has the highest total death 
select location, max(total_deaths) as KematianTertinggi
from CovidDeaths
where continent is null
group by location
order by KematianTertinggi desc  

--The percentage of total deaths vs total cases in every country sort by day
select date, sum(new_deaths) as kematian_harian, sum(new_cases) as kasus_harian,
sum(CASE  WHEN new_deaths=new_deaths THEN new_deaths END) /
nullif(sum(CASE  WHEN new_cases>0 THEN new_cases END),0)*100 persentase_kematian
from CovidDeaths
group by date
order by 1,2

--Covid Vaccination Table
select * from [dbo].[CovidVaccination]

--Total Vaccination partition by date
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.date) as Jumlah_Vaksin
from CovidDeaths dea
join CovidVaccination vac
on dea.location = vac.location and
dea.date = vac.date
where dea.continent is not null
order by 2,3 

--Total Vaccination vs Population by date
With VaccineRate (continent, location, date, population, new_vaccinations, jumlah_vaksin)
as (select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.date) as Jumlah_Vaksin
from CovidDeaths dea
join CovidVaccination vac
on dea.location = vac.location and
dea.date = vac.date
where dea.continent is not null)

select *, (jumlah_vaksin/population)*100 as PersentaseVaksin  
from VaccineRate

--Create Temp Table
Drop table if exists #VaccinePercentage
Create table #VaccinePercentage(  
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
jumlah_vaksin numeric)

insert into #VaccinePercentage
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.date) as Jumlah_Vaksin
from CovidDeaths dea
join CovidVaccination vac
on dea.location = vac.location and
dea.date = vac.date
where dea.continent is not null
select *, (jumlah_vaksin/population)*100 as PersentaseVaksin  
from #VaccinePercentage

--Create View
create view VaccinePercentageview as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.date) as Jumlah_Vaksin
from CovidDeaths dea 
join CovidVaccination vac
on dea.location = vac.location and
dea.date = vac.date
where dea.continent is not null

select * 
from VaccinePercentageview
