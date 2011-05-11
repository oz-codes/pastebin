CREATE TABLE pastes (

  id serial, 
  title char(64) default NULL,
  content text,
  lang char(16) default NULL,
  poster char(20) default NULL,
  user_id int,
  created_on timestamp,
  updated_on timestamp default NULL,
  PRIMARY KEY (id)
);

CREATE TABLE users (

  id serial,
  username char(32) default NULL,
  name char(32) default NULL,
  email char(64) default NULL,
  password char(32) default NULL,
  last_paste integer default NULL,
  CONSTRAINT users_ibfk_1 FOREIGN KEY (last_paste) REFERENCES pastes (id) ON DELETE CASCADE,
  PRIMARY KEY (id)
);

CREATE TABLE active (
	
  id serial,
  user_id integer default NULL,
  logged_on integer default NULL,
  CONSTRAINT active_ibfk_1 FOREIGN KEY (user_id) REFERENCES pastes (id) ON DELETE CASCADE,
  PRIMARY KEY (id)
);


CREATE TABLE forks (

  id serial,
  paste_id integer default NULL,
  fork_id integer default NULL,
  created_on timestamp default NULL,
  CONSTRAINT forks_ibfk_1 FOREIGN KEY (paste_id) REFERENCES pastes (id) ON DELETE CASCADE,
  CONSTRAINT forks_ibfk_2 FOREIGN KEY (fork_id) REFERENCES pastes (id) ON DELETE CASCADE,
  PRIMARY KEY (id)
);


CREATE TABLE revisions (

  id serial,
  paste_id integer default NULL,
  CONSTRAINT revisions_ibfk_1 FOREIGN KEY (paste_id) REFERENCES pastes (id) ON DELETE CASCADE,
  PRIMARY KEY (id)
);

CREATE TABLE roles (

  id serial,
  role char(64) default NULL,
  PRIMARY KEY (id)
);



CREATE TABLE user_role (

  user_id integer  default '0',
  role_id integer  default '0',
  CONSTRAINT user_role_ibfk_1 FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
  CONSTRAINT user_role_ibfk_2 FOREIGN KEY (role_id) REFERENCES roles (id) ON DELETE CASCADE

);



/*!40000 ALTER TABLE users DISABLE KEYS */
INSERT INTO users (username, name, email, password) VALUES ('admin','Admini Strator','admin@hg.fr.am','21232f297a57a5a743894a0e4a801fc3');

ALTER TABLE pastes ADD CONSTRAINT user_id_ibfk FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE;
