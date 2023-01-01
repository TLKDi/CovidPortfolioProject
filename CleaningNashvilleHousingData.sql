-- CLEANING DATA --

SELECT * FROM [PortfolioProject]..NashvilleHousing


-- Standardize Date Format

SELECT SaleDate, CONVERT(Date, SaleDate) 
FROM [PortfolioProject]..NashvilleHousing

--Does not work
UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

--But this way it works
ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

-------------------------------------
--Populate Property Address Data

SELECT PropertyAddress FROM [PortfolioProject]..NashvilleHousing
WHERE PropertyAddress IS NOT NULL

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, a.[UniqueID ], b.[UniqueID ]
FROM [PortfolioProject]..NashvilleHousing a
JOIN [PortfolioProject]..NashvilleHousing b
	ON a.ParcelID = b.ParcelID 
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [PortfolioProject]..NashvilleHousing a
JOIN [PortfolioProject]..NashvilleHousing b
	ON a.ParcelID = b.ParcelID 
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

-------------------------------------

-- Breaking out Address into Individual Columns (Adress, City, State)

SELECT PropertyAddress FROM [PortfolioProject]..NashvilleHousing
--WHERE PropertyAddress IS NOT NULL

SELECT 
SUBSTRING(PropertyAddress,1, CHARINDEX(',', PropertyAddress)-1) as Adress,
SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as City
FROM [PortfolioProject]..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAdress Nvarchar(255)

UPDATE NashvilleHousing
SET PropertySplitAdress = SUBSTRING(PropertyAddress,1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar(255)

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

--SELECT * FROM [PortfolioProject]..NashvilleHousing

-------------------------------------

-- Breaking out Adress into Individual Columns (Adress, City, State) Part2

SELECT OwnerAddress FROM [PortfolioProject]..NashvilleHousing

SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'), 3),
PARSENAME(REPLACE(OwnerAddress,',','.'), 2),
PARSENAME(REPLACE(OwnerAddress,',','.'), 1)
FROM [PortfolioProject]..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'), 3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity Nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'), 2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState Nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'), 1)

--SELECT * FROM [PortfolioProject]..NashvilleHousing

-------------------------------------

--Change Y and N to Yes and No in "Sold As Vacant" field

SELECT DISTINCT (SoldAsVacant), COUNT(SoldAsVacant)
FROM [PortfolioProject]..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant, 
	CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
	WHEN SoldAsVacant = 'N' THEN 'NO'
	ELSE SoldAsVacant 
	END
FROM [PortfolioProject]..NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
	WHEN SoldAsVacant = 'N' THEN 'NO'
	ELSE SoldAsVacant 
	END

-------------------------------------

--Remove Duplicates

--SELECT-STATEMENT
WITH RowNumCTE AS
(
SELECT * , 
ROW_NUMBER() OVER(
	PARTITION BY 
		ParcelID, PropertyAddress, SalePrice, SaleDate,legalReference
	ORDER BY 
		UniqueID) row_num
FROM [PortfolioProject]..NashvilleHousing
)
SELECT * FROM RowNumCTE 
WHERE row_num > 1
ORDER BY PropertyAddress

--DELETE-STATEMENT
WITH RowNumCTE AS
(
SELECT * , 
ROW_NUMBER() OVER(
	PARTITION BY 
		ParcelID, PropertyAddress, SalePrice, SaleDate,legalReference
	ORDER BY 
		UniqueID) row_num
FROM [PortfolioProject]..NashvilleHousing
)
DELETE RowNumCTE 
WHERE row_num > 1

-------------------------------------

--DELETE UNUSED COLUMNS

SELECT * FROM [PortfolioProject]..NashvilleHousing

ALTER TABLE [PortfolioProject]..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE [PortfolioProject]..NashvilleHousing
DROP COLUMN SaleDate