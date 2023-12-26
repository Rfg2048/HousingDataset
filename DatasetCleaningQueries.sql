/*

Data cleaning queries

*/

Select *
From NashvilleHousing


--Standardization of date column


Select SaleDate2, CONVERT(Date, SaleDate)
From NashvilleHousing

UPDATE NashvilleHousing
Set SaleDate = CONVERT(Date, SaleDate)

Alter table NashvilleHousing
Add SaleDate2 Date;

UPDATE NashvilleHousing
Set SaleDate2 = CONVERT(Date, SaleDate)


-- Populating empty adrresses


Select *
From NashvilleHousing
Order by ParcelID

Select Nash1.ParcelID, Nash1.PropertyAddress, Nash2.ParcelID, Nash2.PropertyAddress, ISNULL(Nash1.PropertyAddress,Nash2.PropertyAddress)
From NashvilleHousing Nash1
Join NashvilleHousing Nash2
	On Nash1.ParcelID = Nash2.ParcelID
	And Nash1.UniqueID <> Nash2.UniqueID
Where Nash1.PropertyAddress is null

Update Nash1
Set PropertyAddress = ISNULL(Nash1.PropertyAddress,Nash2.PropertyAddress)
From NashvilleHousing Nash1
Join NashvilleHousing Nash2
	On Nash1.ParcelID = Nash2.ParcelID
	And Nash1.UniqueID <> Nash2.UniqueID
Where Nash1.PropertyAddress is null


-- Separating property address line with address and city using Substring


Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address1,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address2

From NashvilleHousing

Alter table NashvilleHousing
Add PropertySplitAddress nvarchar(255),
	PropertySplitCity nvarchar(255);

Update NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1),
	PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress));


-- Separating owner address line with address, city and state using Parsename


Select
PARSENAME(Replace(OwnerAddress, ',','.'),3),
PARSENAME(Replace(OwnerAddress, ',','.'),2),
PARSENAME(Replace(OwnerAddress, ',','.'),1)
From NashvilleHousing

Alter table NashvilleHousing
Add OwnerSplitAddress nvarchar(255),
	OwnerSplitCity nvarchar(255),
	OwnerSplitState nvarchar(255);

Update NashvilleHousing
Set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress, ',','.'),3),
	OwnerSplitCity = PARSENAME(Replace(OwnerAddress, ',','.'),2),
	OwnerSplitState = PARSENAME(Replace(OwnerAddress, ',','.'),1);


-- Replacing values of Yes and No using Case


Select Distinct(Soldasvacant), count(Soldasvacant)
From NashvilleHousing
Group by Soldasvacant
Order by 2

Select Soldasvacant,
Case When Soldasvacant = 'Y' then 'Yes'
	 When Soldasvacant = 'N' then 'No'
	 Else Soldasvacant
	 End
From NashvilleHousing

Update NashvilleHousing
Set SoldAsVacant = Case When Soldasvacant = 'Y' then 'Yes'
	 When Soldasvacant = 'N' then 'No'
	 Else Soldasvacant
	 End

-- Removing duplicates with CTE

Select *
From NashvilleHousing


With RowCTE as(

Select *,
	Row_number() Over(
	Partition by ParcelID,
				 PropertyAddress,
				 SaleDate,
				 LegalReference
				 Order by
					UniqueID
					) row_num

From NashvilleHousing
--Order by ParcelID
)

Select *
From RowCTE
Where row_num > 1


-- Deleting unused Columns


Alter Table NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate