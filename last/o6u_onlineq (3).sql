-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1:3307
-- Generation Time: Feb 21, 2025 at 10:30 AM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `o6u_onlineq`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `generateInstructorInvites` (IN `count` INT)   BEGIN
  DECLARE i INT DEFAULT 0;
  WHILE i < count DO
    INSERT INTO instructor_invitations(`code`) VALUES (
      CRC32(CONCAT(NOW(), RAND()))
    );
    SET i = i + 1;
  END WHILE;

END$$

--
-- Functions
--
CREATE DEFINER=`root`@`localhost` FUNCTION `checkAnswer` (`answer_id` INT) RETURNS INT(11) DETERMINISTIC BEGIN
    DECLARE result INT;
    SELECT COUNT(*) INTO result FROM answers WHERE id = answer_id;
    RETURN result;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `generateGroupInvites` (`groupID` INT, `count` INT, `pf` VARCHAR(50)) RETURNS INT(11)  BEGIN
  DECLARE i INT DEFAULT 0;
  WHILE i < count DO
    INSERT INTO group_invitations(groupID,`code`) VALUES (
      groupID,CONCAT(COALESCE(pf,''),CRC32(CONCAT(NOW(), RAND())))
    );
    SET i = i + 1;
  END WHILE;
	RETURN 0;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `getQuestionRightAnswers` (`qid` INT) RETURNS VARCHAR(255) CHARSET utf8 COLLATE utf8_general_ci  BEGIN
DECLARE C VARCHAR(255);
DECLARE qtype INT;
SET qtype = (select type from question where id = qid);
IF (qtype = 1) THEN
SELECT 'True' INTO C FROM question WHERE id = qID AND isTrue = 1;
	IF C IS NULL THEN
	SET C = 'False';
	END IF;
ELSEIF (qtype = 2) THEN
SELECT GROUP_CONCAT(answer SEPARATOR ', ') into C FROM question_answers
WHERE questionID = qid
GROUP BY questionID;

ELSEIF (qtype = 4) THEN
SELECT GROUP_CONCAT(CONCAT(answer, ' => ', matchAnswer) ORDER BY id SEPARATOR ', ') into C FROM question_answers
WHERE questionID = qid
GROUP BY questionID;
ELSE
SELECT GROUP_CONCAT(answer SEPARATOR ', ') into C FROM question_answers
WHERE questionID = qid AND isCorrect
GROUP BY questionID;
END IF;
RETURN C;

END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `getQuestionsInTest` (`tID` INT) RETURNS INT(11)  BEGIN
DECLARE C INT(11);
SELECT ((SELECT count(*) FROM tests_has_questions WHERE testID = tID) + COALESCE((SELECT SUM(questionsCount) FROM test_random_questions WHERE testID = tID),0)) INTO C;
   IF (C IS NULL) THEN
      SET C = 0;
   END IF;


RETURN C;

END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `getResultGrade` (`result_id` INT) RETURNS VARCHAR(10) CHARSET utf8mb4 COLLATE utf8mb4_general_ci DETERMINISTIC BEGIN
    DECLARE grade VARCHAR(10);
    DECLARE score INT;

    -- Fetch the score from the result table (modify if needed)
    SELECT SUM(score) INTO score FROM result WHERE id = result_id;

    -- Assign a grade based on the score
    IF score >= 90 THEN
        SET grade = 'A';
    ELSEIF score >= 80 THEN
        SET grade = 'B';
    ELSEIF score >= 70 THEN
        SET grade = 'C';
    ELSE
        SET grade = 'F';
    END IF;

    RETURN grade;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `getResultMaxGrade` (`result_id` INT) RETURNS INT(11) DETERMINISTIC BEGIN
    DECLARE maxGrade INT;

    -- Modify the calculation based on your database structure
    SELECT MAX(score) INTO maxGrade FROM result WHERE id = result_id;

    RETURN maxGrade;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `getTestGrade` (`test_id` INT) RETURNS DECIMAL(10,2) DETERMINISTIC BEGIN
    DECLARE total_grade DECIMAL(10,2);
    
    SELECT SUM(points) INTO total_grade 
    FROM result_answers 
    WHERE resultID IN (SELECT id FROM result WHERE testID = test_id);
    
    RETURN IFNULL(total_grade, 0);
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `Result_CorrectQuestions` (`exam_id` INT) RETURNS INT(11) DETERMINISTIC BEGIN
    DECLARE correct_count INT;
    
    SELECT COUNT(*) INTO correct_count
    FROM answers
    WHERE exam_id = exam_id AND is_correct = 1; 

    RETURN correct_count;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `Result_WrongQuestions` (`exam_id` INT) RETURNS INT(11) DETERMINISTIC BEGIN
    DECLARE wrong_count INT;
    SELECT COUNT(*) INTO wrong_count FROM answers WHERE exam_id = exam_id AND is_correct = 0;
    RETURN wrong_count;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `answers`
