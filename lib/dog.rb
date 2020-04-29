class Dog
    attr_accessor :id, :name, :breed
    def initialize(props)
        props.each {|key, value| self.send(("#{key}="), value)}
    end

    def save 
        sql = <<-SQL
            INSERT INTO dogs (name, breed) VALUES (?, ?);
        SQL

        res = DB[:conn].execute(sql, self.name, self.breed);
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        self
    end

    def self.create_table 
        sql = <<-SQL
            CREATE TABLE IF NOT EXISTS dogs(
            id INTEGER PRIMARY KEY,
            name TEXT,
            breed TEXT
            );
        SQL

        DB[:conn].execute(sql);
    end

    def self.drop_table
        sql = <<-SQL
            DROP TABLE dogs;
        SQL

        DB[:conn].execute(sql);
    end

    def self.create(props)
        dog = self.new(props)
        dog.save
        dog
    end

    def self.new_from_db(row)
        self.new({:id => row[0], :name => row[1], :breed => row[2]})
    end

    def self.find_by_id(id)
        # find the student in the database given a name
        # return a new instance of the Student class
        sql = <<-SQL
          SELECT * FROM dogs WHERE id = ?;
        SQL
    
        res = DB[:conn].execute(sql, id)
        self.new_from_db(res[0])
    end

    def self.find_or_create_by(name:, breed:)
        dogs = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?;", name, breed)
        if !dogs.empty?
            dog = dogs[0]
            self.new({:id => dog[0], :name => dog[1], :breed => dog[2]})
        else
            dog = self.new({:name => name, :breed => breed})
            dog.save
            dog
        end
    end
    
    def self.find_by_name(name)
        sql = <<-SQL
          SELECT * FROM dogs WHERE name = ?;
        SQL
    
        res = DB[:conn].execute(sql, name)
        self.new_from_db(res[0])
    end

    def update 
        sql = <<-SQL
            UPDATE dogs SET name = ?, breed = ? WHERE id = ?;
          SQL
    
          DB[:conn].execute(sql, self.name, self.breed, self.id)
      end
end