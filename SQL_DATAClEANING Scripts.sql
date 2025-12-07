/* Cleaning data in SQL Queries */

Select *
From SQLDataCleaning.dbo.NashvilleHousing
-----------------------------------------------------------------------------
-- Standardize Date Format

Select SaleDate
From SQLDataCleaning.dbo.NashvilleHousing

Select SaleDate, CONVERT(Date,SaleDate)
From SQLDataCleaning.dbo.NashvilleHousing

 -- ?? When you run this query
--SELECT SaleDate, CONVERT(Date, SaleDate)
--FROM NashvilleHousing
--It does not change anything in the table.
--It only shows you how the data would look if you converted it to Date format.
--SaleDate (original)	CONVERT(Date, SaleDate) (temporary)
--2013-04-09 00:00:00.000	         2013-04-09
--2014-06-10 00:00:00.000	         2014-06-10
--So this is just a preview, not a real change.

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

--?? You ran this command
--UPDATE NashvilleHousing
--SET SaleDate = CONVERT(Date, SaleDate)
--? It says “(56477 rows affected)” — that means the query executed successfully
--? But — here’s the tricky part:
--If the SaleDate column type is still datetime,
--then even after the update, SQL Server stores it again as:
--2013-04-09 00:00:00.000
--Why? Because the data type itself (datetime) forces it to show both date and time.
--Even though you set only the date part, SQL adds 00:00:00.000 automatically.
--So, the update did happen,
--but visually it looks the same because the column type didn’t change

--?? Verify the column data type
--Run this:
--EXEC sp_help 'NashvilleHousing'
--- OR
--USE SQLDataCleaning;
--GO
--EXEC sp_help 'NashvilleHousing';
--Check the SaleDate column’s Type:
--•	If it says datetime ? the update didn’t visibly change anything.
--•	If it says date ? then it will show only the date (no time part).
--?? How to actually store only date :
--Backup column (safe step)


UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

-- RUN TO VERIFY 
Select SaleDateConverted
From SQLDataCleaning.dbo.NashvilleHousing

--OR
--If you really want to remove time permanently,
--you must change the column’s data type like this:

--UPDATE NashvilleHousing
--SET SaleDate = CONVERT(date, SaleDate);

--ALTER TABLE NashvilleHousing
--ALTER COLUMN SaleDate DATE;

--Now when you do:
--SELECT SaleDate FROM NashvilleHousing;
--You’ll see only:
--SaleDate
--2013-04-09
--2014-06-10
--2015-08-12
--? No time part anymore!

-----------------------------------------------------------------------------

-- Populate Property Address Data

Select *
From SQLDataCleaning.dbo.NashvilleHousing

Select [UniqueID ], ParcelID, PropertyAddress
From SQLDataCleaning.dbo.NashvilleHousing
Order by ParcelID


--Note: 
--•  If a ParcelID appears more than once, this query lets you see duplicates clearly.
--•  You can check for different PropertyAddress values or missing addresses for the same parcel.

--For example, using your small table:
--UniqueID	ParcelID	PropertyAddress
--1	1001	123 Main St
--2	1001	NULL
--3	1002	45 River Rd
--4	1002	45 River Rd
--5	1003	200 Oak Ln

Select a.[UniqueID ], a.ParcelID, a.PropertyAddress, b.[UniqueID ], b.ParcelID, b.PropertyAddress
From SQLDataCleaning.dbo.NashvilleHousing a
Join SQLDataCleaning.dbo.NashvilleHousing b
  on a.ParcelID = b.ParcelID
  AND a.[UniqueID ] <> b.[UniqueID ]

--  Notes to understand to above query:

--We’ll use our small example table:
--UniqueID	ParcelID	PropertyAddress
--1	1001	123 Main St
--2	1001	NULL
--3	1002	45 River Rd
--4	1002	45 River Rd
--5	1003	200 Oak Ln

----All possible pairings with PropertyAddress


