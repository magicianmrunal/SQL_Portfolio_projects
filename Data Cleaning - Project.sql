/* 
THIS IS A DATA CLEANING PROJECT HERE WE HAVE A DATASET HAVING DATA ABOUT THE LAYOFFS OF PEOPLE AROUND THE WORLD. 
i HAVE USED SQL CONCEPTS LIKE DDL, DML, JOIN AND STRING FUNCTIONS TO CLEAN AND MAKE THIS DATA PRESENTABLE AND WORKABLE FOR FURTHER ANALYSIS
*/
SELECT *
FROM LAYOFFS;

-- 1. REMOVE DUPLICATES
-- 2. STANDARDIZE THE DATA (SPELLINGS, WRONG DATA, ETC)
-- 3. NULL VALUES OR BLANK VALUES
-- 4. REMOVE ANY COLUMNS

-- CREATIND A STAGING TABLE TO NOT AFFECT THE RAW DATA

CREATE TABLE LAYOFFS_STAGING
LIKE LAYOFFS;

INSERT INTO LAYOFFS_STAGING
SELECT *
FROM LAYOFFS;

SELECT * FROM LAYOFFS_STAGING;

-- 1. REMOVING DUPLICATES USING ROW_NUMBER()

SELECT *,
ROW_NUMBER() OVER(PARTITION BY COMPANY,  INDUSTRY, TOTAL_LAID_OFF, PERCENTAGE_LAID_OFF, `DATE`) AS ROW_NUM
FROM LAYOFFS_STAGING;

WITH DUPLICATE_CTE  AS 
(
SELECT *,
ROW_NUMBER() OVER(PARTITION BY COMPANY,LOCATION, INDUSTRY, TOTAL_LAID_OFF, PERCENTAGE_LAID_OFF, `DATE`,STAGE,
COUNTRY,FUNDS_RAISED_MILLIONS) AS ROW_NUM
FROM LAYOFFS_STAGING
)
SELECT *
FROM DUPLICATE_CTE
WHERE ROW_NUM > 1;

SELECT * 
FROM LAYOFFS_STAGING
WHERE COMPANY = 'CASPER';

 
 CREATE TABLE `layoffs_staging2` (
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


SELECT *
FROM LAYOFFS_STAGING2;

DROP TABLE LAYOFFS_STAGING2;

INSERT INTO LAYOFFS_STAGING2
SELECT *,
ROW_NUMBER() OVER(PARTITION BY COMPANY,LOCATION, INDUSTRY, TOTAL_LAID_OFF, PERCENTAGE_LAID_OFF, `DATE`,STAGE,
COUNTRY,FUNDS_RAISED_MILLIONS) AS ROW_NUM
FROM LAYOFFS_STAGING;


DELETE
FROM LAYOFFS_STAGING2
WHERE ROW_NUM > 1;


SELECT *
FROM LAYOFFS_STAGING2;

-- 2. STANDARDIZING THE DATA

SELECT COMPANY, TRIM(COMPANY)
FROM LAYOFFS_staging2;

UPDATE LAYOFFS_staging2							-- REMOVING BLANKS 
SET COMPANY = TRIM(COMPANY);

SELECT DISTINCT INDUSTRY
FROM LAYOFFS_STAGING2;
												-- CORRECTING SPELLINGS
UPDATE LAYOFFS_STAGING2
SET INDUSTRY = 'Crypto'
WHERE INDUSTRY LIKE 'CRYPTO%';

SELECT DISTINCT LOCATION
FROM layoffs_staging2
ORDER BY 1;

SELECT DISTINCT COUNTRY
FROM layoffs_staging2
ORDER BY 1;

SELECT DISTINCT COUNTRY, TRIM(TRAILING '.' FROM COUNTRY) 
FROM LAYOFFS_STAGING2
ORDER BY 1;

UPDATE LAYOFFS_STAGING2
SET COUNTRY = TRIM(TRAILING '.' FROM COUNTRY) 
WHERE COUNTRY LIKE 'UNITED STATES%';

SELECT `DATE`, STR_TO_DATE(`DATE`, '%m/%d/%Y')
FROM LAYOFFS_STAGING2;
													-- CORRECTING DATE FORMATTING
UPDATE LAYOFFS_STAGING2
SET `DATE` = STR_TO_DATE(`DATE`,'%m/%d/%Y');

ALTER TABLE LAYOFFS_STAGING2
MODIFY `date` DATE;

SELECT *
FROM LAYOFFS_STAGING2;

SELECT *
FROM LAYOFFS_STAGING2
WHERE INDUSTRY = '' OR INDUSTRY IS NULL ;

SELECT *
FROM LAYOFFS_STAGING2
WHERE INDUSTRY = '';

UPDATE LAYOFFS_STAGING2
SET INDUSTRY = NULL
WHERE INDUSTRY = '';
			
SELECT *
FROM LAYOFFS_STAGING2 T1
JOIN LAYOFFS_STAGING2 T2
	ON T1.COMPANY=T2.COMPANY
WHERE T1. INDUSTRY IS NULL 
AND T2.INDUSTRY IS NOT NULL    
;
														-- CORRECTING INDUSTRY COLUMN
UPDATE LAYOFFS_STAGING2 T1
JOIN LAYOFFS_STAGING2 T2
	ON T1.COMPANY=T2.COMPANY
SET T1.INDUSTRY = T2.INDUSTRY
WHERE T1. INDUSTRY IS NULL 
AND T2.INDUSTRY IS NOT NULL
;  

SELECT *
FROM layoffs_staging2
WHERE TOTAL_LAID_OFF IS NULL
AND PERCENTAGE_LAID_OFF IS NULL;

DELETE FROM layoffs_staging2
WHERE TOTAL_LAID_OFF IS NULL
AND PERCENTAGE_LAID_OFF IS NULL;

-- 4. REMOVE UNWANTED COLUMNS

ALTER TABLE layoffs_staging2
DROP COLUMN ROW_NUM;

SELECT * FROM layoffs_staging2;