--

CREATE TABLE `answers` (
  `id` int(11) NOT NULL,
  `exam_id` int(11) DEFAULT NULL,
  `question_id` int(11) DEFAULT NULL,
  `student_id` int(11) DEFAULT NULL,
  `is_correct` tinyint(1) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `course`
--

CREATE TABLE `course` (
  `id` int(11) NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  `parent` int(11) DEFAULT NULL,
  `instructorID` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Table structure for table `groups`
--

CREATE TABLE `groups` (
  `id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `assignedTest` int(11) DEFAULT NULL,
  `settingID` int(11) DEFAULT NULL,
  `instructorID` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Table structure for table `groups_has_students`
--

CREATE TABLE `groups_has_students` (
  `groupID` int(11) NOT NULL,
  `studentID` int(11) NOT NULL,
  `joinDate` datetime DEFAULT NULL ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Table structure for table `group_invitations`
--

CREATE TABLE `group_invitations` (
  `groupID` int(11) DEFAULT NULL,
  `code` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Table structure for table `instructor`
--

CREATE TABLE `instructor` (
  `id` int(11) NOT NULL,
  `name` varchar(120) NOT NULL,
  `email` varchar(120) NOT NULL,
  `password` varchar(100) NOT NULL,
  `phone` varchar(13) NOT NULL,
  `password_token` varchar(100) DEFAULT NULL,
  `token_expire` timestamp NULL DEFAULT NULL,
  `suspended` int(11) NOT NULL DEFAULT 0,
  `isAdmin` tinyint(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

--
-- Dumping data for table `instructor`
--

INSERT INTO `instructor` (`id`, `name`, `email`, `password`, `phone`, `password_token`, `token_expire`, `suspended`, `isAdmin`) VALUES
(38, 'mostafa heraji', 'admin@gmail.com', '21232f297a57a5a743894a0e4a801fc3', '01276612118', NULL, NULL, 0, 0);

-- --------------------------------------------------------

--
-- Table structure for table `instructor_invitations`
--

CREATE TABLE `instructor_invitations` (
  `code` varchar(36) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Table structure for table `mails`
--

CREATE TABLE `mails` (
  `id` int(11) NOT NULL,
  `resultID` int(11) DEFAULT NULL,
  `studentID` int(11) DEFAULT NULL,
  `instructorID` int(11) DEFAULT NULL,
  `sends_at` timestamp NULL DEFAULT NULL,
  `sent` tinyint(1) DEFAULT 0,
  `type` tinyint(1) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Table structure for table `question`
--

CREATE TABLE `question` (
  `id` int(11) NOT NULL,
  `question` varchar(2000) DEFAULT NULL,
  `type` int(1) DEFAULT NULL COMMENT '0 - MCQ / 1 - T/F /2- COMPLETE/',
  `points` int(11) NOT NULL DEFAULT 1,
  `difficulty` tinyint(1) DEFAULT 1,
  `isTrue` tinyint(1) NOT NULL DEFAULT 1,
  `instructorID` int(11) NOT NULL,
  `courseID` int(11) DEFAULT NULL,
  `deleted` tinyint(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Table structure for table `question_answers`
--

CREATE TABLE `question_answers` (
  `id` int(11) NOT NULL,
  `questionID` int(11) DEFAULT NULL,
  `answer` varchar(2000) DEFAULT NULL,
  `matchAnswer` varchar(255) DEFAULT NULL,
  `isCorrect` tinyint(1) DEFAULT 1,
  `points` int(2) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Table structure for table `result`
--

CREATE TABLE `result` (
  `id` int(11) NOT NULL,
  `studentID` int(11) NOT NULL,
  `testID` int(11) NOT NULL,
  `groupID` int(11) DEFAULT NULL,
  `settingID` int(11) DEFAULT NULL,
  `startTime` timestamp NOT NULL DEFAULT current_timestamp(),
  `endTime` timestamp NULL DEFAULT NULL,
  `isTemp` tinyint(1) NOT NULL DEFAULT 1,
  `hostname` varchar(255) DEFAULT NULL,
  `ipaddr` varchar(15) DEFAULT NULL,
  `score` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Table structure for table `result_answers`
--

CREATE TABLE `result_answers` (
  `id` int(11) NOT NULL,
  `resultID` int(11) NOT NULL,
  `questionID` int(11) NOT NULL,
  `answerID` int(11) DEFAULT NULL,
  `isTrue` tinyint(1) DEFAULT NULL,
  `textAnswer` varchar(2000) DEFAULT NULL,
  `points` int(3) DEFAULT -1,
  `isCorrect` tinyint(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Table structure for table `student`
--

CREATE TABLE `student` (
  `id` int(11) NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `phone` varchar(255) DEFAULT NULL,
  `password` varchar(255) DEFAULT NULL,
  `password_token` varchar(100) DEFAULT NULL,
  `token_expire` timestamp NULL DEFAULT NULL,
  `suspended` tinyint(1) DEFAULT 0,
  `sessionID` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

--
-- Dumping data for table `student`
--

INSERT INTO `student` (`id`, `name`, `email`, `phone`, `password`, `password_token`, `token_expire`, `suspended`, `sessionID`) VALUES
(201234567, 'omar rehan', 'omar@gmail.com', '01276112119', '276506d3704c67d67ff9a500be50dd95', NULL, NULL, 0, 'ugvf83kao77ac6k0u9g3imcq5v');

-- --------------------------------------------------------

--
-- Table structure for table `students_has_tests`
--

CREATE TABLE `students_has_tests` (
  `studentID` int(11) DEFAULT NULL,
  `testID` int(11) DEFAULT NULL,
  `settingID` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Table structure for table `tempquestions`
--

CREATE TABLE `tempquestions` (
  `resultID` int(11) NOT NULL,
  `questionID` int(11) NOT NULL,
  `rand` int(4) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Table structure for table `test`
--

CREATE TABLE `test` (
  `id` int(11) NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  `courseID` int(11) DEFAULT NULL,
  `deleted` tinyint(1) DEFAULT 0,
  `instructorID` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Table structure for table `tests_has_questions`
--

CREATE TABLE `tests_has_questions` (
  `testID` int(11) DEFAULT NULL,
  `questionID` int(11) DEFAULT NULL,
  `rand` int(4) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Table structure for table `test_invitations`
--

CREATE TABLE `test_invitations` (
  `id` int(15) NOT NULL,
  `name` varchar(255) NOT NULL,
  `testID` int(11) DEFAULT NULL,
  `settingID` int(11) DEFAULT NULL,
  `used` tinyint(1) DEFAULT 0,
  `useLimit` int(11) DEFAULT NULL,
  `instructorID` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Table structure for table `test_random_questions`
--

CREATE TABLE `test_random_questions` (
  `testID` int(11) NOT NULL,
  `courseID` int(11) NOT NULL,
  `questionsCount` int(11) NOT NULL,
  `difficulty` int(1) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Table structure for table `test_settings`
--

CREATE TABLE `test_settings` (
  `id` int(11) NOT NULL,
  `startTime` datetime DEFAULT NULL,
  `endTime` datetime DEFAULT NULL,
  `duration` int(3) DEFAULT NULL,
  `random` tinyint(255) DEFAULT NULL,
  `prevQuestion` int(1) DEFAULT NULL,
  `viewAnswers` tinyint(1) DEFAULT NULL,
  `releaseResult` int(1) DEFAULT 1,
  `sendToStudent` tinyint(1) DEFAULT NULL,
  `sendToInstructor` tinyint(1) DEFAULT NULL,
  `passPercent` int(3) DEFAULT NULL,
  `instructorID` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `answers`
--
ALTER TABLE `answers`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `course`
--
ALTER TABLE `course`
  ADD PRIMARY KEY (`id`) USING BTREE,
  ADD KEY `instructorID` (`instructorID`) USING BTREE,
  ADD KEY `parent` (`parent`) USING BTREE;

--
-- Indexes for table `groups`
--
ALTER TABLE `groups`
  ADD PRIMARY KEY (`id`) USING BTREE,
  ADD KEY `instructorID` (`instructorID`) USING BTREE,
  ADD KEY `settingID` (`settingID`) USING BTREE,
  ADD KEY `groups_ibfk_2` (`assignedTest`) USING BTREE;

--
-- Indexes for table `groups_has_students`
--
ALTER TABLE `groups_has_students`
  ADD UNIQUE KEY `my_unique_key` (`groupID`,`studentID`) USING BTREE,
  ADD KEY `groups_has_students_ibfk_2` (`studentID`) USING BTREE;

--
-- Indexes for table `group_invitations`
--
ALTER TABLE `group_invitations`
  ADD UNIQUE KEY `code` (`code`) USING BTREE,
  ADD KEY `groupID` (`groupID`) USING BTREE;

--
-- Indexes for table `instructor`
--
ALTER TABLE `instructor`
  ADD PRIMARY KEY (`id`) USING BTREE;

--
-- Indexes for table `mails`
--
ALTER TABLE `mails`
  ADD PRIMARY KEY (`id`) USING BTREE,
  ADD KEY `resultID` (`resultID`) USING BTREE,
  ADD KEY `instructorID` (`instructorID`) USING BTREE,
  ADD KEY `studentID` (`studentID`) USING BTREE;

--
-- Indexes for table `question`
--
ALTER TABLE `question`
  ADD PRIMARY KEY (`id`) USING BTREE,
  ADD KEY `question_ibfk_1` (`instructorID`) USING BTREE,
  ADD KEY `question_ibfk_2` (`courseID`) USING BTREE;

--
-- Indexes for table `question_answers`
--
ALTER TABLE `question_answers`
  ADD PRIMARY KEY (`id`) USING BTREE,
  ADD KEY `answers_ibfk_1` (`questionID`) USING BTREE,
  ADD KEY `matchAnswer` (`matchAnswer`) USING BTREE;

--
-- Indexes for table `result`
--
ALTER TABLE `result`
  ADD PRIMARY KEY (`id`) USING BTREE,
  ADD UNIQUE KEY `testID_2` (`testID`,`studentID`) USING BTREE,
  ADD KEY `result_ibfk_2` (`studentID`) USING BTREE,
  ADD KEY `settingID` (`settingID`) USING BTREE,
  ADD KEY `groupID` (`groupID`) USING BTREE;

--
-- Indexes for table `result_answers`
--
ALTER TABLE `result_answers`
  ADD PRIMARY KEY (`id`) USING BTREE,
  ADD KEY `FK_result_answers_result` (`resultID`) USING BTREE,
  ADD KEY `FK_result_answers_question` (`questionID`) USING BTREE,
  ADD KEY `answerID` (`answerID`) USING BTREE;

--
-- Indexes for table `student`
--
ALTER TABLE `student`
  ADD PRIMARY KEY (`id`) USING BTREE,
  ADD UNIQUE KEY `email` (`email`) USING BTREE;

--
-- Indexes for table `students_has_tests`
--
ALTER TABLE `students_has_tests`
  ADD UNIQUE KEY `StudentID` (`studentID`,`testID`) USING BTREE,
  ADD KEY `students_has_tests_ibfk_1` (`studentID`) USING BTREE,
  ADD KEY `students_has_tests_ibfk_2` (`testID`) USING BTREE,
  ADD KEY `students_has_tests_ibfk_3` (`settingID`) USING BTREE;

--
-- Indexes for table `tempquestions`
--
ALTER TABLE `tempquestions`
  ADD UNIQUE KEY `resultID` (`resultID`,`questionID`) USING BTREE,
  ADD KEY `quest` (`questionID`) USING BTREE;

--
-- Indexes for table `test`
--
ALTER TABLE `test`
  ADD PRIMARY KEY (`id`) USING BTREE,
  ADD KEY `instructorID` (`instructorID`) USING BTREE,
  ADD KEY `courseID` (`courseID`) USING BTREE;

--
-- Indexes for table `tests_has_questions`
--
ALTER TABLE `tests_has_questions`
  ADD UNIQUE KEY `my_unique_key` (`testID`,`questionID`) USING BTREE,
  ADD KEY `tests_has_questions_ibfk_2` (`questionID`) USING BTREE;

--
-- Indexes for table `test_invitations`
--
ALTER TABLE `test_invitations`
  ADD PRIMARY KEY (`id`) USING BTREE,
  ADD KEY `instructorID` (`instructorID`) USING BTREE,
  ADD KEY `settingID` (`settingID`) USING BTREE,
  ADD KEY `test_invitations_ibfk_1` (`testID`) USING BTREE;

--
-- Indexes for table `test_random_questions`
--
ALTER TABLE `test_random_questions`
  ADD UNIQUE KEY `testID_2` (`testID`,`courseID`,`difficulty`) USING BTREE,
  ADD KEY `testID` (`testID`) USING BTREE,
  ADD KEY `courseID` (`courseID`) USING BTREE;

--
-- Indexes for table `test_settings`
--
ALTER TABLE `test_settings`
  ADD PRIMARY KEY (`id`) USING BTREE,
  ADD KEY `instructorID` (`instructorID`) USING BTREE;

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `answers`
--
ALTER TABLE `answers`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `course`
--
ALTER TABLE `course`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=77;

--
-- AUTO_INCREMENT for table `groups`
--
ALTER TABLE `groups`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=19;

--
-- AUTO_INCREMENT for table `instructor`
--
ALTER TABLE `instructor`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=39;

--
-- AUTO_INCREMENT for table `mails`
--
ALTER TABLE `mails`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=22;

--
-- AUTO_INCREMENT for table `question`
--
ALTER TABLE `question`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=188;

--
-- AUTO_INCREMENT for table `question_answers`
--
ALTER TABLE `question_answers`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=912;

--
-- AUTO_INCREMENT for table `result`
--
ALTER TABLE `result`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=44;

--
-- AUTO_INCREMENT for table `result_answers`
--
ALTER TABLE `result_answers`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=470;

--
-- AUTO_INCREMENT for table `test`
--
ALTER TABLE `test`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=44;

--
-- AUTO_INCREMENT for table `test_invitations`
--
ALTER TABLE `test_invitations`
  MODIFY `id` int(15) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=31;

--
-- AUTO_INCREMENT for table `test_settings`
--
ALTER TABLE `test_settings`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=85;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `course`
--
ALTER TABLE `course`
  ADD CONSTRAINT `course_ibfk_1` FOREIGN KEY (`instructorID`) REFERENCES `instructor` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `course_ibfk_2` FOREIGN KEY (`parent`) REFERENCES `course` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `groups`
--
ALTER TABLE `groups`
  ADD CONSTRAINT `groups_ibfk_1` FOREIGN KEY (`instructorID`) REFERENCES `instructor` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `groups_ibfk_2` FOREIGN KEY (`assignedTest`) REFERENCES `test` (`id`) ON DELETE SET NULL ON UPDATE SET NULL,
  ADD CONSTRAINT `groups_ibfk_3` FOREIGN KEY (`settingID`) REFERENCES `test_settings` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `groups_has_students`
--
ALTER TABLE `groups_has_students`
  ADD CONSTRAINT `groups_has_students_ibfk_1` FOREIGN KEY (`groupID`) REFERENCES `groups` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `groups_has_students_ibfk_2` FOREIGN KEY (`studentID`) REFERENCES `student` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `group_invitations`
--
ALTER TABLE `group_invitations`
  ADD CONSTRAINT `group_invitations_ibfk_1` FOREIGN KEY (`groupID`) REFERENCES `groups` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `mails`
--
ALTER TABLE `mails`
  ADD CONSTRAINT `mails_ibfk_1` FOREIGN KEY (`resultID`) REFERENCES `result` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `mails_ibfk_2` FOREIGN KEY (`instructorID`) REFERENCES `instructor` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `mails_ibfk_3` FOREIGN KEY (`studentID`) REFERENCES `student` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `question`
--
ALTER TABLE `question`
  ADD CONSTRAINT `question_ibfk_1` FOREIGN KEY (`instructorID`) REFERENCES `instructor` (`id`),
  ADD CONSTRAINT `question_ibfk_2` FOREIGN KEY (`courseID`) REFERENCES `course` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `question_answers`
--
ALTER TABLE `question_answers`
  ADD CONSTRAINT `question_answers_ibfk_1` FOREIGN KEY (`questionID`) REFERENCES `question` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `result`
--
ALTER TABLE `result`
  ADD CONSTRAINT `result_ibfk_2` FOREIGN KEY (`studentID`) REFERENCES `student` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `result_ibfk_3` FOREIGN KEY (`testID`) REFERENCES `test` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `result_ibfk_4` FOREIGN KEY (`settingID`) REFERENCES `test_settings` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `result_ibfk_5` FOREIGN KEY (`groupID`) REFERENCES `groups` (`id`) ON DELETE SET NULL ON UPDATE SET NULL;

--
-- Constraints for table `result_answers`
--
ALTER TABLE `result_answers`
  ADD CONSTRAINT `FK_result_answers_result` FOREIGN KEY (`resultID`) REFERENCES `result` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `result_answers_ibfk_1` FOREIGN KEY (`answerID`) REFERENCES `question_answers` (`id`),
  ADD CONSTRAINT `result_answers_ibfk_2` FOREIGN KEY (`questionID`) REFERENCES `question` (`id`);

--
-- Constraints for table `students_has_tests`
--
ALTER TABLE `students_has_tests`
  ADD CONSTRAINT `students_has_tests_ibfk_1` FOREIGN KEY (`studentID`) REFERENCES `student` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `students_has_tests_ibfk_2` FOREIGN KEY (`testID`) REFERENCES `test` (`id`) ON UPDATE CASCADE,
  ADD CONSTRAINT `students_has_tests_ibfk_3` FOREIGN KEY (`settingID`) REFERENCES `test_settings` (`id`) ON UPDATE CASCADE;

--
-- Constraints for table `tempquestions`
--
ALTER TABLE `tempquestions`
  ADD CONSTRAINT `tempquestions_ibfk_1` FOREIGN KEY (`resultID`) REFERENCES `result` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `test`
--
ALTER TABLE `test`
  ADD CONSTRAINT `test_ibfk_1` FOREIGN KEY (`instructorID`) REFERENCES `instructor` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `test_ibfk_2` FOREIGN KEY (`courseID`) REFERENCES `course` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `tests_has_questions`
--
ALTER TABLE `tests_has_questions`
  ADD CONSTRAINT `tests_has_questions_ibfk_1` FOREIGN KEY (`testID`) REFERENCES `test` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `tests_has_questions_ibfk_2` FOREIGN KEY (`questionID`) REFERENCES `question` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `test_invitations`
--
ALTER TABLE `test_invitations`
  ADD CONSTRAINT `test_invitations_ibfk_1` FOREIGN KEY (`testID`) REFERENCES `test` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `test_invitations_ibfk_3` FOREIGN KEY (`instructorID`) REFERENCES `instructor` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `test_invitations_ibfk_4` FOREIGN KEY (`settingID`) REFERENCES `test_settings` (`id`);

--
-- Constraints for table `test_random_questions`
--
ALTER TABLE `test_random_questions`
  ADD CONSTRAINT `test_random_questions_ibfk_1` FOREIGN KEY (`courseID`) REFERENCES `course` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `test_random_questions_ibfk_2` FOREIGN KEY (`testID`) REFERENCES `test` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `test_settings`
--
ALTER TABLE `test_settings`
  ADD CONSTRAINT `test_settings_ibfk_1` FOREIGN KEY (`instructorID`) REFERENCES `instructor` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
