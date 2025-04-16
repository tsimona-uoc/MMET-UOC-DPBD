START TRANSACTION;

CREATE TABLE IF NOT EXISTS backup_users AS
SELECT * FROM users WHERE 1 = 0;

SELECT*
FROM backup_users

INSERT INTO backup_users
SELECT *
FROM users
WHERE userid IN (
    SELECT userid
    FROM users_without_buys
    WHERE userid IN (SELECT userid FROM users_without_sells)
);
