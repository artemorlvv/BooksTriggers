CREATE TABLE Publishing (
	id INT IDENTITY PRIMARY KEY,
	name NVARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE Author (
	id INT IDENTITY PRIMARY KEY,
	name NVARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE Book (
	id INT IDENTITY PRIMARY KEY,
	publishing_id INT REFERENCES Publishing(id) NOT NULL,
	author_id INT REFERENCES Author(id) NOT NULL,
	year INT CHECK (year >= 1000 AND year <= 9999) NOT NULL,
	name NVARCHAR(255) NOT NULL UNIQUE,
	is_deleted BIT DEFAULT 0
);

CREATE TABLE ReadingRoom (
	id INT IDENTITY PRIMARY KEY,
	name NVARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE ReadingRoomBook (
	id INT IDENTITY PRIMARY KEY,
	room_id INT REFERENCES ReadingRoom(id) NOT NULL,
	book_id INT REFERENCES Book(id) NOT NULL,
	count INT CHECK (count >= 0) DEFAULT 0 
);

CREATE TABLE Student (
	id INT IDENTITY PRIMARY KEY,
	full_name NVARCHAR(100) NOT NULL,
	is_debtor BIT DEFAULT 0
);

CREATE TABLE LibraryCard (
	id INT IDENTITY PRIMARY KEY,
	student_id INT REFERENCES Student(id) NOT NULL
);

CREATE TABLE LibraryCardBook (
	id INT IDENTITY PRIMARY KEY,
	reading_room_book_id INT REFERENCES ReadingRoomBook(id) NOT NULL,
	card_id INT REFERENCES LibraryCard(id) NOT NULL,
	issued_date DATE NOT NULL,
	returned_date DATE
);

--DROP TABLE LibraryCardBook;
--DROP TABLE LibraryCard;
--DROP TABLE Student;
--DROP TABLE ReadingRoomBook;
--DROP TABLE ReadingRoom;
--DROP TABLE Book;
--DROP TABLE Author;
--DROP TABLE Publishing;