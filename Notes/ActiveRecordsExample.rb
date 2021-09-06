# Link: https://github.com/AllisonAnz/phase-3-active-record-translating-from-orm-to-ar

config/environment.rb
ENV["RACK_ENV"] ||= "development"

require 'bundler/setup'
Bundler.require(:default, ENV["RACK_ENV"])
require 'active_record'
require_relative '../lib/dog'

# Tells ActiveRecord where the database is located 
# Once eastablish_connection is ran, ActiveRecord::Base keeps it stored as a class 
# variable at ActiveRecord::Base.connection
ActiveRecord::Base.establish_connection(
  # adapter tells ActiveRecord which SQL software to use
  adapter: "sqlite3",
  # database tells ActiveRecord where the db is
  database: "./db/test.sqlite3"
)

--------------------------------------------------------------------------------
class Dog < ActiveRecord::Base

# All the below methods are provided by ActiveRecord, so you don't need to code for them!
# inheritence: inherits from ActiveRecord::Base
# attributes: has a name and a breed
# .create: takes in a hash of attributes and uses metaprogramming to create a new dog object. Then it uses the #save method to save that dog to the database
# .save: saves an instance of the dog class to the database and then sets the given dogs `id` attribute
# .update: updates the record associated with a given instance
# .find_or_create_by: creates a dog if it does not already exist
# .find_by_name: returns a dog that matches the name from the DB
# .find_by_id: returns a dog that matches the name from the DB

end
-------------------------------------------------------------------------------
#!/usr/bin/env ruby 
require 'sqlite3'
require_relative "../config/environment.rb"

# Create a table 
# Create a table to hold students 
sql = <<-SQL
  CREATE TABLE IF NOT EXISTS dogs (
  id INTEGER PRIMARY KEY,
  name TEXT, 
  breed TEXT
  )
SQL

# Remember, the previous step has to run first so that `connection` is set!
ActiveRecord::Base.connection.execute(sql) 

dog = Dog.find_or_create_by(name: "Teddy", breed: "Cockapoo")
p dog.name
#=> Teddy

Dog.find_or_create_by(name: "Ralph", breed: "lab")
ralph = Dog.find_by(name: "Ralph")
p ralph.name
#=> Ralph

# ruby bin/run
