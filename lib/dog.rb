require "pry"

class Dog
    attr_accessor :name, :breed
    attr_reader :id

    def initialize(name:, breed:, id: nil)
        @name = name
        @breed = breed
        @id = id
    end

    def self.create_table
        sql = <<-SQL
        CREATE TABLE IF NOT EXISTS dogs (
            id INTEGER PRIMARY KEY, 
            name TEXT, 
            breed TEXT
        )
        SQL

        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = <<-SQL
            DROP TABLE dogs
        SQL

        DB[:conn].execute(sql)
    end

    def save(name: name, breed: breed, id: id)
        if self.id
            self.update
        else
        sql = <<-SQL
            INSERT INTO dogs (name, breed)
            VALUES (?, ?)
        SQL
        DB[:conn].execute(sql, self.name, self.breed)
        end 

        new_dog = Dog.new(name: name, breed: breed, id: id)
        new_dog
    end

    def self.create(name: name, breed: breed, id: id)
        new_dog = Dog.new(name: name, breed: breed, id: id)
        new_dog.save
        new_dog
    end

    def self.new_from_db(row)
        id = row[0]
        name = row[1]
        breed = row[2]
        Dog.new(id: id, name: name, breed: breed)
    end

    def self.find_by_id(id)
        sql = "SELECT * FROM dogs WHERE id = ?"
        result = DB[:conn].execute(sql, id)[0]
        Dog.new(id: result[0], name: result[1], breed: result[2])
    end

    def self.find_or_create_by(name: name, breed: breed)
        dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
        
        if !dog.empty?
            dog_info = dog[0]
            dog = self.new(dog_info[0], dog_info[1], dog_info[2])
        else
            dog = self.create(name: name, breed: breed)
        end
        dog
        
    end 
end
