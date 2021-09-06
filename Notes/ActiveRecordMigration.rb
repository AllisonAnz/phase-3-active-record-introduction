# Active Record Migrations
# Create, connect to, and manipulate a SQLite database using Active Record

# Using activerecord gem create a mapping between our db and modle 
# Migrations are a convenient way for you to alter your db in a structured and organized manner
# Migration allows you to describe transformations using Ruby
# You might create a table, add some data to it, and the make some changes later on 
# adding new Migrations for each change you make, you wont loose any data you don't want to 
# Executed migrations are tracked by ActiveRecord in your database so that they aren't used twice
# Using the migrations system to apply the schema changes is easier than keeping track of the changes 
# manually and executing them manually at the appropriate time.

# Setting Up Your Migration 
# 1. Create a directory called db, and create a migrate directory (db/migrate)
# 2. in here create a file 01_create_artists.rb
# Add in the migration code in this file 
# db/migrate/01_create_artists.rb
class CreateArtists < ActiveRecord::Migration[5.2]
  def up
  end

  def down
  end
end 

# Important: Active Rocord is primarily used in Rails applications, as of Active Record 5.x, we must 
# speicify which version of Rails the migration was written for 
# The lesson was orginally created with gem version that support Rails 4.2 
# So we need to make our CreateArtist migration inherit from ActiveRecord::Migration[4.2]

# Active Record Migration Methods: up, down, change 
# We're creating a class called CreateArtists that inherits from ActiveRecords ActiveRecord::Migration module
# Within the class we have an up method to define the code to execute when the mirgration runs 
# a down method to define the code to execute when the migration is rolled back 
# Think of it "do" and "undo"

# Another method change is more common for basic migrations

#----------------------------------------------------------------------------------------------------
# Creating a Table
# Take a look at how to finsih off our CreateArtists migration, which will generate our artist table with the appropriate columns

# Below is how we were creating tables
# connect to a db, then write the SQL to create the table 
# Connect to db 
ActiveRecord::Base.establish_connection(
  :adapter => "sqlite3",
  :database => "db/artists.sqlite"
) 

# some SQL to create the table 
sql = <<-SQL
  CREATE TABLE IF NOT EXISTS artists (
  id INTEGER PRIMARY KEY,
  name TEXT,
  genre TEXT,
  age INTEGER,
  hometown TEXT
  )
SQL
ActiveRecord::Base.connection.execute(sql) 

#----Using Migration-----------
# We still need to establish Active Records connection to the bd 
# bbut we no longer need the SQL 
# Instead of dealing with SQl directly, we provide 
# the migration we want and Active Records takes care of creating it 
# We still need to connect to the db, make the connection
# config/environment.rb
require 'rake'
require 'active_record'
require 'yaml/store'
require 'ostruct'
require 'date'

require 'bundler/setup'
Bundler.require

# put the code to connect to the database here
ActiveRecord::Base.establish_connection(
  :adapter => "sqlite3",
  :database => "db/artists.sqlite"
)

require_relative "../artist.rb" 

# With the connection to the db configured 
# We have access to ActiveRecord::Migration, and can create tables using only Ruby!
# db/migrate/01_create_artists.rb
def change
  create_table :artists do |t|
  end
end 
# We've added a create_table method and passed the name of the table we want to create as a symbol 

# We can also use other methods like remove_table, rename_table, remove_column, add_column 
http://guides.rubyonrails.org/migrations.html#writing-a-migration

# add some columns 
class CreateArtists < ActiveRecord::Migration[4.2]
  def change
    create_table :artists do |t|
      t.string :name
      t.string :genre
      t.integer :age
      t.string :hometown
    end
  end
end 
# On the left we've given the data type we'd like to cast the column as
# On the firght we've given the name we'd like to give the column 
# We are only missing the primary key 
# Active Record will generate the primary key column for us 
# and for each row added, a key will be auto-incremented

# Running Migration 
# The simplest way to run our migration through a Rake Task 
# That we're given through the activerecord gem 

# We access these by...
# Run rake -T to see the list of commands we have 

# If an error occurs run bundle exec rake -T 
# Adding bundle exec indicates that you want rake to run with the context of this lessions bundle 
# bundle exec rake db:migrate if rake db:migrate doesn't work

# run  rake db:migrate
== 1 CreateArtists: migrating =================================================
-- create_table(:artists, {:id=>:integer})
   -> 0.0018s
== 1 CreateArtists: migrated (0.0020s) ========================================

# Extend the artist.rb class with ActiveRecord::Base 
# artist.rb
class Artist < ActiveRecord::Base
end 

# Test the class using rake console (or bundle exec rake console)
#rake console
# [1] pry(main)> Artist
#=> Artist (call 'Artist.connection' to establish a connection) 

# view the columns in its corresponding table in the db 
Artist.column_names
# => ["id", "name", "genre", "age", "hometown"] 

# Instantiate a new Artist named Jon and save him 
a = Artist.new(name: 'Jon')
# => #<Artist id: nil, name: "Jon", genre: nil, age: nil, hometown: nil>

a.age = 30
# => 30

a.save
# => true 

# The .new method creates a new instance in memory, but for that instance to persist 
# We need to save it 
# If we want to create a new instance and save it we use .create 
Artist.create(name: 'Kelly')
# => #<Artist id: 2, name: "Kelly", genre: nil, age: nil, hometown: nil> 

Artist.all
# => [#<Artist id: 1, name: "Jon", genre: nil, age: 30, hometown: nil>,
 #<Artist id: 2, name: "Kelly", genre: nil, age: nil, hometown: nil>] 

 # Find an Artist by name
 Artist.find_by(name: 'Jon')
# => #<Artist id: 1, name: "Jon", genre: nil, age: 30, hometown: nil> 

#----------------------------------------------------------------------------------------------------------------------
# Using Migration To Manupulate Existing Tables 
# add a favorite_food column to our artist table 
# Remember Active Records keeps tack of the migration we've already run 
# so adding the new code to our 01_create_artist.rb file wont work 
# Since we aren't rolling back our previous migration(or dripping the entire table)
# The 01_create_artist.rb migration wont be re-exectued when we run rake db:migration 

# Best practice for database management is creating new migrations to modify 
# existings tables 
# that way there is a clear linear record of all of the changes that led to our current db 
# We need a new migration 
# 02_add_favorite_food_to_artists.rb
# db/migrate/02_add_favorite_food_to_artists.rb

class AddFavoriteFoodToArtists < ActiveRecord::Migration[4.2]
  def change
    add_column :artists, :favorite_food, :string
  end
end 
# We told active records to add a column to the artist table called favorite_food
# run rake:db migrate again and this column will be added

# To undo a change 
# roll back the first migration

#Then drop back into the console to double check:
Artist.column_names
# => ["id", "name", "genre", "age", "hometown"] 