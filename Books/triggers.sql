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

    BEGIN TRY
        -- Проверка, что count в ReadingRoomBook не равен 0
        IF NOT EXISTS (
            SELECT 1
            FROM inserted i
            INNER JOIN ReadingRoomBook rrb ON i.reading_room_book_id = rrb.id AND rrb.count > 0
        )
        BEGIN
            ;THROW 50001, N'Книга отсутствует', 1;
        END;

        -- Проверка, что у студента меньше 3 книг на руках
        IF EXISTS (
            SELECT 1
            FROM LibraryCardBook lcb
            WHERE 
                lcb.card_id = (SELECT card_id FROM inserted)
                AND lcb.returned_date IS NULL
            GROUP BY lcb.card_id
            HAVING COUNT(*) >= 3
        )
        BEGIN
            ;THROW 50002, N'Студент не может взять больше 3 книг.', 1;
        END;

        -- Продолжить вставку, если проверка прошла успешно
        INSERT INTO LibraryCardBook (reading_room_book_id, card_id, issued_date, returned_date)
        SELECT reading_room_book_id, card_id, issued_date, returned_date
        FROM inserted;
    END TRY
    BEGIN CATCH
        PRINT 'Ошибка: ' + ERROR_MESSAGE();
    END CATCH;
END;
GO

CREATE TRIGGER trg_InsteadOfDeleteBook
ON Book
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;

    -- Обновить count в таблице ReadingRoomBook на 0
    UPDATE ReadingRoomBook
    SET count = 0
    WHERE book_id IN (SELECT id FROM deleted);

    -- Пометить книги как удаленные
    UPDATE Book
    SET is_deleted = 1
    WHERE id IN (SELECT id FROM deleted);
END;
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
        RETURN;
    END;

    -- Продолжить вставку, если проверка прошла успешно
    INSERT INTO Book (publishing_id, author_id, year, name)
    SELECT publishing_id, author_id, year, name
    FROM inserted;
END;
GO