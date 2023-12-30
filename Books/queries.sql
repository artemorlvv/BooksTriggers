INSERT INTO LibraryCardBook (reading_room_book_id, card_id, issued_date)
VALUES (
	(
		SELECT id 
		FROM ReadingRoomBook 
		WHERE 
			room_id = (SELECT id FROM ReadingRoom WHERE name = N'1') AND
			book_id = (SELECT id FROM Book WHERE name = N'Гарри Поттер')
	),
	(
		SELECT id
		FROM LibraryCard
		WHERE student_id = (SELECT id FROM Student WHERE full_name = N'Петров П.П.')
	),
	CONVERT(DATE, GETDATE())
);

UPDATE TOP (1) LibraryCardBook
SET	returned_date = CONVERT(DATE, GETDATE())
WHERE 
	card_id = (
		SELECT id 
		FROM LibraryCard 
		WHERE student_id = (SELECT id FROM Student WHERE full_name = N'Петров П.П.')
	)
	AND reading_room_book_id = (
		SELECT id 
		FROM ReadingRoomBook 
		WHERE 
			room_id = (SELECT id FROM ReadingRoom WHERE name = N'1') AND
			book_id = (SELECT id FROM Book WHERE name = N'Гарри Поттер')
	)
	AND returned_date IS NULL;

DELETE FROM Book WHERE id IN (2, 3, 4);

INSERT INTO Book (publishing_id, author_id, year, name)
VALUES (
    (SELECT id FROM Publishing WHERE name = N'Росмэн'),
    (SELECT id FROM Author WHERE name = N'Джоан Роулинг'),
    2023,
    N'Гарри Поттер'
);

INSERT INTO Book (publishing_id, author_id, year, name)
VALUES 
(
    (SELECT id FROM Publishing WHERE name = N'Росмэн'),
    (SELECT id FROM Author WHERE name = N'Джоан Роулинг'),
    2009,
    N'Гарри Поттер 2'
),
(
	(SELECT id FROM Publishing WHERE name = N'Росмэн'),
    (SELECT id FROM Author WHERE name = N'Джоан Роулинг'),
    2011,
    N'Гарри Поттер 3'
);