--a.UniqueID	a.ParcelID	a.PropertyAddress	b.UniqueID	b.ParcelID	b.PropertyAddress	Keep?
--1	1001	123 Main St	1	1001	123 Main St	? same UniqueID
--1	1001	123 Main St	2	1001	NULL	? keep
--1	1001	123 Main St	3	1002	45 River Rd	? ParcelID different
--1	1001	123 Main St	4	1002	45 River Rd	? ParcelID different
--1	1001	123 Main St	5	1003	200 Oak Ln	? ParcelID different
--2	1001	NULL	1	1001	123 Main St	? keep
--2	1001	NULL	2	1001	NULL	? same UniqueID
--2	1001	NULL	3	1002	45 River Rd	? ParcelID different
--2	1001	NULL	4	1002	45 River Rd	? ParcelID different
--2	1001	NULL	5	1003	200 Oak Ln	? ParcelID different
--3	1002	45 River Rd	1	1001	123 Main St	? ParcelID different
--3	1002	45 River Rd	2	1001	NULL	? ParcelID different
--3	1002	45 River Rd	3	1002	45 River Rd	? same UniqueID
--3	1002	45 River Rd	4	1002	45 River Rd	? keep
--3	1002	45 River Rd	5	1003	200 Oak Ln	? ParcelID different
--4	1002	45 River Rd	1	1001	123 Main St	? ParcelID different
--4	1002	45 River Rd	2	1001	NULL	? ParcelID different
--4	1002	45 River Rd	3	1002	45 River Rd	? keep
--4	1002	45 River Rd	4	1002	45 River Rd	? same UniqueID
--4	1002	45 River Rd	5	1003	200 Oak Ln	? ParcelID different
--5	1003	200 Oak Ln	1	1001	123 Main St	? ParcelID different


--5	1003	200 Oak Ln	2	1001	NULL	? ParcelID different
--5	1003	200 Oak Ln	3	1002	45 River Rd	? ParcelID different
--5	1003	200 Oak Ln	4	1002	45 River Rd	? ParcelID different
--5	1003	200 Oak Ln	5	1003	200 Oak Ln	? same UniqueID

--Filtered result (only Keep? = ?)
--a.UniqueID	a.ParcelID	a.PropertyAddress	b.UniqueID	b.ParcelID	b.PropertyAddress
--1	1001	123 Main St	2	1001	NULL
--2	1001	NULL	1	1001	123 Main St
--3	1002	45 River Rd	4	1002	45 River Rd
--4	1002	45 River Rd	3	1002	45 River Rd


Select a.[UniqueID ], a.ParcelID, a.PropertyAddress, b.[UniqueID ], b.ParcelID, b.PropertyAddress
From SQLDataCleaning.dbo.NashvilleHousing a
Join SQLDataCleaning.dbo.NashvilleHousing b
  on a.ParcelID = b.ParcelID
  AND a.[UniqueID ] <> b.[UniqueID ]
  Where a.PropertyAddress is Null

  Select a.[UniqueID ], a.ParcelID, a.PropertyAddress, b.[UniqueID ], b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From SQLDataCleaning.dbo.NashvilleHousing a
Join SQLDataCleaning.dbo.NashvilleHousing b
  on a.ParcelID = b.ParcelID
  AND a.[UniqueID ] <> b.[UniqueID ]
  Where a.PropertyAddress is Null

--  Note :
--The ISNULL() function works like this:
--•	If a.PropertyAddress is NOT NULL, it keeps its value.
--If a.PropertyAddress is NULL, it replaces it with b.PropertyAddress

 UPDATE a
 SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
 From SQLDataCleaning.dbo.NashvilleHousing a
 Join SQLDataCleaning.dbo.NashvilleHousing b
 on a.ParcelID = b.ParcelID
 AND a.[UniqueID ] <> b.[UniqueID ]

-- execute this query to check :
Select a.[UniqueID ], a.ParcelID, a.PropertyAddress, b.[UniqueID ], b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From SQLDataCleaning.dbo.NashvilleHousing a
Join SQLDataCleaning.dbo.NashvilleHousing b
  on a.ParcelID = b.ParcelID
  AND a.[UniqueID ] <> b.[UniqueID ]
  Where a.PropertyAddress is Null

  -- if above query returns zero rows, it means the update worked — all missing addresses were filled.

  -- update concept with small earlier example
--?? Your join result before the update
--a.UniqueID	a.ParcelID	a.PropertyAddress	b.UniqueID	b.ParcelID	b.PropertyAddress
--1	1001	123 Main St	2	1001	NULL
--2	1001	NULL	1	1001	123 Main St
--3	1002	45 River Rd	4	1002	45 River Rd
--4	1002	45 River Rd	3	1002	45 River Rd

--?? Row 1
--•	a.UniqueID = 1 ? PropertyAddress = '123 Main St'
--•	b.PropertyAddress = NULL
--•	ISNULL('123 Main St', NULL) ? ‘123 Main St’
--? No change — it already has an address.
--________________________________________

