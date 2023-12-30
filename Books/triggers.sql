CREATE TRIGGER trg_LibraryCardBook_Insert
ON LibraryCardBook
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE ReadingRoomBook
    SET count = count - 1
    FROM inserted i
    WHERE ReadingRoomBook.id = i.reading_room_book_id;
END;
GO

CREATE TRIGGER trg_LibraryCardBook_Update
ON LibraryCardBook
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Обновляем count в ReadingRoomBook только если returned_date изменен и не является NULL
    UPDATE ReadingRoomBook
    SET count = count + 1
    FROM inserted i
    JOIN deleted d ON i.id = d.id
    WHERE ReadingRoomBook.id = i.reading_room_book_id
      AND i.returned_date IS NOT NULL
      AND d.returned_date IS NULL;
END;
GO

CREATE TRIGGER trg_InsteadOfInsert
ON LibraryCardBook
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT OFF;

    DECLARE @StudentID INT, @CardID INT;

    SELECT @CardID = card_id
    FROM inserted;

    SELECT @StudentID = student_id
    FROM LibraryCard
    WHERE id = @CardID;

    BEGIN TRY
        -- Проверка, что у студента меньше 3 книг на руках
        IF EXISTS (
            SELECT 1
            FROM LibraryCardBook lcb
            WHERE 
                lcb.card_id = @CardID
                AND lcb.returned_date IS NULL
            GROUP BY lcb.card_id
            HAVING COUNT(*) >= 3
        )
        BEGIN
            ;THROW 50002, N'Студент не может взять больше 3 книг.', 1;
        END;

        -- Проверка, что студент не должник
        IF EXISTS (
            SELECT 1
            FROM Student
            WHERE id = @StudentID AND is_debtor = 1
        )
        BEGIN
            ;THROW 50003, N'Студент - должник', 1;
        END;

        -- Проверка, что студент в прошлый раз читал книгу НЕ дольше 2 месяцев
        IF EXISTS (
            SELECT 1
            FROM LibraryCardBook lcb
            INNER JOIN inserted i
            ON
                lcb.card_id = i.card_id
                AND DATEDIFF(MONTH, lcb.issued_date, COALESCE(lcb.returned_date, CAST(GETDATE() AS DATE))) >= 2
        )
        BEGIN
            UPDATE Student
            SET is_debtor = 1
            WHERE id = @StudentID;

            ;THROW 50004, N'Студент читал книгу дольше 2 месяцев', 1;
        END;

        -- Проверка, что count в ReadingRoomBook не равен 0
        IF NOT EXISTS (
            SELECT 1
            FROM inserted i
            INNER JOIN ReadingRoomBook rrb ON i.reading_room_book_id = rrb.id AND rrb.count > 0
        )
        BEGIN
            DECLARE @RandomBookId INT;

            SELECT TOP 1 @RandomBookId = id
            FROM ReadingRoomBook
            WHERE count > 0
            ORDER BY NEWID();

            INSERT INTO LibraryCardBook (reading_room_book_id, card_id, issued_date, returned_date)
            SELECT @RandomBookId, card_id, issued_date, returned_date
            FROM inserted;

            ;THROW 50001, N'Книга отсутствует, вместо этого была выдана', 1;
        END;

        -- Продолжить вставку, если проверка прошла успешно
        INSERT INTO LibraryCardBook (reading_room_book_id, card_id, issued_date, returned_date)
        SELECT reading_room_book_id, card_id, issued_date, returned_date
        FROM inserted;
    END TRY
    BEGIN CATCH
        PRINT N'Ошибка: ' + ERROR_MESSAGE();
    END CATCH;
END;
GO

--DROP TRIGGER trg_InsteadOfInsert;
--go

CREATE TRIGGER trg_InsteadOfDeleteBook
ON Book
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;

    -- Обновить count в таблице ReadingRoomBook на 0
    UPDATE ReadingRoomBook
    SET count = 0
    WHERE book_id IN (
        SELECT id 
        FROM deleted 
        WHERE publishing_id <> (
            SELECT id FROM 
            Publishing 
            WHERE name = N'АСТ'
        )
    );
    --WHERE book_id IN (
    --    SELECT id 
    --    FROM deleted
    --    WHERE id <> 3 --?????????
    --);

    -- Пометить книги как удаленные
    UPDATE Book
    SET is_deleted = 1
    WHERE id IN (
        SELECT id 
        FROM deleted 
        WHERE publishing_id <> (
            SELECT id FROM 
            Publishing 
            WHERE name = N'АСТ'
        )
    );
END;
GO

--DROP TRIGGER trg_InsteadOfDeleteBook;
GO

CREATE TRIGGER trg_InsteadOfInsertBook
ON Book
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1 
        FROM Book b
        WHERE b.name IN (SELECT name FROM inserted)
    )
    BEGIN
        UPDATE Book
        SET is_deleted = 0
        WHERE name IN (SELECT name FROM inserted)
        PRINT N'Книга уже существует. Метка об удалении была снята.';
        RETURN;
    END;

    -- Запрет вставки книг, если есть хоть одна с годом менее 2010
    --IF EXISTS (
    --    SELECT 1
    --    FROM INSERTED
    --    WHERE year < 2010
    --)
    --BEGIN
    --    PRINT N'В списке книг есть хотябы одна, с годом менее 2010. Вставка полностью отменена';
    --    RETURN;
    --END;

    -- Вставка только тех книг, год которых более 2010
    IF EXISTS (
        SELECT 1
        FROM INSERTED
        WHERE year < 2010
    )
    BEGIN
        PRINT N'В списке книг есть хотябы одна, с годом менее 2010. Вставлены только те книги, год которых более 2009';

        INSERT INTO Book (publishing_id, author_id, year, name)
        SELECT publishing_id, author_id, year, name
        FROM inserted
        WHERE year >= 2010;

        RETURN;
    END;

    -- Продолжить вставку, если проверка прошла успешно
    INSERT INTO Book (publishing_id, author_id, year, name)
    SELECT publishing_id, author_id, year, name
    FROM inserted;
END;
GO

--DROP TRIGGER trg_InsteadOfInsertBook;
--GO