DROP TABLE IF EXISTS account;

CREATE TABLE account(
 user_id serial PRIMARY KEY,
 username VARCHAR (50) UNIQUE NOT NULL,
 password VARCHAR (50) NOT NULL,
 email VARCHAR (355) UNIQUE NOT NULL,
 created_on TIMESTAMP NOT NULL
);

INSERT INTO account VALUES(1, 'spcruzaley', 'password', 'email@server.com', now());
