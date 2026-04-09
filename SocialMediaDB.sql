-- =========================
-- Database Design Overview
-- =========================
-- The database is designed to represent social media usage data.
-- It separates static entities (Users, Platforms, Genders)
-- from dynamic activity data (Posts, Daily_Usage).
-- This structure reduces data duplication, enforces data integrity,
-- and supports future analytical queries using SQL, BI, and Python.

USE master;

GO

if exists (select * from sysdatabases where name='SocialMediaDB')
		drop database SocialMediaDB

GO

CREATE DATABASE SocialMediaDB

GO

USE SocialMediaDB

GO

-- Table: Genders
-- Purpose: Lookup table that stores possible gender values.
-- Reason: Prevents duplicate or inconsistent gender entries.
-- Relationship: Referenced by Users.gender_id (one gender to many users).
CREATE TABLE Genders
(gender_id INT IDENTITY CONSTRAINT SMDB_gendid_pk PRIMARY KEY,
 gender_name VARCHAR(20) NOT NULL,
 constraint SMDB_gendname_uk unique (gender_name)
 )

 GO

-- Table: Users
-- Purpose: Stores basic and demographic information about users.
-- Reason: Acts as the central entity for all user-related activity.
-- Relationships:
	-- gender_id references Genders(gender_id)
	-- user_id is referenced by Posts and Daily_Usage (one user to many records).
 CREATE TABLE Users
(user_id INT IDENTITY CONSTRAINT SMDB_userid_pk PRIMARY KEY,
 full_name VARCHAR(100) NOT NULL,
 age INT,
 date_of_birth DATE,
 email varchar(100),
 constraint SMDB_email_uk unique (email),
 gender_id INT not null,
 constraint SMDB_gendid_fk foreign key (gender_id) references Genders(gender_id),
 country varchar(50)
 )

 GO

-- Table: Platforms
-- Purpose: Stores social media platforms (e.g., Instagram, TikTok).
-- Reason: Centralizes platform data and avoids repeated platform names.
-- Relationships:
	-- platform_id is referenced by Posts and Daily_Usage
	-- (one platform to many activity records).
 CREATE TABLE Platforms
(platform_id INT IDENTITY CONSTRAINT SMDB_platid_pk PRIMARY KEY,
 platform_name VARCHAR(50) NOT NULL,
 constraint SMDB_platname_uk unique (platform_name),
 category varchar(50)
 )

 GO

-- Table: Posts
-- Purpose: Stores individual posts created by users.
-- Reason: Represents content-level activity for detailed analysis.
-- Relationships:
	-- user_id references Users(user_id)
	-- platform_id references Platforms(platform_id)
	-- Each post belongs to one user and one platform.
 CREATE TABLE Posts
(post_id INT IDENTITY CONSTRAINT SMDB_postid_pk PRIMARY KEY,
 user_id INT NOT NULL,
 constraint SMDB_posts_userid_fk FOREIGN KEY (user_id) references Users(user_id),
 platform_id INT NOT NULL,
 constraint SMDB_posts_platid_fk FOREIGN KEY (platform_id) references Platforms(platform_id),
 post_datetime datetime not null,
 content varchar(500),
 likes_count INT not null,
 comments_count int not null
 )

 GO

-- Table: Daily_Usage
-- Purpose: Stores daily aggregated usage data per user and platform.
-- Reason: Enables time-based analysis such as usage duration,
--         number of sessions, and user activity patterns.
-- Relationships:
	-- user_id references Users(user_id)
	-- platform_id references Platforms(platform_id)
	-- Each record represents one user, one platform, on one day.
 CREATE TABLE Daily_usage
(usage_id INT IDENTITY CONSTRAINT SMDB_usageid_pk PRIMARY KEY,
 user_id int not null,
 constraint SMDB_du_userid_fk FOREIGN KEY (user_id) references Users(user_id),
 platform_id INT NOT NULL,
 constraint SMDB_du_platid_fk FOREIGN KEY (platform_id) references Platforms(platform_id),
 usage_date date not null,
 sessions_per_day int not null,
 total_minutes int not null,
 posts_per_day int not null,
 likes_given_per_day int not null,
 messages_sent_per_day int not null
 )

 GO

 INSERT INTO Genders (gender_name)
 VALUES ('Male'),
		('Female'),
		('Non-binary')

GO

 INSERT INTO Platforms (platform_name,category)
 VALUES ('Instagram','Photo sharing'),
		('TikTok','Video'),
		('Facebook','Social network'),
		('LinkedIn','Professional'),
		('Telegram','Messaging'),
		('Spotify','Music'),
		('Twitter','Microblogging')

GO

