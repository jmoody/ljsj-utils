CREATE TABLE `booking`.`genre` (
  `genre_id` VARCHAR(38) NOT NULL,
  `genre_name` VARCHAR(50) NOT NULL DEFAULT 'band',
  PRIMARY KEY (`genre_id`)
)
CHARACTER SET utf8;
