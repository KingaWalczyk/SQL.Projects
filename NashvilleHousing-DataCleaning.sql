/*
Cleaning Data on Housing in Nashville with SQl Queries.
Utilizing Converting Data Types, Join, Windows Function, CTE's.
*/


SELECT *
FROM PortfolioProject..NashvilleHousing$ 


-- Standardizing Date Format


SELECT SaleDate, CONVERT(Date,SaleDate) 
FROM PortfolioProject..NashvilleHousing$ 

ALTER TABLE NashvilleHousing$
ADD SaleDateConverted Date;

UPDATE NashvilleHousing$
SET SaleDateConverted = CONVERT(Date,SaleDate)


-- Populating Property Address Data


SELECT *
FROM PortfolioProject.dbo.NashvilleHousing$
--WHERE PropertyAddress is null
ORDER BY ParcelID


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing$ a
JOIN PortfolioProject.dbo.NashvilleHousing$ b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS null


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing$ a
JOIN PortfolioProject..NashvilleHousing$ b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS null


-- Splitting PropertyAddress Column into Individual Columns (Address, City)


SELECT PropertyAddress
FROM PortfolioProject..NashvilleHousing$
--WHERE PropertyAddress is null
--ORDER BY ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) AS Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) AS Address

FROM PortfolioProject.dbo.NashvilleHousing$


ALTER TABLE NashvilleHousing$
ADD PropertySplitAddress Nvarchar(255);

UPDATE NashvilleHousing$
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE NashvilleHousing$
ADD PropertySplitCity Nvarchar(255);

UPDATE NashvilleHousing$
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))


-- Splitting OwnerAddress Column into Individual Columns (Address, City, State)


SELECT OwnerAddress
FROM PortfolioProject..NashvilleHousing$


SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
FROM PortfolioProject..NashvilleHousing$



ALTER TABLE NashvilleHousing$
ADD OwnerSplitAddress Nvarchar(255);

UPDATE NashvilleHousing$
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE NashvilleHousing$
ADD OwnerSplitCity Nvarchar(255);

UPDATE NashvilleHousing$
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)


ALTER TABLE NashvilleHousing$
ADD OwnerSplitState Nvarchar(255);

UPDATE NashvilleHousing$
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)


-- Changing Y and N to Yes and No in "Sold as Vacant" field


SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM PortfolioProject..NashvilleHousing$


UPDATE NashvilleHousing$
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END


-- Showing Duplicates


WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

FROM PortfolioProject..NashvilleHousing$
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress

-- Deleting Duplicates

--SELECT *
--FROM RowNumCTE
--WHERE row_num > 1
--ORDER BY PropertyAddress