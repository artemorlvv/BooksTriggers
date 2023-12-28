--INSERT INTO Publishing (name)
--VALUES (N'ЭКСМО'), (N'АСТ'), (N'Росмэн');

--select * from Publishing;


--INSERT INTO Author (name)
--VALUES (N'Джоан Роулинг'), (N'Ф. М. Достоевский'), (N'Альбер Камю');

--select * from Author;

--INSERT INTO Book (publishing_id, author_id, year, name)
--VALUES (
--    (SELECT id FROM Publishing WHERE name = N'АСТ'),
--    (SELECT id FROM Author WHERE name = N'Ф. М. Достоевский'),
--    2023,
--    N'Гарри Поттер'
--);

--INSERT INTO Book (publishing_id, author_id, year, name)
--VALUES (
--    (SELECT id FROM Publishing WHERE name = N'ЭКСМО'),
--    (SELECT id FROM Author WHERE name = N'Альбер Камю'),
--    2023,
--    N'Посторонний'
--);

--INSERT INTO Book (publishing_id, author_id, year, name)
--VALUES (
--    (SELECT id FROM Publishing WHERE name = N'Росмэн'),
--    (SELECT id FROM Author WHERE name = N'Джоан Роулинг'),
--    2023,
--    N'Гарри Поттер'
--);

--select * from Book;

--INSERT INTO ReadingRoom (name)
--VALUES (N'1'), (N'2'), (N'2а');

--select * from ReadingRoom;

--INSERT INTO ReadingRoomBook (room_id, book_id, count)
--VALUES (
--    (SELECT id FROM ReadingRoom WHERE name = N'1'),
--    (SELECT id FROM Book WHERE name = N'Гарри Поттер'),
--    2
--);

--INSERT INTO ReadingRoomBook (room_id, book_id, count)
--VALUES (
--    (SELECT id FROM ReadingRoom WHERE name = N'1'),
--    (SELECT id FROM Book WHERE name = N'Посторонний'),
--    3
--);

--INSERT INTO ReadingRoomBook (room_id, book_id, count)
--VALUES (
--    (SELECT id FROM ReadingRoom WHERE name = N'2'),
--    (SELECT id FROM Book WHERE name = N'Посторонний'),
--    3
--);

--INSERT INTO ReadingRoomBook (room_id, book_id, count)
--VALUES (
--    (SELECT id FROM ReadingRoom WHERE name = N'2'),
--    (SELECT id FROM Book WHERE name = N'Гарри Поттер'),
--    1
--);

--INSERT INTO ReadingRoomBook (room_id, book_id, count)
--VALUES (
--    (SELECT id FROM ReadingRoom WHERE name = N'2'),
--    (SELECT id FROM Book WHERE name = N'Братья Карамазовы'),
--    4
--);

--INSERT INTO ReadingRoomBook (room_id, book_id, count)
--VALUES (
--    (SELECT id FROM ReadingRoom WHERE name = N'2а'),
--    (SELECT id FROM Book WHERE name = N'Гарри Поттер'),
--    3
--);

--INSERT INTO ReadingRoomBook (room_id, book_id, count)
--VALUES (
--    (SELECT id FROM ReadingRoom WHERE name = N'2а'),
--    (SELECT id FROM Book WHERE name = N'Братья Карамазовы'),
--    2
--);

--select * from ReadingRoomBook;


--INSERT INTO Student (full_name)
--VALUES (N'Петров П.П.'), (N'Николаев Н.Н.'), (N'Данилов Д.Д.');

--SELECT * FROM Student;

--INSERT INTO LibraryCard (student_id)
--VALUES 
--((SELECT id FROM Student WHERE full_name = N'Петров П.П.')), 
--((SELECT id FROM Student WHERE full_name = N'Николаев Н.Н.')), 
--((SELECT id FROM Student WHERE full_name = N'Данилов Д.Д.'));

--SELECT * FROM LibraryCard;



SELECT * FROM Author;
SELECT * FROM Book;
SELECT * FROM ReadingRoom;
SELECT * FROM ReadingRoomBook;
SELECT * FROM Student;
SELECT * FROM LibraryCard;