INSERT INTO Users (full_name, age, date_of_birth, email, gender_id, country) 
VALUES
('Noa Cohen',27,'1998-04-15','noa@gmail.com',2,'Israel'),
('Daniel Levi',21,'2003-09-10','daniel@gmail.com',3,'Israel'),
('Alex Green',28,'1997-01-22','alex@gmail.com',3,'United States'),
('Yossi Bar',27,'1998-11-02','yossi@gmail.com',1,'Germany'),
('Lior Shalev',21,'2003-03-18','lior@gmail.com',3,'United Kingdom'),
('Tal Mor',24,'2001-06-25','tal@gmail.com',2,'Brazil'),
('Michael Stone',30,'1995-07-12','michal@gmail.com',1,'Japan'),
('Dana Azulay',19,'2006-02-14','dana@gmail.com',2,'Israel'),
('John Smith',34,'1991-09-03','john@gmail.com',1,'Canada'),
('Emily Johnson',26,'1999-05-30','emily@gmail.com',2,'India'),
('Robin Taylor',22,'2002-01-09','robin@gmail.com',3,'Israel'),
('Omer Ben David',29,'1996-12-21','omer@gmail.com',1,'France'),
('Sara Cohen',23,'2002-08-04','sara@gmail.com',2,'Spain'),
('Yonatan Azul',20,'2005-03-06','yonatan@gmail.com',3,'Mexico'),
('David Levi',32,'1993-10-11','david@gmail.com',1,'Italy'),
('Shira Gold',28,'1997-08-15','shira@gmail.com',2,'Netherlands'),
('Kim Adler',25,'2000-04-09','kim@gmail.com',3,'Sweden'),
('Amir Cohen',31,'1994-02-28','amir@gmail.com',1,'Norway'),
('Gal Peretz',27,'1998-06-17','gal@gmail.com',2,'Argentina'),
('Neta Fox',23,'2002-07-01','neta@gmail.com',3,'South Africa');

GO

INSERT INTO Posts (user_id, platform_id, post_datetime, content, likes_count, comments_count)
VALUES
(1,1,'2025-01-01T10:00:00','Brunch with friends',40,10),
(1,3,'2025-01-01T18:15:00','Sharing a family update',25,5),
(2,2,'2025-01-01T09:30:00','Dance challenge video',90,20),
(2,7,'2025-01-01T21:05:00','Tweet about new tech',30,8),
(3,1,'2025-01-02T11:10:00','Travel photo from Rome',52,12),
(3,3,'2025-01-02T19:40:00','Opinion on a news topic',18,4),
(4,4,'2025-01-01T08:00:00','Announcing a new job',60,15),
(5,1,'2025-01-03T13:25:00','Gym progress photo',26,6),
(6,2,'2025-01-03T16:10:00','Funny pet video',40,9),
(7,6,'2025-01-01T20:00:00','Shared workout playlist',0,2),
(8,5,'2025-01-02T09:05:00','Channel update message',5,2),
(9,7,'2025-01-02T14:45:00','Short opinion tweet',38,11),
(10,1,'2025-01-02T10:20:00','Sunset photo',60,15),
(10,2,'2025-01-02T22:10:00','Mini vlog',46,12),
(11,6,'2025-01-01T07:50:00','Shared podcast episode',0,1),
(12,4,'2025-01-03T09:00:00','Post about data career',12,4),
(13,1,'2025-01-03T18:30:00','Baking cookies at home',45,10),
(14,3,'2025-01-04T12:10:00','Birthday party album',14,3),
(15,7,'2025-01-04T21:30:00','Thread about SQL tips',120,25);

GO

INSERT INTO Daily_Usage (user_id, platform_id, usage_date, sessions_per_day, total_minutes, posts_per_day, likes_given_per_day, messages_sent_per_day)
VALUES (1,1,'2025-01-01',3,120,2,35,10),
		(1,3,'2025-01-01',1,45,1,10,5),
		(2,2,'2025-01-01',4,150,2,60,8),
		(2,7,'2025-01-01',2,80,1,25,3),
		(3,1,'2025-01-02',3,110,1,40,6),
		(3,3,'2025-01-02',1,40,1,12,4),
		(4,4,'2025-01-01',2,35,1,8,2),
		(5,1,'2025-01-03',2,90,1,20,4),
		(6,2,'2025-01-03',3,95,2,30,6),
		(7,6,'2025-01-01',1,60,0,0,1),
		(8,5,'2025-01-02',3,70,0,5,20),
		(9,7,'2025-01-02',2,85,2,28,5),
		(10,1,'2025-01-02',3,130,2,45,7),
		(10,2,'2025-01-02',2,90,1,30,5),
		(11,6,'2025-01-01',1,50,0,0,1),
		(12,4,'2025-01-03',2,55,1,10,3),
		(13,1,'2025-01-03',2,95,2,35,6),
		(14,3,'2025-01-04',1,40,1,12,3),
		(15,7,'2025-01-04',3,160,2,50,9);

GO


