select * 
from PortfolioProfil.dbo.NashvilleHousing
-----------------------------------------------

--Standardize Date Format

select SaleDateConverted, convert(Date,SaleDate)
from PortfolioProfil.dbo.NashvilleHousing

Update NashvilleHousing 
set SaleDate = convert(Date,SaleDate)

Alter Table NashvilleHousing
add SaleDateConverted Date;

Update NashvilleHousing 
set SaleDateConverted = convert(Date,SaleDate)

------------------------------------------------------
--populate Property Adress data

select *
from PortfolioProfil.dbo.NashvilleHousing
--where PropertyAddress is NULL
order by ParcelID

select n.ParcelID, n.PropertyAddress, n1.ParcelID, n1.PropertyAddress, 
ISNULL(n.PropertyAddress,n1.PropertyAddress)
from PortfolioProfil.dbo.NashvilleHousing n
join PortfolioProfil.dbo.NashvilleHousing n1
on n.ParcelID = n1.ParcelID
and n.[UniqueID ] <> n1.[UniqueID ]
where n.PropertyAddress is NULL


Update n
set PropertyAddress = ISNULL(n.PropertyAddress,n1.PropertyAddress)
from PortfolioProfil.dbo.NashvilleHousing n
join PortfolioProfil.dbo.NashvilleHousing n1
on n.ParcelID = n1.ParcelID
and n.[UniqueID ] <> n1.[UniqueID ]
--------------------------------------------------------
--Breaking out Address into individual Columns (Adress, City, State)

select PropertyAddress
from PortfolioProfil.dbo.NashvilleHousing


select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',' , PropertyAddress)-1) as address,
SUBSTRING(PropertyAddress,  CHARINDEX(',' , PropertyAddress)+1, len(PropertyAddress)) as address
from PortfolioProfil.dbo.NashvilleHousing

Alter Table NashvilleHousing
add PropertySliptAdress nvarchar(255);

Update NashvilleHousing 
set PropertySliptAdress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',' , PropertyAddress)-1)



Alter Table NashvilleHousing
add PropertySliptCity  nvarchar(255);

Update NashvilleHousing 
set PropertySliptCity = SUBSTRING(PropertyAddress,  CHARINDEX(',' , PropertyAddress)+1, len(PropertyAddress))



select *
from PortfolioProfil.dbo.NashvilleHousing






select OwnerAddress
from PortfolioProfil.dbo.NashvilleHousing

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From PortfolioProfil.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

Select *
From  PortfolioProfil.dbo.NashvilleHousing
-----------------------------------------------------------------------------------
-- Change Y and N to Yes and No in "Sold as Vacant" field


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProfil.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2


Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
	   From PortfolioProfil.dbo.NashvilleHousing


Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
--------------------------------------------------------------------------
-- Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

  From PortfolioProfil.dbo.NashvilleHousing
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress



Select *
 From PortfolioProfil.dbo.NashvilleHousing




---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns



Select *
 From PortfolioProfil.dbo.NashvilleHousing


ALTER TABLE PortfolioProfil.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

