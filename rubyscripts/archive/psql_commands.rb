module SearchCommands

  def all_tables
    return <<~HEREDOC
    SELECT table_name
      FROM information_schema.tables
     WHERE table_schema='public'
       AND table_type='BASE TABLE';
    HEREDOC
  end
end

module InputCommands
  def record_user(name)
    return <<~HEREDOC
      INSERT INTO users
        (name)
        VALUES ('#{name}')
        ON CONFLICT (name)
          DO UPDATE
          SET timesSeen = (SELECT timesSeen
            FROM users
           WHERE name = '#{name}') + 1;
    HEREDOC
  end

  def record_source(name)
    return <<~HEREDOC
    INSERT INTO sources
      (name)
      VALUES ('#{name}')
      ON CONFLICT (name)
        DO NOTHING;
    HEREDOC
  end

  def record_thread(title, tag, comments)
    # NOTE: at the moment we're assuming we're only ever going to record each thread once and never update any info about any threads
    return <<~HEREDOC
    INSERT INTO threads
      (title, comments, tag)
      VALUES ($$#{title}$$, #{comments}, '#{tag}')
      ON CONFLICT (title)
        DO NOTHING;
    HEREDOC
  end

  def record_currency(name)
    return <<~HEREDOC
    INSERT INTO currencies
      (name)
      SELECT '#{name}'
      WHERE NOT exists (
      SELECT *
      FROM currencies
      WHERE name = '#{name}');
    HEREDOC
  end

  def record_mention(source, thread, comment, user, currency, time)
    return <<~HEREDOC
    INSERT INTO mentions
      (sourceId, threadId, comment, userId, currencyId, time)
      SELECT  *
      FROM
        (SELECT id FROM sources WHERE name = '#{source}') AS sourceId
      CROSS JOIN
        (SELECT id FROM threads WHERE title = $$#{thread}$$) AS threadId
      CROSS JOIN
        (SELECT #{comment} AS commentyyyy) AS comment
      CROSS JOIN
        (SELECT id FROM users WHERE name = '#{user}') AS userId
      CROSS JOIN
        (SELECT id FROM currencies WHERE name = '#{currency}') AS currencyId
      CROSS JOIN
        (SELECT TIMESTAMP '#{time}' AS time) AS time;
    HEREDOC
  end
end

=begin
Clean User Insertion ------------------------------------------------------
INSERT INTO users (name)
  VALUES ('john24'), ('steve'), ('tom');


INSERT INTO users
  (name)
  VALUES ('john66')
  ON CONFLICT (name)
    DO UPDATE
    SET timesSeen = (SELECT timesSeen
      FROM users
     WHERE name = 'john66') + 1;

Clean source Insertion ------------------------------------------------------

INSERT INTO sources
  (name)
  VALUES ('reddit')
  ON CONFLICT (name)
    DO NOTHING;

Clean thread Insertion ------------------------------------------------------

INSERT INTO threads
  (title, comments, tag)
  VALUES ('WHy bitcoin is terrible asdafasf89ga bnut not vertcoin lulz', 4, 'Announcement')
  ON CONFLICT (title)
    DO NOTHING;

Clean currency Insertion ------------------------------------------------------

INSERT INTO currencies
  (name)
  SELECT 'trashcoin'
  WHERE NOT exists (
  SELECT *
  FROM currencies
  WHERE name = 'trashcoin');

Clean mention Insertion ------------------------------------------------------

INSERT INTO mentions
  (sourceId, threadId, comment, userId, currencyId, time)
  SELECT  *
  FROM
    (SELECT id FROM sources WHERE name = 'reddit') AS sourceId
  CROSS JOIN
    (SELECT id FROM threads WHERE title = 'WHy bitcoin is terrible asdafasf89ga bnut not vertcoin lulz') AS threadId
  CROSS JOIN
    (SELECT false AS comment) AS comment
  CROSS JOIN
    (SELECT id FROM users WHERE name = 'tom') AS userId
  CROSS JOIN
    (SELECT id FROM currencies WHERE name = 'trashcoin') AS currencyId
  CROSS JOIN
    (SELECT now() AS time) AS time;

 graphing ------------------------------------------------------

The idea here would be: in ruby keep running this query with a different timeframe and different names extracting the data untill you have enough x axis values

SELECT name, COUNT(name) AS mentions
  FROM mentions
  JOIN currencies
    ON currencies.id = mentions.currencyId
  WHERE time > '2017-10-21 23:37:13.000444'
  AND name = 'SALT'
  GROUP BY name;

setup------------------------------------------------------

CREATE TABLE currencies(
  id serial,
  name VARCHAR(60) NOT NULL UNIQUE,
  PRIMARY KEY(id)
);

CREATE TABLE users(
  id serial,
  name VARCHAR(30) NOT NULL UNIQUE ,
  timesSeen SMALLINT DEFAULT 1,
  PRIMARY KEY(id)
);

CREATE TABLE threads(
  id serial,
  title VARCHAR(400) NOT NULL UNIQUE,
  tag VARCHAR(40) NOT NULL DEFAULT 'N/A',
  comments SMALLINT NOT NULL DEFAULT 0,
  PRIMARY KEY(id)
);

CREATE TABLE comments(
  id serial,
  points SMALLINT NOT NULL DEFAULT 1,
  PRIMARY KEY(id)
);


CREATE TABLE sources(
  id serial,
  name VARCHAR(40) NOT NULL UNIQUE,
  PRIMARY KEY(id)
);

CREATE TABLE mentions(
  id serial,
  currencyId INTEGER REFERENCES currencies (id) ON DELETE CASCADE,
  sourceId INTEGER REFERENCES sources (id) ON DELETE CASCADE,
  userId INTEGER REFERENCES users (id) ON DELETE CASCADE,
  threadId INTEGER REFERENCES threads (id) ON DELETE CASCADE,
  comment BOOLEAN NOT NULL DEFAULT false,
  time TIMESTAMP NOT NULL,
  PRIMARY KEY(id)
);

teardown------------------------------------------------------

DROP TABLE mentions;
DROP TABLE sources;
DROP TABLE comments;
DROP TABLE threads;
DROP TABLE users;
DROP TABLE currencies;
=end