--?? Row 2
--•	a.UniqueID = 2 ? PropertyAddress = NULL
--•	b.PropertyAddress = ‘123 Main St’ (from the other record with same ParcelID 1001)
--•	ISNULL(NULL, '123 Main St') ? ‘123 Main St’
--? Updated! — address filled from the matching record.
--________________________________________
--?? Row 3
--•	a.UniqueID = 3 ? 45 River Rd
--•	b.PropertyAddress = 45 River Rd
--•	ISNULL(‘45 River Rd’, ‘45 River Rd’) ? ‘45 River Rd’
--? No change — both already have values.
--1?? after update - See the full table (be careful — it’s big!)  
--•	SELECT *
--•	FROM SQLDataCleaning.dbo.NashvilleHousing;
--2?? Just check the top few rows
--SELECT TOP 20 *
--FROM SQLDataCleaning.dbo.NashvilleHousing;
--This will display the first 20 records — great for a quick glance.

--3?? Check only rows where the address was NULL before
--Since we updated rows that had missing addresses, let’s verify those:
--SELECT ParcelID, PropertyAddress
--FROM SQLDataCleaning.dbo.NashvilleHousing
--WHERE PropertyAddress IS NULL;
--?? If this returns zero rows, it means the update worked — all missing addresses were filled.
--4?? Compare addresses of same ParcelIDs
--SELECT ParcelID, COUNT(DISTINCT PropertyAddress) AS DifferentAddresses
--FROM SQLDataCleaning.dbo.NashvilleHousing
--GROUP BY ParcelID
--HAVING COUNT(DISTINCT PropertyAddress) > 1;
--LET’S UNDERSTAND THIS QUERY WITH SMALL PREVIOUS EXAMPLE
--?? Step 1 — GROUP BY ParcelID
--This makes SQL collect all rows with the same ParcelID together.
--Example:
--ParcelID	PropertyAddress
--1001	123 Main St
--1001	123 Main St
--1001	125 Main St
--After GROUP BY ParcelID, SQL will treat these 3 rows as one group for ParcelID = 1001.________________________________________?? Step 2 — COUNT(DISTINCT PropertyAddress)
--Inside each group, SQL counts how many unique addresses exist.
--Continuing our example:
--ParcelID	PropertyAddress	Unique?
--1001	123 Main St	?
--1001	123 Main St	? (duplicate)
--1001	125 Main St	?
--So:
--COUNT(DISTINCT PropertyAddress) = 2
--That means — for this parcel, there are two different addresses found in the table.________________________________________

--?? Step 3 — HAVING COUNT(DISTINCT PropertyAddress) > 1
--The HAVING clause works like a WHERE, but for grouped data.
--It keeps only those groups where the count of distinct addresses is greater than 1.
--So:
--•	If a ParcelID has only one unique address ? it’s clean ? ? excluded.
--•	If a ParcelID has two or more unique addresses ? that’s inconsistent ?? ? shown in the result.
--________________________________________
--?? Step 4 — What it shows after UPDATE
--After your update, most rows that were NULL now got filled with their correct addresses.
--? So, this query now helps you verify the quality of your update.
--It shows only those ParcelIDs that still have more than one distinct address — meaning, something like:
--ParcelID	DifferentAddresses
--025 12 0 071.00	2
--026 02 0 010.00	2
--That’s SQL telling you:
--“Hey! These ParcelIDs still have 2 different address values in the table.”
--Project real data shows when executed this query:
--To check how many different PropertyAddresses exist for each ParcelID.
-- execute:
SELECT ParcelID, COUNT(DISTINCT PropertyAddress) AS DifferentAddresses
FROM SQLDataCleaning.dbo.NashvilleHousing
GROUP BY ParcelID
HAVING COUNT(DISTINCT PropertyAddress) > 1;

--To check the exact duplicate rows (same ParcelID and same PropertyAddress together repeated).:
Execute:
SELECT ParcelID, PropertyAddress, COUNT(*) AS Records
FROM SQLDataCleaning.dbo.NashvilleHousing
GROUP BY ParcelID, PropertyAddress
ORDER BY ParcelID;

--“Group all properties by their ParcelID and Address, count how many records exist for each combination, and sort by ParcelID.”

--check with parcel ids:
SELECT PropertyAddress, ParcelID
FROM SQLDataCleaning.dbo.NashvilleHousing
WHERE ParcelID = '025 12 0 071.00';

