--Pulling up All the data from Nashvillehousing

SELECT *
FROM PortfolioProject.dbo.Nashvillehousing

-- Standardize the date format

SELECT Saledateconverted, CONVERT(Date,Saledate)
FROM PortfolioProject.dbo.Nashvillehousing

ALTER TABLE Nashvillehousing
ADD Saledateconverted DATE;

UPDATE Nashvillehousing
SET Saledateconverted = CONVERT(Date,Saledate)


-- Populate Property Address data

SELECT *
FROM PortfolioProject.dbo.Nashvillehousing
--WHERE Propertyaddress is null
ORDER BY ParcelID

SELECT ACD.ParcelID, ACD.PropertyAddress, EFG.ParcelID, EFG.PropertyAddress, ISNULL(ACD.PropertyAddress,EFG.PropertyAddress)
FROM PortfolioProject.dbo.Nashvillehousing ACD
JOIN PortfolioProject.dbo.Nashvillehousing EFG
 ON ACD.ParcelID=EFG.PARCELID
 AND ACD.[UniqueID ] <> EFG.[UniqueID ]
WHERE ACD.PropertyAddress IS NULL


UPDATE ACD
SET PropertyAddress = ISNULL(ACD.PropertyAddress,EFG.PropertyAddress)
FROM PortfolioProject.dbo.Nashvillehousing ACD
JOIN PortfolioProject.dbo.Nashvillehousing EFG
 ON ACD.ParcelID=EFG.PARCELID
 AND ACD.[UniqueID ] <> EFG.[UniqueID ]
WHERE ACD.PropertyAddress IS NULL


--Breaking out address into Individual column (Address, city, State)

SELECT PropertyAddress
FROM PortfolioProject.dbo.Nashvillehousing

SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1 , LEN(PropertyAddress))

FROM PortfolioProject.dbo.Nashvillehousing

ALTER TABLE Nashvillehousing
ADD PropertySplitAdddress nvarchar(255);

UPDATE Nashvillehousing
SET PropertySplitAdddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE Nashvillehousing
ADD PropertySplitCity nvarchar(255);

UPDATE Nashvillehousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1 , LEN(PropertyAddress))

SELECT*
FROM PortfolioProject.dbo.Nashvillehousing

--Spltting the owner address 

Select
PARSENAME(REPLACE(owneraddress,',','.'),3)
,PARSENAME(REPLACE(owneraddress,',','.'),2)
,PARSENAME(REPLACE(owneraddress,',','.'),1)
FROM PortfolioProject.dbo.Nashvillehousing

ALTER TABLE Nashvillehousing
ADD ownersplitaddress Nvarchar(255);

UPDATE Nashvillehousing
SET ownersplitaddress = PARSENAME(REPLACE(owneraddress,',','.'),3)

ALTER TABLE Nashvillehousing
ADD ownersplitcity Nvarchar(255);

UPDATE Nashvillehousing
SET ownersplitcity = PARSENAME(REPLACE(owneraddress,',','.'),2)

ALTER TABLE Nashvillehousing
ADD ownersplitstate nvarchar(255);

UPDATE Nashvillehousing
SET ownersplitstate = PARSENAME(REPLACE(owneraddress,',','.'),1)

SELECT *
FROM PortfolioProject.dbo.Nashvillehousing

--Change Y and N to Yes and NO in "SoldAsVacant" field

SELECT DISTINCT(SoldAsVacant)	
 ,COUNT(SoldAsVacant)
FROM PortfolioProject.dbo.Nashvillehousing
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant
,CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	  WHEN SoldAsVacant = 'N' THEN 'No'
	  ELSE SoldAsVacant
	  END
FROM PortfolioProject.dbo.Nashvillehousing

UPDATE Nashvillehousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	  WHEN SoldAsVacant = 'N' THEN 'No'
	  ELSE SoldAsVacant
	  END


-- Remove Duplicates

WITH RownumCTE AS(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 Saleprice,
				 SaleDate,
				 LegalReference
				 ORDER BY
				   UniqueID)
				   Row_num
FROM PortfolioProject.dbo.Nashvillehousing
)
SELECT *
FROM RownumCTE
WHERE Row_num>1
ORDER BY PropertyAddress

-- Delete Unused Columns

SELECT*
FROM PortfolioProject.dbo.Nashvillehousing

ALTER TABLE PortfolioProject.dbo.Nashvillehousing
DROP COLUMN PropertyAddress, SaleDate, OwnerAddress, TaxDistrict
