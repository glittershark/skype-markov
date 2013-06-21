import sqlite3

def triples(words):
  """ Generates triples from the given data string. So if our string were
      "What a lovely day", we'd generate (What, a, lovely) and then
      (a, lovely, day).
  """

  if len(words) < 3:
    return

  for i in range(len(words) - 2):
    yield (words[i], words[i+1], words[i+2])

def get_random_seed_pair(conn):
  c = conn.cursor()
  c.execute("""SELECT word1, word2
               FROM chain_stems
               JOIN people
                 ON chain_stems.sender_id = people.id
--               WHERE skypename = ?
               ORDER BY RANDOM()
               LIMIT 1""") #, (username,))
  return c.fetchone()

def generate(username, num_words, db_file="./markov.db"):
  conn = sqlite3.connect(db_file)
  w1, w2 = get_random_seed_pair(conn)

  gen_words = []
  for i in xrange(num_words):
    gen_words.append(w1)
    c2 = conn.cursor()
    c2.execute("""SELECT word
                 FROM chain_stems
                 JOIN chain_words
                   ON chain_stems.id   = chain_words.stem_id
--                 JOIN people
--                   ON chain_stems.sender_id = people.id
                 WHERE lower(word1) = lower(?)
                   AND lower(word2) = lower(?)
--                   AND skypename  = ?
                 ORDER BY RANDOM() * probability DESC
                 LIMIT 1;""",
                 (w1, w2)) #, username))
    row = c2.fetchone()
    if row is not None:
      w1 = w2
      w2 = row[0]
    else:
      return ' '.join(gen_words)
  gen_words.append(w2)
  return ' '.join(gen_words)

def load_from_skype(home_folder, skype_username, db_file="./markov.db", do_initial_load=True):
  conn = sqlite3.connect(db_file)
  conn.row_factory = sqlite3.Row

  try:
    ## Initialize the database and load the initial data from Skype
    if do_initial_load:
      with open("./init.sql", 'r') as f:
        conn.executescript(f.read() % {"home_folder": home_folder, "skype_username": skype_username})

    ## Go through all the messages...
    for row in conn.execute('SELECT sender_id, message_body FROM main.chatlog_raw'):
      if row['message_body'] is None:
        continue
      ## Split the message into words
      words = row['message_body'].split()
      for triple in triples(words):
        ## Test if we already have these stem words
        #c = conn.cursor()
        #if len(c.execute("""
            #SELECT 1 FROM main.chain_stems as cs
                #WHERE cs.word1     = ?
                #AND   cs.word2     = ?
                #AND   cs.sender_id = ?""",
                #(triple[0], triple[1], row["sender_id"])).fetchall()) == 0:
        try:
          c2 = conn.cursor()
          c2.execute("""INSERT INTO chain_stems (word1, word2, sender_id) VALUES (?, ?, ?)""",
              (triple[0], triple[1], row["sender_id"]))
          conn.execute("""INSERT INTO chain_words (stem_id, word) VALUES (?, ?)""",
              (c2.lastrowid, triple[2]))
        except sqlite3.IntegrityError:
          conn.execute("""UPDATE main.chain_words SET probability = probability + 1
              WHERE word = ?""", (triple[2],))
  finally:
    conn.commit()

def get_random_username(db_file="./markov.db"):
  pass
  conn = sqlite3.connect(db_file)
  c = conn.cursor()
  c.execute("""SELECT skypename FROM people
             ORDER BY RANDOM()
             LIMIT 1""")
  return c.fetchone()[0]


if __name__ == "__main__":
  #import argparse
  #parser = argparse.ArgumentParser()
  #parser.add_argument("command", help="[load|generate]")
  #args = parser.parse_args()

  #load_from_skype("/home/smith", "wildgriffin45", do_initial_load=True)
  for i in xrange(50):
    print generate(None, 400)

