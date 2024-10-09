-- data cleaning


use layoffs;
select * from layoffs;


CREATE TABLE `layoffs2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

select * from layoffs2;

insert into layoffs2
select * ,
row_number() over (partition BY company, industry,
total_laid_off, percentage_laid_off, 'date') as row_num
from layoffs;

select * from layoffs2;


-- --remove duplicates

select *from  layoffs2
where row_num>1;


delete from layoffs2
where row_num>1;


select * from layoffs2;



-- stanardize the data
select company, TRIM(company) from layoffs2;

update layoffs2
set company=TRIM(company);

select company from layoffs2;

select industry from layoffs2 
group  by industry;

select location from layoffs2;

update layoffs2
set industry = "crypto"
where industry like "crypto%";


use layoffs;

select distinct location 
from layoffs2     -- --check the issue there is no issue---- 
order by 1 ; 

select distinct country , TRIM(TRAILING '.' FROM COUNTRY)
from layoffs2
order by 1;

update layoffs2
set country = TRIM(TRAILING'.' FROM COUNTRY)
WHERE COUNTRY LIKE 'united states%';

select distinct country   -- check the isseue and issue resolving  by updating
from layoffs2 order  by 1;

select `date`
from layoffs2;   -- check issue and change date format

update layoffs2
set `date`= STR_TO_DATE(`date`, '%m/%d/%Y');

ALTER TABLE layoffs2
modify column `date` DATE; -- MODIFY THE COLUMN FROM TEXT TO DATE

-- null value or blank value
SELECT * from layoffs2
where industry is null  -- 3 rows in industry which have blank row
or industry = '';

update layoffs2
set industry = null   -- by update we change 3 blank row with null 
where industry ='';

select * from layoffs2
where industry is null
or industry = '';    -- 3 rows in industry which have blank row

select t1.industry ,t2.industry
from layoffs2 t1
join layoffs2 t2
on t1.company=t2.company
and t1.location = t2.location
where (t1.industry is null or t1.industry='')
and t2.industry is not null;


update layoffs2 t1
join layoffs2 t2
on t1.company = t2.company
set t1.industry= t2.industry
where t1.industry is null
and t2.industry is not null;

select location from layoffs2;

select * from layoffs2
where total_laid_off is null
and percentage_laid_off is null;


delete 
from layoffs2
where total_laid_off is  null
and percentage_laid_off is null;

select * from layoffs2;   -- remove any column--
ALTER TABLE layoffs2
drop column row_num;


-- exploratory analysis

-- --1 how many layoffs happend per country?

select country, sum(total_laid_off)
as total_layoffs
from layoffs2
group by country
order by total_layoffs desc
limit 10;


-- --2 which industry faced the highest number of layoffs
select industry , sum(total_laid_off)
as total_layoffs
from layoffs2
group by industry 
order by total_layoffs desc;

-- 3. whuch companise laid off more than a 
-- certain threshold of employees ( eg.,1000)?
-- --isme layoffs jiska 1000 se upar ka hoga wo show kar deag 
select company , total_laid_off
from layoffs2
where total_laid_off>1000
order by total_laid_off desc;

-- isme layoffs jiska 1000 se upar ka hoga wo show kar deag 
select company , total_laid_off
from layoffs2
where total_laid_off>5000
order by total_laid_off desc;

-- 4. what is the average percentage of workforce laid off per industry?-- 
select industry,avg(percentage_laid_off)
as avg_percentage_laid_off
from layoffs2
group by industry
order by avg_percentage_laid_off desc;

-- 5. what are the top 10 companies with the most layoffs ?--

select company,total_laid_off
from layoffs2
order  by total_laid_off desc
limit 10;

-- 6. what is the total number off layoffs across all companies?

select sum(total_laid_off) as total_offs
from layoffs2;

-- 7. how many layoffs occurred in each funding stage(e.g, post-IPO, series B)

SELECT stage , count(*) as num_layoffs
from layoffs2
group by stage 
order by num_layoffs desc;

-- 8.which country raised the highest amount of funds?
select country ,sum(funds_raised_millions)
as total_fund_raised
from layoffs2
group by country
order by total_fund_raised desc
limit 10;

-- 9. which companies had layoffs with missing data for percentage laid off?

select company, total_laid_off
from layoffs2
where percentage_laid_off is null
order by total_laid_off desc;

-- 10. how many layoffs occured in a specific time period (eg.,2023)?

select count(*) as layoffs_in_2023
from layoffs2
where year(date)= 2023;

-- 11, whichh countries have the highest percentage of
-- layoffs relative to their total workforce-- 
select country, avg (percentage_laid_off) 
as avg_percentage_laid_off
from layoffs2
group by country 
order by avg_percentage_laid_off desc
limit 10;

-- 12, what is the distribution of layoffs across different location (cities)?-- 
select location , count(*) as num_offs 
from layoffs2
group by location 
order by num_offs desc;

-- 13.what are the top 5 industries that raised the most funds and had layoffs ?

select industry,sum(funds_raised_millions)
as total_funds_raised
from layoffs2
where total_laid_off>0
group by industry 
order by total_funds_raised desc
limit 5;

-- 14. maximum of total_laid_off and percentage_laid_off ?
select max(total_laid_off),
max(percentage_laid_off)
from layoffs2;

-- 15.layoffs from start date to end date?
select min(`date`),max(`date`)
from layoffs2;

-- 16. sum of total_laid_off by year?
select year (`date`), sum(total_laid_off)
from layoffs2
group by year (`date`)
order by 1 desc;

-- 17. show the layoffs by industryb and break them down by company stage? (eg. post-ipo, series B, ETC)

select industry , stage , sum(total_laid_off)
as total_layoffs
from layoffs2
group by industry , stage 
order by industry;

-- 11, whichh countries have the highest percentage of
-- layoffs relative to their total workforce-- 
select country, round(avg(percentage_laid_off))
as avg_percentage_laid_off
from layoffs2
group by country 
order by avg_percentage_laid_off desc
limit 10;





