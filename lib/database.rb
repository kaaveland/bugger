#! /usr/bin/env ruby

require 'SQLite3'
require 'date'

require_relative '../config/config'

class BuggerDB
	def initialize()
		@db = SQLite3::Database.new(CONFIG['bugger_db'])
        @db.results_as_hash = true
        puts CONFIG['bugger_db'] + sex
	end

    def create_empty_db()
        sql_task = "create table 
            task (
                task_id INTEGER PRIMARY KEY,
                name VARCHAR,
                description VARCHAR
            );"
        sql_time_spent = "create table 
            time_spent (
                time_id INTEGER PRIMARY KEY, 
                time_start DATETIME, 
                time_stop DATETIME,
                last_update DATETIME,
                task_id INTEGER, 
                FOREIGN KEY(task_id) REFERENCES task(task_id)
            );"

        @db.execute(sql_task)
        @db.execute(sql_time_spent)
    end

    def execute(sql, parameters)
        puts sql
        result = @db.execute(sql, parameters)
        if result.empty?
            @db.last_insert_row_id
        else
            result
        end
    end

end