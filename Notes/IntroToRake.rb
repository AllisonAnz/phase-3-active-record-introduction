# Intro to Rake 

# Introduce Rake and Rake tasks
# Understand what Rake is used for in our Ruby programs
# Learn how to build a basic Rake task

# Rake is a tool that allows us to automate certain jobs 
# anything from execute SQL to putsing out messages in the terminal 

# Rake allows us to define "Rake tasks" that execute these jobs 

# Why Rake
# Every program has some jobs that must be executed now and then 
# like creating a db table, task of making or maintaining certain files 
# Rake provides us a standard, conventional way to define and execute tasks using Ruby 

# How to Define and Use Rake Tasks 
# Rake is already available as part of Ruby 
# Create a file in the top level of the directory called Rakefile 
# Here we define our task 
task :hello do 
    #the code we want to be executed by this task 
end 

# We define tasks with task + name of task as a symbol + a block that contains the code we want to execute 

#If you open up the Rakefile in this directory, you'll see our :hello task:
task :hello do
  puts "hello from Rake!"
end 

# In the terminal type 
rake hello 
#=> hello from Rake!

# Describing our Tasks for reke -T 
# a handy command rake -T, we can run in the terminal to view a list of available Rake tasks 
# and their descriptions. 
# In order for this to work, we need to give our Reake tasks descriptions 
# Give the hello task a description 
desc 'outputs hello to the terminal'
task :hello do
  puts "hello from Rake!"
end 

# type rake -T in the terminal 
#=> rake hello  # outputs hello to the terminal

# Namespacing Rake Tasks 
# We can namespace our Rake tasks 
# namespacing is a way to group or contain something, in this case our Rake tasks 
# we might namespace a series of greeting Reak tasks, like hello under the greeting heading 

# Create another greeting-type Rake task, hola 
desc 'outputs hola to the terminal'
task :hola do
  puts "hola de Rake!"
end 

# And namespace both hello and hola 
namespace :greeting do
desc 'outputs hello to the terminal'
  task :hello do
    puts "hello from Rake!"
  end

  desc 'outputs hola to the terminal'
  task :hola do
    puts "hola de Rake!"
  end
end 

# To use either of our Rake tasks, we use the following syntax:
# rake greeting:hello
#=> hello from Rake!

# rake greeting:hola
#=> hola de Rake! 

#-------------------------------------------------------------------------------
# Common Rake Tasks 
# As we move to developing Sinatra and Rails web applications 
# You'll begin to use some common Rake tasks that handle certain database-related jobs 

# rake db:migrate
# A common pattern you'll become familiar with is the pattern of writing code that creates 
# database tables and then "migrating" that code using a rake task 

# our student class has a #create_table method, so let's use that method to build out our own 
# migrate rake task 
class Student

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]  
  
  attr_accessor :name, :grade
  
  attr_reader :id
  
  def initialize(name, grade, id=nil)
    @id = id
    @name = name
    @grade = grade
  end
  
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


# Namespace this task under the db heading 
# The namespace will contain a few common database-related tasks 

# We'll call this task migrate beacuse it is convention to say we are "migrating" 
# our databse by applying SQL statements that alter that db 
# Put code into Rakefile
namespace :db do
  desc 'migrate changes to your database'
  task :migrate => :environment do
    Student.create_table
  end
end 

# We hit an error if we run rake db:migrate 

# this snippet
task :migrate => :environment do ... 
# crates a task dependency 
# Since our Student.create_table code would require access to the config/environment.rb file (where the student class and db are loaded)
# We need to give our task acess to this file 

# In order to do that, we need to define another Rake task that we can tell to run before the migrate task is fun 
# Check out that environment task 
# in Rakefile
task :environment do
  require_relative './config/environment'
end 

# After adding our environment task, running rake db:migrate should create our students table.

# rake db:seed 
# This task is responsible for "seeding" our db with dummy data 
# The conventional way to seed your db is to have a file in the db directory db/seeds.rb 
# that contains some code to create instances of your class 

# in db/seeds.rb 
Student.create(name: "Melissa", grade: "10th")
Student.create(name: "April", grade: "10th")
Student.create(name: "Luke", grade: "9th")
Student.create(name: "Devon", grade: "11th")
Student.create(name: "Sarah", grade: "10th") 

# Define a rake task that executes this code in this file 
# This taks is also namespaced uner db 
namespace :db do

  ...

  desc 'seed the database with some dummy data'
  task :seed do
    require_relative './db/seeds.rb'
  end
end 


# rake console
# To interact with out class and db without having to run our entire program 
# we can build a Rake task that will load up Pry console for us 

# Define a task that starts up the Pry console 
# Make it dependent on our environment task so that 
# the Student class and the database connection load first 
desc 'drop into the Pry console'
task :console => :environment do
  Pry.start
end 

# Now provided we ran rake db:migrate and rake db:seed, we can type this into the console 
rake console 

# Brings up 
[1] pry(main)> 

# Check to see that we did successfully migrate and seed our db 
[1] pry(main)> Student.all
# => [[1, "Melissa", "10th"],
#     [2, "April", "10th"],
#     [3, "Luke", "9th"],
#     [4, "Devon", "11th"],
#     [5, "Sarah", "10th"]] 
