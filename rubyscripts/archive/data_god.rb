require 'pg'

class DatabaseManager
  # parent class which just connects to a database and stores its name
  attr_accessor :name, :database
  def initialize(db_name)
    self.name = db_name
    self.database = PG.connect(dbname: db_name, user: 'postgres')
  end
end

class DataGod < DatabaseManager
  # creates all the tables we need and also drops all of them quickly
  def setup_database
    self.database.exec(<<~HEREDOC
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
    HEREDOC
    )
  end

  def teardown_database
    puts 'Now then let Me alone, that My anger may burn against them and that I may destroy them...'
    self.database.exec(
      <<~HEREDOC
        DROP TABLE mentions;
        DROP TABLE sources;
        DROP TABLE comments;
        DROP TABLE threads;
        DROP TABLE users;
        DROP TABLE currencies;
      HEREDOC
    )
  end

end
