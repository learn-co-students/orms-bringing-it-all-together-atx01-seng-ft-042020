require "pry"
class Dog
    attr_accessor :name, :breed
    attr_reader :id
    def initialize(id: nil, name:, breed:)
        @id = id
        @name = name
        @breed = breed
    end

    def save
        if @id
            self.update
        else
            sql = <<-SQL 
                INSERT INTO dogs(name, breed)
                VALUES(?,?)
            SQL
            DB[:conn].execute(sql, @name, @breed)
            @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs LIMIT 1")[0][0]
        end
        self
    end

    def update
        sql = <<-SQL 
            UPDATE dogs SET name=?, breed=? WHERE id=?
        SQL
        DB[:conn].execute(sql, @name, @breed, @id)
    end

    def self.create(name:, breed:)
        self.new(name: name, breed: breed).save
    end


    def self.create_table
        sql = <<-SQL 
            CREATE TABLE IF NOT EXISTS dogs(
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

    def self.new_from_db(row)
        self.new(id: row[0], name: row[1], breed: row[2])
    end

    def self.find_by_name(name)
        sql = <<-SQL 
            SELECT * FROM dogs WHERE name=? LIMIT 1
        SQL
        new_from_db( DB[:conn].execute(sql, name).first)
    end

    def self.find_by_id(id)
        sql = <<-SQL 
            SELECT * FROM dogs WHERE id=? LIMIT 1
        SQL
        new_from_db( DB[:conn].execute(sql, id).first)
    end

    def self.find_or_create_by(name:, breed:)
        sql = <<-SQL 
            SELECT * FROM dogs WHERE name=? AND breed=?
        SQL
        dog = DB[:conn].execute(sql, name, breed)
        if !dog.empty?
            new_from_db(dog[0])
        else
            create(name: name, breed: breed)
        end
    end


end
