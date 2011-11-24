CREATE TABLE `booking`.`performer` (
  `performer_id` VARCHAR(38) NOT NULL,
  `name` VARCHAR(50) NOT NULL,
  `genre` VARCHAR(50) NOT NULL,
  PRIMARY KEY (`performer_id`),
  CONSTRAINT `fk__genre__genre_Id` FOREIGN KEY `fk__genre__genre_Id` (`genre`)
    REFERENCES `genre` (`genre_id`)
)
ENGINE = InnoDB
CHARACTER SET utf8;
