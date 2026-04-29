CREATE DATABASE game_management;

USE game_management;

CREATE TABLE GAMES (
	game_id VARCHAR(5) PRIMARY KEY,
    game_name VARCHAR(100) NOT NULL UNIQUE,
    genre VARCHAR(50) NOT NULL,
    developer VARCHAR(100) NOT NULL
);

CREATE TABLE MATCHES (
	match_id VARCHAR(5) PRIMARY KEY,
    game_id VARCHAR(5) NOT NULL,
    arena_name VARCHAR(50) NOT NULL,
    start_time 	DATETIME NOT NULL,
    entry_fee DECIMAL(10,2) NOT NULL,
    
    FOREIGN KEY(game_id) REFERENCES GAMES(game_id)
);

CREATE TABLE PLAYERS (
	player_id VARCHAR(5) PRIMARY KEY,
    nickname VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    rank_level VARCHAR(50) NOT NULL
);

CREATE TABLE REGISTRATIONS (
	reg_id INT AUTO_INCREMENT PRIMARY KEY,
    match_id VARCHAR(5) NOT NULL,
    player_id VARCHAR(5) NOT NULL,
    team_name VARCHAR(50) NOT NULL,
    `status` VARCHAR(20) NOT NULL,
    
    FOREIGN KEY(match_id) REFERENCES MATCHES(match_id) ON DELETE CASCADE,
    FOREIGN KEY(player_id) REFERENCES PLAYERS(player_id)
);

INSERT INTO GAMES(game_id, game_name, genre, developer) VALUES
('G01',  'League of Legends', 'MOBA', 'Riot'),
('G02',  'Valorant', 'FPS', 'Riot'),
('G03',  'DOTA 2', 'MOBA', 'Valve'),
('G04',  'CS2', 'FPS', 'Valve');

INSERT INTO MATCHES(match_id, game_id, arena_name, start_time, entry_fee) VALUES
('S01', 'G01', 'Stadium A', '2025-11-10 18:00:00', 500000.00),
('S02', 'G02', 'Studio B', '2025-11-10 20:00:00', 300000.00),
('S03', 'G01', 'Stadium A', '2025-11-11 09:00:00', 200000.00),
('S04', 'G04', 'Online Server', '2025-11-12 14:00:00', 150000.00);

SELECT * FROM PLAYERS;

INSERT INTO PLAYERS(player_id, nickname, email, rank_level) VALUES
('P01', 'Faker', 'faker@t1.com', 'Challenger'),
('P02', 'TenZ', 'tenz@sentinels.com', 'Radiant'),
('P03', 'S1mple', 'simple@navi.com', 'Global Elite');

INSERT INTO REGISTRATIONS(match_id, player_id, team_name, `status`) VALUES
('S01', 'P01', 'T1', 'Confirmed'),
('S02', 'P02', 'Sentinels', 'Confirmed'),
('S01', 'P03', 'NAVI', 'Cancelled'),
('S04', 'P01', 'T1', 'Confirmed'),
('S03', 'P02', 'MixTeam', 'Pending');

-- update giá thêm 15%
UPDATE MATCHES
SET entry_fee = entry_fee * 1.5
WHERE match_id = 'S01';

-- Thay đổi rank của người chơi có nickname là Faker
UPDATE PLAYERS 
SET rank_level = 'Legendary'
WHERE nickname = 'Faker';

-- Xóa các đơn có trạng thái là cancelled
DELETE FROM REGISTRATIONS
WHERE `status` = 'Cancelled';

-- THêm rằng buộc check vào bài
ALTER TABLE MATCHES
ADD CONSTRAINT chk_entry_fee CHECK(entry_fee > 0);

-- thêm default vào cột status
ALTER TABLE REGISTRATIONS
ALTER COLUMN `status` SET DEFAULT 'Pending';

-- thêm cột nationlity 
ALTER TABLE PLAYERS
ADD COLUMN nationality VARCHAR(50);

-- hiển thị danh sách các game có genre là MOBA
SELECT * FROM GAMES
WHERE genre = 'MOBA';

-- hiển thị các người chơi có nickname chứa kí tự 'e'
SELECT nickname, email
FROM PLAYERS
WHERE nickname LIKE '%e%';

-- hiển thị trận đấu thời gian giảm dần
SELECT match_id, arena_name, start_time
FROM MATCHES
ORDER BY start_time DESC;

-- hiển thị 3 matches có fee thấp nhất
SELECT * FROM MATCHES
ORDER BY entry_fee ASC
LIMIT 3;

-- hiển thị games bỏ qua 2 game đầu
SELECT game_name, genre FROM GAMES
LIMIT 2 OFFSET 2;

-- Giảm 20% lệ phí (entry_fee) cho tất cả các trận đấu diễn ra tại 'Online Server'.
UPDATE MATCHES
SET entry_fee = entry_fee * 0.8
WHERE arena_name = 'Online Server';

-- Chuyển đổi toàn bộ nickname của người chơi trong bảng Players thành chữ in hoa 
UPDATE PLAYERS
SET nickname = UPPER(nickname);
	
-- Xóa trạn đấu entry_fee  = 0
DELETE FROM MATCHES
WHERE entry_fee = 0;

-- Hiển thị danh sách có status bằng confirmed
SELECT r.reg_id, p.nickname,g.game_name, r.team_name 
FROM REGISTRATIONS r
JOIN PLAYERS p ON r.player_id = p.player_id
JOIN MATCHES m ON r.match_id = m.match_id
JOIN GAMES g ON m.game_id = g.game_id
WHERE r.status = 'Confirmed';

-- hiển thị toàn bộ game kể cả các game không có  lịch nào
SELECT g.game_name, m.start_time
FROM GAMES g
LEFT JOIN MATCHES m ON g.game_id = m.game_id;

-- thống ke số trận bằng status
SELECT status, COUNT(*) AS total
FROM REGISTRATIONS
GROUP BY status;

-- Thống kê số lượng trận đấu mà mỗi người chơi đã đăng ký. Chỉ hiện những người đăng ký từ 2 trận trở lên.
SELECT p.player_id, p.nickname, COUNT(*) AS 'total_games'
FROM PLAYERS p
JOIN REGISTRATIONS r ON p.player_id = r.player_id
GROUP BY p.player_id
HAVING COUNT(*) >= 2;

-- Lấy thông tin các trận đấu có lệ phí thấp hơn lệ phí trung bình của tất cả các trận.
SELECT *
FROM MATCHES
WHERE entry_fee < (SELECT AVG(entry_fee) FROM MATCHES);

-- Hiển thị nickname và rank_level của những người chơi đã đăng ký tham gia game 'League of Legends'.
SELECT P.nickname, p.rank_level
FROM REGISTRATIONS r
JOIN PLAYERS p ON r.player_id = p.player_id
JOIN MATCHES m ON r.match_id = m.match_id
JOIN GAMES g ON m.game_id = g.game_id
WHERE g.game_name = 'League of Legends';

-- Liệt kê danh sách các trận đấu diễn ra trong tháng 11 năm 2025.
SELECT * FROM MATCHES
WHERE MONTH(start_time) = 11 AND YEAR(start_time) = 2025;
