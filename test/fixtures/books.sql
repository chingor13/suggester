DROP TABLE IF EXISTS `books`;

CREATE TABLE `books` (
  `id` INT UNSIGNED AUTO_INCREMENT NOT NULL,
  `title` VARCHAR(64),
  `author` VARCHAR(125),
  PRIMARY KEY (`id`)
);

INSERT INTO `books` SET `id` = 1, `title` = 'A Tale of Two Cities', `author` = 'Charles Dickens';
INSERT INTO `books` SET `id` = 2, `title` = 'Anna Karenina', `author` = 'Leo Tolstoy';
INSERT INTO `books` SET `id` = 3, `title` = 'Great Expectations', `author` = 'Charles Dickens';
INSERT INTO `books` SET `id` = 4, `title` = 'The Origin of Species', `author` = 'Charles Darwin';
INSERT INTO `books` SET `id` = 5, `title` = 'The Catcher in the Rye', `author` = 'J.D. Salinger';
INSERT INTO `books` SET `id` = 6, `title` = 'The Lord of the Rings', `author` = 'J.R.R. Tolkien';
