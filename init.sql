ATTACH DATABASE '%(home_folder)s/.Skype/%(skype_username)s/main.db' AS skype;

-- Create the tables that cache data from Skype {{{

CREATE TABLE IF NOT EXISTS people (
  id        INTEGER PRIMARY KEY AUTOINCREMENT,
  skypename TEXT,
  fullname  TEXT
);

CREATE TABLE IF NOT EXISTS chatlog_raw (
  sender_id    INTEGER,
  message_body TEXT UNIQUE ON CONFLICT IGNORE,
  -- TODO: chat_id TEXT

  FOREIGN KEY ( sender_id ) REFERENCES people ( id )
);

-- }}}

-- Insert the Skype chatlog data into those tables {{{

INSERT INTO people ( skypename, fullname )
  SELECT a.skypename, a.fullname FROM skype.Accounts AS a
  -- make sure we don't get anyone who's never said anything
  INNER JOIN skype.Messages AS m
    ON a.skypename = m.author
;

INSERT INTO chatlog_raw ( sender_id, message_body )
  SELECT p.id, m.body_xml FROM skype.Messages AS m
  JOIN people AS p
    ON m.author = p.skypename
;

-- }}}

-- Create data structure schemas {{{

-- NOTE: split source two words (w1, w2) and third word into seperate column so we can
--       have easier joins

CREATE TABLE IF NOT EXISTS chain_stems (
  id         INTEGER PRIMARY KEY AUTOINCREMENT,
  sender_id  INTEGER,
  word1      TEXT,
  word2      TEXT,

  FOREIGN KEY ( sender_id ) REFERENCES people ( id ),
  UNIQUE ( word1, word2 )
);

CREATE TABLE IF NOT EXISTS chain_words (
  stem_id     INTEGER,
  word        TEXT,
  probability INTEGER NOT NULL DEFAULT 1,

  FOREIGN KEY ( stem_id ) REFERENCES chain_stems ( id )
);

-- }}}

-- vim: set foldmethod=marker expandtab tabstop=2 shiftwidth=2 syntax=sql:

