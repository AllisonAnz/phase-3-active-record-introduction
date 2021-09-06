# https://github.com/AllisonAnz/phase-3-active-record-intro-to-rake
# config/environment.rb
require 'bundler/setup'
Bundler.require
#require 'sqlite3'
require_relative "../lib/student"

DB = { conn: SQLite3::Database.new("db/students.db") }
# --------------------------------------------------------------------------------
# db/seed.rb
#require_relative "../lib/student.rb"

Student.create(name: "Melissa", grade: "10th")
Student.create(name: "April", grade: "10th")
Student.create(name: "Luke", grade: "9th")
Student.create(name: "Devon", grade: "11th")
Student.create(name: "Sarah", grade: "10th")
# --------------------------------------------------------------------------------
# Rakefile 
# define task with task + name of task as a symbol + block that contains the code to execute
# namespace: a way to group or contain something (in this case Rake tasks)
namespace :greeting do
  desc 'outputs hello to the terminal'
  task :hello do
    puts "hello from Rake!"
  end # rake greeting:hello #=> hello from Rake!
  
desc 'outputs hola to the terminal'
  task :hola do
    puts "hola de Rake!"
  end # rake greeting:hola #=> hola de Rake!
end

namespace :db do
  # pattern of writing code that creates db tables & "migrating" that code using rake
  desc 'migrate changes to your database'
  # Our Student.create_table requires access to the config/environment.rb file 
  # (where the student class and db are loaded)
  # give the task access to this file using task.environment
  task migrate: :environment do
    Student.create_table
  End #rake db:migrate => creates a student.db file

  # "seeding" our db with some dummy data
  desc 'seed the database with some dummy data'
  task seed: :environment do
    require_relative './db/seeds'
  end # rake db:seed (after running db:migrate)  #=> now the db has data!
end

# required to run rake db:mirgrate: gives the migrate task access to the student.rb file
task :environment do
  require_relative './config/environment'
end

# Starts up the Pry console 
# Make dependent on envirionment task so that the Student class & the db connection load first
desc 'drop into the Pry console'
task console: :environment do
  Pry.start
End # rake console  #=> [1] pry(main)>
# Check to see if we successfully migrated and seed our db 
# [1] pry(main)> Student.all
# => [[1, "Melissa", "10th"], # [2, "April", "10th"], #  [3, "Luke", "9th"],…
# -------------------------------------------------------------------------------
# lib/student.rb
class Student
  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]  
  attr_accessor :name, :grade
  attr_reader :id
  def initialize(name, grade, id=nil)
    @id = id
    @name = name
    @grade = grade
  End

  def self.create_table
    sql =  <<-SQL 
      CREATE TABLE IF NOT EXISTS students (
        id INTEGER PRIMARY KEY, 
        name TEXT, 
        grade TEXT
        )
    SQL
    DB[:conn].execute(sql) 
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS students"
    DB[:conn].execute(sql) 
  end
  
  def save
    sql = <<-SQL
      INSERT INTO students (name, grade) 
      VALUES (?, ?)
    SQL
    DB[:conn].execute(sql, self.name, self.grade)
  end

  def self.create(name:, grade:)
    student = Student.new(name, grade)
    student.save
  end

  def self.all
    sql = "SELECT * FROM students" 
    DB[:conn].execute(sql)
  end
end

