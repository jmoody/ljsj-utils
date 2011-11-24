CREATE TABLE `booking`.`address` (
  `address_id` VARCHAR(38) NOT NULL,
  `address1` VARCHAR(38) NOT NULL,
  `address2` VARCHAR(38) DEFAULT NULL,
  `city` VARCHAR(38) NOT NULL,
  `state` VARCHAR(2) NOT NULL,
  `zip` VARCHAR(5) NOT NULL,
  PRIMARY KEY (`address_id`)
)
CHARACTER SET utf8;
