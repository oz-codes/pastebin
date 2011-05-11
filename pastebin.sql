CREATE DATABASE pastebin;
CREATE USER 'pastebin'@'localhost' IDENTIFIED BY 'user';
GRANT ALL ON `pastebin`.* TO 'pastebin'@'localhost';
USE pastebin;

CREATE TABLE `pastes` (
	`id` int(10) AUTO_INCREMENT,
	`title` char(64),
	`content` text,
	`lang` char(16),
	`poster` char(20),
	`created_on` datetime,
	`updated_on` datetime,
	`user_id` int(10),
	PRIMARY KEY (`id`),
	FOREIGN KEY (`user_id`) REFERENCES `users`(`id`),
	KEY `post_title` (`title`),
	KEY `language` (`lang`)
) ENGINE=InnoDB, DEFAULT CHARSET=utf8;

CREATE TABLE `forks` (
	`id` int(10) AUTO_INCREMENT,
	`paste_id` int(10),
        `fork_id`  int(10),
	`created_on` datetime,
	 PRIMARY KEY (`id`),
	 KEY `paste` (`paste_id`),
	 FOREIGN KEY ( `paste_id` )  REFERENCES `pastes`(`id`) ON DELETE CASCADE,
	 FOREIGN KEY ( `fork_id`  )  REFERENCES `pastes`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB, DEFAULT CHARSET=utf8;

CREATE TABLE `users` (
	`id` int(10) AUTO_INCREMENT,
	`username` char(32),
	`name` char(32),
	`email` char(64),
	`password` char(32),
	`last_paste` int(10) DEFAULT NULL,
	 PRIMARY KEY (`id`),
	 KEY `full_name` (`name`),
	 FOREIGN KEY (`last_paste`) REFERENCES `pastes`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB, DEFAULT CHARSET=utf8;

CREATE TABLE `roles` (
	`id` int(1) AUTO_INCREMENT,
	`role` char(64),
	PRIMARY KEY(`id`)
) ENGINE = InnoDB, DEFAULT CHARSET=utf8;

CREATE TABLE `user_role` (
	user_id int(10),
	role_id int(10),
	PRIMARY KEY (`user_id`, `role_id`),
	FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
	FOREIGN KEY (`role_id`) REFERENCES `roles`(`id`) ON DELETE CASCADE
) ENGINE = InnoDB, DEFAULT CHARSET = utf8;
	
CREATE TABLE `revisions` (
	`id` int(10) AUTO_INCREMENT,
	`paste_id` int(10),
	PRIMARY KEY (`id`),
	FOREIGN KEY (`paste_id`) REFERENCES `pastes`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB, DEFAULT CHARSET=utf8;

CREATE TABLE `active` (
	`id` int(10) AUTO_INCREMENT,
	`user_id` int(10),
	`logged_on` int(10),
	PRIMARY KEY (`id`),
	FOREIGN KEY (`user_id`) REFERENCES `pastes`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB, DEFAULT CHARSET=utf8;

INSERT INTO `users` (`username`,`name`,`email`,`password`) VALUES ('admin','Admini Strator','admin@hg.fr.am',MD5('admin'));
INSERT INTO `users` (`username`,`name`,`email`,`password`) VALUES ('test1','Test One','test1@hg.fr.am',MD5('test1'));
INSERT INTO `users` (`username`,`name`,`email`,`password`) VALUES ('test2','Test Two','test2@hg.fr.am',MD5('test2'));
INSERT INTO `roles` VALUES (1,"User");
INSERT INTO `roles` VALUES (2,"Moderator");
INSERT INTO `roles` VALUES (3,"Administrator");
INSERT INTO `user_role` VALUES ( 1 , 3 );
INSERT INTO `user_role` VALUES ( 2 , 1 );
INSERT INTO `user_role` VALUES ( 3 , 2 );
