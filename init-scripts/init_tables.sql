-- init_tables.sql
CREATE TABLE IF NOT EXISTS log_in_info (
  id INTEGER PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  username VARCHAR (255),
  password VARCHAR (255)
);