SELECT ParcelID, PropertyAddress
FROM SQLDataCleaning.dbo.NashvilleHousing
WHERE ParcelID IN (
  SELECT ParcelID
  FROM SQLDataCleaning.dbo.NashvilleHousing
  GROUP BY ParcelID
  HAVING COUNT(DISTINCT PropertyAddress) > 1
)
 ORDER BY ParcelID;

 -- now Execute it
 
-- What’s really happening behind the scenes:
--SQL sees this as two different strings:
--'301  MYSTIC HILL DR, GOODLETTSVILLE' 
--? 
--'301 MYSTIC HILL  DR, GOODLETTSVILLE'
--Even though to your eyes they’re the same address, to SQL it’s a mismatch because of spaces.

--Data cleaning step to fix the kind of problem you’re seeing right now:

UPDATE SQLDataCleaning.dbo.NashvilleHousing
SET PropertyAddress = LTRIM(RTRIM(REPLACE(PropertyAddress, '  ', ' ')));

--? LTRIM(RTRIM(REPLACE(PropertyAddress, ' ', ' ')))
--    cleans both extra spaces between words and spaces at the start or end.

--To understand above query, here is small example step by step:

--Step 0 — Sample Table
--Let’s assume a small table:
--UniqueID	ParcelID	PropertyAddress
--1	033 16 0 131.00	1128 NELSON DR, MADISON
--2	033 16 0 131.00	221 SLAYTON DR, MADISON
--3	163 07 0A 104.00	2222 DALE VIEW DR, ANTIOCH
--4	163 07 0A 104.00	2224 DALE VIEW DR, ANTIOCH
--5	043 05 0 282.00	336 ANDERSON LN, MADISON
--6	043 05 0 282.00	829 BIXLER AVE, MADISON
--Notice that some ParcelIDs repeat but have different PropertyAddresses.
--________________________________________
--Step 1 — Inner Query
--SELECT ParcelID
--FROM SQLDataCleaning.dbo.NashvilleHousing
--GROUP BY ParcelID
--HAVING COUNT(DISTINCT PropertyAddress) > 1;
--What this does:
--1.	GROUP BY ParcelID ? groups all rows by ParcelID.
--2.	COUNT(DISTINCT PropertyAddress) ? counts how many unique addresses exist per ParcelID.
--3.	HAVING COUNT(DISTINCT PropertyAddress) > 1 ? keeps only ParcelIDs that have more than 1 unique address (i.e., duplicates/conflicts).
--Inner Query Result (ParcelIDs)
--ParcelID
--033 16 0 131.00
--163 07 0A 104.00
--043 05 0 282.00
--? These are the ParcelIDs where there are multiple addresses.

--Step 2 — Outer Query
--SELECT ParcelID, PropertyAddress
--FROM SQLDataCleaning.dbo.NashvilleHousing
--WHERE ParcelID IN ( ... )
--ORDER BY ParcelID;
--How it works:
--1.	The WHERE ParcelID IN (...) filters rows to only the ParcelIDs returned by the inner query.
--2.	This means we only see rows with conflicting/multiple addresses.
--3.	ORDER BY ParcelID ? sorts the result by ParcelID for easier reading.
--Step 2 Result — Filtered Data
--ParcelID	PropertyAddress
--033 16 0 131.00	1128 NELSON DR, MADISON
--033 16 0 131.00	221 SLAYTON DR, MADISON
--163 07 0A 104.00	2222 DALE VIEW DR, ANTIOCH
--163 07 0A 104.00	2224 DALE VIEW DR, ANTIOCH
--043 05 0 282.00	336 ANDERSON LN, MADISON
--043 05 0 282.00	829 BIXLER AVE, MADISON
--? Now you can see exactly which ParcelIDs have more than one address, so you can clean or standardize them.

--Step 3 — Why this is useful
--•	This is a common data cleaning step for a data analyst:
--1.	Identify ParcelIDs with inconsistent addresses.
--2.	Standardize them or remove duplicates.
--3.	Ensure data quality before analysis.

--To delete the duplicate rows (same ParcelID and same PropertyAddress together repeated).:

