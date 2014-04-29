CREATE TABLE bands(
	id INT,
	name VARCHAR(255),
	thumb VARCHAR(255),
	picture VARCHAR(255)
);

CREATE TABLE genres(
	id INT,
	genre VARCHAR(255)
);

CREATE TABLE dates(
	id INT,
	date DATE,
	city VARCHAR(255)
);

CREATE TABLE links(
	id INT,
	type VARCHAR(255),
	link VARCHAR(255)
);