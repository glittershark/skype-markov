-- replace <your_username> and <your_skype_name with
-- the path to your home folder and your skype name, respectively
ATTACH DATABASE '/home/<your_username>/.Skype/<your_skype_name>/main.db' AS skype;
ATTACH DATABASE 'markov.db' AS markov;

-- Create the tables that cache data from Skype {{{

CREATE TABLE IF NOT EXISTS markov.people (
  id        INTEGER PRIMARY KEY AUTOINCREMENT,
  skypename TEXT,
  fullname  TEXT
);

CREATE TABLE IF NOT EXISTS markov.chatlog_raw (
  sender_id    INTEGER,
  message_body TEXT,
  -- TODO: chat_id TEXT

  FOREIGN KEY ( sender_id ) REFERENCES markov.people ( id )
);

-- }}}

-- Insert the Skype chatlog data into those tables {{{

INSERT INTO markov.people ( skypename, fullname )
(
  SELECT a.skypename, a.realname FROM skype.Accounts AS a
  -- make sure we don't get anyone who's never said anything
  INNER JOIN skype.Messages AS m
    ON a.skypename = m.author
);

INSERT INTO markov.chatlog_raw ( sender_id, message_body )
(
  SELECT p.id, m.body_xml FROM skype.Messages AS m
  JOIN markov.people AS p
    ON m.author = p.skypename
);

-- }}}

-- Create data structure schemas {{{

CREATE TABLE IF NOT EXISTS markov.chains (
  sender_id INTEGER,
  word1     TEXT,
  word2     TEXT,
  word3     TEXT,

  FOREIGN KEY ( sender_id ) REFERENCES markov.people ( id )
);

-- }}}

-- vim: set foldmethod=marker expandtab tabstop=2 shiftwidth=2 syntax=sql:

