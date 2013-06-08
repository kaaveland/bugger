require 'sqlite3'

module BuggerDB

  class DatabaseAccess

    def initialize(connection_string)
      @db = SQLite3::Database.new(connection_string)
      @db.results_as_hash = true
    end

    def prepare_schema
      @db.execute(task_sql)
      @db.execute(time_spent_sql)
    end

    def task_sql
      "CREATE TABLE TASK (" +
        "TASK_ID INTEGER PRIMARY KEY," +
        "NAME VARCHAR NOT NULL," +
        "DESCRIPTION VARCHAR);"
    end

    def time_spent_sql
      "CREATE TABLE TASK_TIME (" +
        "TASK_TIME INTEGER PRIMARY KEY," +
        "START INTEGER NOT NULL," +
        "STOP INTEGER," +
        "LAST_UPDATE INTEGER," +
        "TASK_ID INTEGER," +
        "FOREIGN KEY(TASK_ID) REFERENCES TASK(TASK_ID));"
    end

    def execute(sql, parameters)
      @db.execute(sql, parameters)
    end

    def insert(sql, parameters)
      execute(sql, parameters)
      @db.last_insert_row_id
    end
  end

  class Task
    attr_reader :id
    attr_accessor :name, :description

    def initialize(id, name, description)
      @id = id
      @name = name
      @description = description
    end

    def to_s
      "Task(#{@id}, #{@name}, #{@description})"
    end

  end

  class Tasks

    def initialize(database)
      @database = database
    end

    def from_row(row)
      Task.new(row["TASK_ID"], row["NAME"], row["DESCRIPTION"])
    end

    def by_name(name)
      rows = @database.execute("SELECT * FROM TASK WHERE NAME=?", name)
      if rows.empty?
        create(name)
      else
        from_row(rows.first)
      end
    end

    def by_id(id)
      rows = @database.execute("SELECT * FROM TASK WHERE TASK_ID=?", id)
      if rows.empty?
        nil
      else
        from_row(rows.first)
      end
    end

    def create(name, description=nil)
      id = @database.insert("INSERT INTO TASK(name, description) VALUES(?, ?)",
                            name, description)
      Task.new(id, name, description)
    end

    def save(task)
      if task.id.nil?
        create(task.name, task.description)
      else
        @database.execute("UPDATE TASK SET NAME = ?, DESCRIPTION = ? WHERE TASK_ID = ?",
                          task.name, task.description, task.id)
        task
      end
    end

    def all
      rows = @database.execute("SELECT * FROM TASK")
      rows.map do | row |
        from_row(row)
      end
    end
  end

end
