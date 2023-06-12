/*

Cleaning Data in SQL Querries

*/

SELECT *
FROM
PortfolioProject..NashvilleHousingDataforDataCleaning

-------------------------------------------------------------------------------------------------------------------------

-- Standardize date format

SELECT SaleDateConverted, CONVERT(date,SaleDate)
FROM
PortfolioProject..NashvilleHousingDataforDataCleaning

UPDATE PortfolioProject..NashvilleHousingDataforDataCleaning
SET SaleDate = CONVERT(date, SaleDate)

ALTER TABLE PortfolioProject..NashvilleHousingDataforDataCleaning
ADD SaleDateConverted DATE;

-------------------------------------------------------------------------------------------------------------------------

-- Populate property address 

SELECT *
from 
PortfolioProject..NashvilleHousingDataforDataCleaning
WHERE PropertyAddress is NULL
--ORDER by ParcelID

-- join table to itself (to populate the null with the address that is already populated)

SELECT a.PropertyAddress, a. ParcelID, b.PropertyAddress, b.ParcelID, ISNULL(a.PropertyAddress, b.PropertyAddress) -- if property address in a is null then populate with property address of b
from 
PortfolioProject..NashvilleHousingDataforDataCleaning a
join
PortfolioProject..NashvilleHousingDataforDataCleaning b
on a.ParcelID = b.ParcelID AND -- join on the same parcel ID and different Unique ID
a.UniqueID <> b.UniqueID
where a.PropertyAddress is NULL

-- update the table to fill the values of Null values in a.PropertyAddress

UPDATE a
set a.PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress) 
from 
PortfolioProject..NashvilleHousingDataforDataCleaning a
join
PortfolioProject..NashvilleHousingDataforDataCleaning b
on a.ParcelID = b.ParcelID AND -- join on the same parcel ID with different Unique ID
a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is NULL

-------------------------------------------------------------------------------------------------------------------------

-- Breaking out address into individual columns (Address,City, state)

-- breaking out Address and City of PropertyAddress (using Substring)

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address -- looking at position 1 of PropertyAddress up to comma and the -1 is to remove the ',' in the end.
, SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as City -- counting from the ',' to the length of property address (+1 to remove comma at the start of the sentences)
FROM
PortfolioProject.dbo.NashvilleHousingDataforDataCleaning

-- Alter Address into the current table

ALTER TABLE PortfolioProject..NashvilleHousingDataforDataCleaning
ADD Address Nvarchar(255);

UPDATE PortfolioProject..NashvilleHousingDataforDataCleaning
SET Address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

-- Alter City into the current table

ALTER TABLE PortfolioProject..NashvilleHousingDataforDataCleaning
ADD City Nvarchar(255);

UPDATE PortfolioProject..NashvilleHousingDataforDataCleaning
SET City = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))

SELECT * 
FROM
PortfolioProject.dbo.NashvilleHousingDataforDataCleaning

-- breaking out Address, City, and State of OwnerAddress (using ParseName)

SELECT OwnerAddress
FROM
PortfolioProject..NashvilleHousingDataforDataCleaning

SELECT
PARSENAME(replace(OwnerAddress,',','.'), 3) as Address
,PARSENAME(replace(OwnerAddress,',','.'), 2) as City
,PARSENAME(replace(OwnerAddress,',','.'), 1) as State
FROM
PortfolioProject..NashvilleHousingDataforDataCleaning

-- Alter these three new table into the current table

--Alter Address
ALTER TABLE PortfolioProject..NashvilleHousingDataforDataCleaning
ADD OwnerAddressSplit NVARCHAR(255)

UPDATE PortfolioProject..NashvilleHousingDataforDataCleaning
SET OwnerAddressSplit = PARSENAME(replace(OwnerAddress,',','.'), 3)

--Alter City
ALTER TABLE PortfolioProject..NashvilleHousingDataforDataCleaning
ADD OwnerCitySplit NVARCHAR(255)

UPDATE PortfolioProject..NashvilleHousingDataforDataCleaning
SET OwnerCitySplit = PARSENAME(replace(OwnerAddress,',','.'), 2)

--Alter State
ALTER TABLE PortfolioProject..NashvilleHousingDataforDataCleaning
ADD OwnerStateSplit NVARCHAR(255)

UPDATE PortfolioProject..NashvilleHousingDataforDataCleaning
SET OwnerStateSplit = PARSENAME(replace(OwnerAddress,',','.'), 1)


-------------------------------------------------------------------------------------------------------------------------

-- in "SoldAsVacant" columns, change Y and N to Yes and No --

select SoldAsVacant, COUNT(SoldAsVacant)
from 
PortfolioProject..NashvilleHousingDataforDataCleaning
GROUP BY SoldAsVacant
ORDER by 2

SELECT SoldAsVacant,
CASE
when SoldAsVacant = 'Y' then 'Yes'
WHEN SoldAsVacant = 'N' then 'No'
ELSE SoldAsVacant
END
FROM
PortfolioProject..NashvilleHousingDataforDataCleaning 

-- Update SOldAsVacant Columns
UPDATE PortfolioProject..NashvilleHousingDataforDataCleaning
SET SoldAsVacant = 
CASE
when SoldAsVacant = 'Y' then 'Yes'
WHEN SoldAsVacant = 'N' then 'No'
ELSE SoldAsVacant
END

-------------------------------------------------------------------------------------------------------------------------
-- Remove Duplicates

WITH CTE_Rownumber
AS
(
    SELECT *,
ROW_NUMBER() OVER(
    PARTITION BY               --partition things that should be unique on each row
    ParcelID,
    PropertyAddress,
    SaleDate,
    SalePrice,
    LegalReference
    ORDER by 
        UniqueID
) row_number

FROM
PortfolioProject..NashvilleHousingDataforDataCleaning
--ORDER BY ParcelID
)
SELECT *
FROM CTE_Rownumber
WHERE row_number > 1
ORDER by ParcelID

-- for testing purposes (delete the duplicates)

WITH CTE_Rownumber
AS
(
    SELECT *,
ROW_NUMBER() OVER(
    PARTITION BY               --partition things that should be unique on each row
    ParcelID,
    PropertyAddress,
    SaleDate,
    SalePrice,
    LegalReference
    ORDER by 
        UniqueID
) row_number

FROM
PortfolioProject..NashvilleHousingDataforDataCleaning
--ORDER BY ParcelID
)
DELETE
FROM CTE_Rownumber
WHERE row_number > 1

-------------------------------------------------------------------------------------------------------------------------
-- Delete Unused Columns


SELECT *
FROM
PortfolioProject..NashvilleHousingDataforDataCleaning

-- delete TaxDistrict columns

ALTER TABLE PortfolioProject..NashvilleHousingDataforDataCleaning
DROP COLUMN PropertyAddress, OwnerAddress

ALTER TABLE PortfolioProject..NashvilleHousingDataforDataCleaning
DROP COLUMN SaleDate
