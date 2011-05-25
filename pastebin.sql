CREATE TABLE pastes (

  id serial, 
  title varchar default NULL,
  content text,
  lang varchar default NULL,
  poster varchar default NULL,
  user_id integer,
  created_on timestamp,
  updated_on timestamp default NULL,
  PRIMARY KEY (id)

);

CREATE TABLE users (

  id serial,
  username varchar default NULL,
  name varchar default NULL,
  email varchar default NULL,
  password varchar default NULL,
  PRIMARY KEY (id)

);

CREATE TABLE active (
	
  id serial,
  user_id integer default NULL REFERENCES pastes (id) ON DELETE SET NULL ON UPDATE SET NULL,
  logged_on integer default NULL,
  PRIMARY KEY (id)

);


CREATE TABLE forks (

  id serial,
  paste_id integer default NULL REFERENCES pastes (id) ON DELETE CASCADE ON UPDATE CASCADE,
  fork_id integer default NULL REFERENCES pastes (id) ON DELETE CASCADE ON UPDATE CASCADE,
  created_on timestamp default NULL,
  PRIMARY KEY (id)

);


CREATE TABLE revisions (

  id serial,
  paste_id integer default NULL REFERENCES pastes (id) ON DELETE CASCADE ON UPDATE CASCADE,
  revision_id integer default NULL REFERENCES pastes (id) ON DELETE CASCADE ON UPDATE CASCADE,
  version integer,
  PRIMARY KEY (id)

);

CREATE TABLE roles (

  id serial,
  role varchar default NULL,
  PRIMARY KEY (id)

);



CREATE TABLE user_role (

  id serial,
  user_id integer  default '0' REFERENCES users (id) ON DELETE CASCADE,
  role_id integer  default '1' REFERENCES roles (id) ON DELETE SET DEFAULT,
  PRIMARY KEY(id)

);

CREATE TABLE notifications (
	
	id serial,
	user_id integer default NULL REFERENCES users (id) ON DELETE CASCADE,
	message text,
	created_on integer,
	sent_on integer,
	PRIMARY KEY (id)

);

CREATE TABLE links (

	id serial,
	shortlink varchar(32),
	link varchar(1024),
	user_id integer default NULL REFERENCES users (id) ON DELETE CASCADE,
	created_on integer,
	PRIMARY KEY (id)

);
	



INSERT INTO users (username, name, email, password) VALUES ('admin','Admini Strator','admin@hg.fr.am','21232f297a57a5a743894a0e4a801fc3');
INSERT INTO roles (role) VALUES ('user');
INSERT INTO roles (role) VALUES ('admin');
INSERT INTO user_role (user_id, role_id) VALUES (1, 2); 
ALTER TABLE pastes ADD CONSTRAINT user_id_ibfk FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE;
