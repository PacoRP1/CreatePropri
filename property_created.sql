CREATE TABLE `property_created` (
  `propertyID` int(11) NOT NULL,
  `owner` varchar(255) DEFAULT NULL,
  `label` varchar(255) DEFAULT NULL,
  `price` varchar(255) DEFAULT NULL,
  `pNumber` varchar(255) DEFAULT NULL,
  `pEnterPos` varchar(255) DEFAULT NULL,
  `gEnterPos` varchar(255) DEFAULT NULL,
  `gPlaces` varchar(255) DEFAULT NULL,
  `stockCapacity` varchar(255) DEFAULT NULL,
  `pInventory` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT '{}',
  `pVehicules` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT '{}',
  `pKeys` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT '{}'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

ALTER TABLE `property_created`
  ADD PRIMARY KEY (`propertyID`);


ALTER TABLE `property_created`
  MODIFY `propertyID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=47;
COMMIT;