WITH RowNumCTE AS (
  SELECT *,
         ROW_NUMBER() OVER (
             PARTITION BY ParcelID, PropertyAddress
             ORDER BY (SELECT NULL)
         ) AS row_num
  FROM NashvilleHousing
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1;

--To understand this query, here is small example:

--?? Step-by-step explanation
--?? Step 1 — Understand the data
--Your table before running the query ??
--UniqueID	ParcelID	PropertyAddress
--1	1001	123 Main St, Nashville
--2	1001	123 Main St, Nashville
--3	1002	45 River Rd, Madison
--4	1002	45 River Rd, Madison
--5	1003	88 Hilltop Ln, Goodlettsville
--6	1003	88 Hilltop Ln, Goodlettsville
--7	1003	88 Hilltop Ln, Goodlettsville
--________________________________________
--?? Step 2 — PARTITION BY ParcelID, PropertyAddress
--SQL divides the data into groups (partitions) based on ParcelID and PropertyAddress.
--Each unique combination forms its own group:
--Group	ParcelID	PropertyAddress	Rows
--??	1001	123 Main St, Nashville	Rows 1 & 2
--??	1002	45 River Rd, Madison	Rows 3 & 4
--??	1003	88 Hilltop Ln, Goodlettsville	Rows 5, 6 & 7
--________________________________________
--?? Step 3 — ORDER BY (SELECT NULL)
--Normally, we order by a specific column (like date or ID).
--But here, (SELECT NULL) means:
--“Don’t care about any particular order — just number them arbitrarily within each group.”
--So, SQL assigns ROW_NUMBER() values starting from 1 for each group:
--UniqueID	ParcelID	PropertyAddress	row_num
--1	1001	123 Main St, Nashville	1
--2	1001	123 Main St, Nashville	2
--3	1002	45 River Rd, Madison	1
--4	1002	45 River Rd, Madison	2
--5	1003	88 Hilltop Ln, Goodlettsville	1
--6	1003	88 Hilltop Ln, Goodlettsville	2
--7	1003	88 Hilltop Ln, Goodlettsville	3
--________________________________________
--?? Step 4 — WITH RowNumCTE AS (...)
--This part creates a temporary virtual table (a CTE = Common Table Expression).
--It’s like saying:
--“Save this intermediate result with row numbers, and will query it next.”
--So now RowNumCTE looks exactly like the above table.
--________________________________________
--?? Step 5 — WHERE row_num > 1
--Now, you select only the rows that have a row_num greater than 1 —
--which means duplicates in each (ParcelID, PropertyAddress) group.
--UniqueID	ParcelID	PropertyAddress	row_num
--2	1001	123 Main St, Nashville	2
--4	1002	45 River Rd, Madison	2
--6	1003	88 Hilltop Ln, Goodlettsville	2
--7	1003	88 Hilltop Ln, Goodlettsville	3
--________________________________________
--? Result Meaning:
--These are duplicate rows — same ParcelID and same PropertyAddress, not the first one

--------------------------------------------------------------------------------------------------------------------

--if you don’t want every column.

WITH RowNumCTE AS (
  SELECT [UniqueID ] AS UniqueID, ParcelID, PropertyAddress,
                  ? notice space here 
         ROW_NUMBER() OVER (
             PARTITION BY ParcelID, PropertyAddress
             ORDER BY (SELECT NULL)
         ) AS row_num
  FROM NashvilleHousing
)
SELECT UniqueID, ParcelID, PropertyAddress
FROM RowNumCTE
WHERE row_num > 1;

--The column name you selected is actually [UniqueID ] (notice the space at the end).
--THAT’S WHY [UniqueID ] AS UniqueID,   -- ?? renamed it (remove space)

--1?? Inside the CTE (inner SELECT):
--SELECT 
--    UniqueID, 
--    ParcelID, 
--    PropertyAddress,
--    ROW_NUMBER() OVER (...)
--This defines what columns you want to process and assign row numbers to.
-- You don’t need SELECT * unless you want every column.


--2?? Outside the CTE (outer SELECT):
--SELECT 
--    UniqueID, 
--    ParcelID, 
--    PropertyAddress
--FROM RowNumCTE
--WHERE row_num > 1;
--•	This controls what you see in the final output — here, just the three columns you care about.
--•	The WHERE row_num > 1 ensures only duplicates appear.

--final step to delete the duplicate copies:
WITH RowNumCTE AS (
  SELECT 
    [UniqueID ] AS UniqueID, 
    ParcelID, 
    PropertyAddress,
    ROW_NUMBER() OVER (
        PARTITION BY ParcelID, PropertyAddress
        ORDER BY (SELECT NULL) / UniqueID 
    ) AS row_num
  FROM SQLDataCleaning.dbo.NashvilleHousing
)
DELETE 
FROM RowNumCTE
WHERE row_num > 1;

----------------------------------------------------------------------- 
--Breaking out Address into Individual Columns (Address, City, Age)
Select PropertyAddress
from SQLDataCleaning.dbo.NashvilleHousing
-- Execute

Select
SUBSTRING(PropertyAddress, 1 , CHARINDEX(',' , PropertyAddress)) as Address
from SQLDataCleaning.dbo.NashvilleHousing

--Note: 
--SUBSTRING(text, start_position, length)
--CHARINDEX(search_for, search_in)

--SUBSTRING()   Extract part of a string
--Start = 1     Start at first character
--Length = CHARINDEX(',' , PropertyAddress)

--Character positions:
--mathematics
--1 2 3 4 5 6 7 8 9 10 11 ...
--1 8 0 8 _ F O X _ C H A ...

--?? CHARINDEX(',', text) ? 18
--?? SUBSTRING(text, 1, 18) ? "1808 FOX CHASE DR,"

--if we use SUBSTRING(PropertyAddress, 1, 18)
--result we get: 1808 FOX CHASE DR,

--if we use SUBSTRING(PropertyAddress, 2, 18)
--result we get: 808 FOX CHASE DR,

--if we use SUBSTRING(PropertyAddress, 3, 18)
--result we get: 08 FOX CHASE DR,


Select
SUBSTRING(PropertyAddress, 1 , CHARINDEX(',' , PropertyAddress)) as Address,
CHARINDEX(',', PropertyAddress)
from SQLDataCleaning.dbo.NashvilleHousing

Select
SUBSTRING(PropertyAddress, 1 , CHARINDEX(',' , PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',' , PropertyAddress) + 1, LEN(PropertyAddress)) as Address
from SQLDataCleaning.dbo.NashvilleHousing

--in this position value/ starting value = CHARINDEX(',' , PropertyAddress) + 1
--length = LEN(PropertyAddress)

ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1 , CHARINDEX(',' , PropertyAddress) -1)

Select *
from SQLDataCleaning.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',' , PropertyAddress) + 1, LEN(PropertyAddress))

Select *
from SQLDataCleaning.dbo.NashvilleHousing

Select
PARSENAME(OwnerAddress,1)
from SQLDataCleaning.dbo.NashvilleHousing

--Notes: 
--PARSENAME() splits a string using the dot (.) character — ONLY THE DOT — and extracts parts from right to left.
--It only works with dots, not commas, slashes, or spaces.
--This will only work correctly if OwnerAddress has dots (.) inside it.
--Most addresses don’t.
--Example address:
--123 Main St, Nashville, TN4
--This won’t work with PARSENAME — unless you first replace commas with dots like this:
--PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

--Address becomes:
--123 Main St. Nashville. TN

--Output Example:
--Street	  City	  State
--123 Main St	  Nashville	   TN

--2nd example : 
--Part #	PARSENAME(string, n)	Output
--1	PARSENAME(a.b.c.d, 1)	d
--2	PARSENAME(a.b.c.d, 2)	c
--3	PARSENAME(a.b.c.d, 3)	b
--4	PARSENAME(a.b.c.d, 4)	a

--It counts from right side.

Select
PARSENAME(Replace(OwnerAddress,',','.'),1),
PARSENAME(Replace(OwnerAddress,',','.'),2),
PARSENAME(Replace(OwnerAddress,',','.'),3)
from SQLDataCleaning.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(Replace(OwnerAddress,',','.'),3)

Select *
from SQLDataCleaning.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(Replace(OwnerAddress,',','.'),2)

Select *
from SQLDataCleaning.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(Replace(OwnerAddress,',','.'),1)

Select *
from SQLDataCleaning.dbo.NashvilleHousing

-- execute itall queries now

----------------------------------------------------------------------------
--Change Y and N to Yes and No In “Sold as Vacant” field

SELECT *
From SQLDataCleaning.dbo.NashvilleHousing

SELECT SoldAsVacant
From SQLDataCleaning.dbo.NashvilleHousing

Select Distinct(SoldAsVacant)
From SQLDataCleaning.dbo.NashvilleHousing

Select Distinct(SoldAsVacant), Count(SoldAsVacant) 
From SQLDataCleaning.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant,                           
CASE When SoldAsVacant = 'Y' THEN 'Yes'
     When SoldAsVacant = 'N' THEN 'No'
     ELSE SoldAsVacant
     End
From SQLDataCleaning.dbo.NashvilleHousing

-------------------------------------------------------------------------------------

--Delete Unused Columns

SELECT *
From SQLDataCleaning.dbo.NashvilleHousing

Alter Table SQLDataCleaning.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

-------------------------------------------------------------------------------------