class Dog
  attr_accessor :name, :breed
  attr_reader :id

  def initialize(dog_hash)
    @name = dog_hash[:name]
    @breed = dog_hash[:breed]
    @id = dog_hash[:id]
  end

  def self.create_table
    DB[:conn].execute("DROP TABLE IF EXISTS dogs")
    sql = <<-SQL
      CREATE TABLE dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT)
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE dogs")
  end

  def self.new_from_db(row)
    dog_hash = {}
    dog_hash[:name] = row[1]
    dog_hash[:breed] = row[2]
    dog_hash[:id] = row[0]
    Dog.new(dog_hash)
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ?
    SQL
    row = DB[:conn].execute(sql, name)[0]
    self.new_from_db(row)
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs WHERE id = ?
    SQL
    row = DB[:conn].execute(sql, id)[0]
    self.new_from_db(row)
  end

  def save
    sql = <<-SQL
      INSERT INTO dogs (name, breed) VALUES (?, ?)
    SQL
    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT id FROM dogs ORDER BY id DESC LIMIT 1")[0][0]
    self
  end

  def self.create(dog_hash)
    dog = Dog.new(dog_hash)
    dog.save
    dog
  end

  def self.find_or_create_by(dog_hash)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ? AND breed = ?
    SQL
    row = DB[:conn].execute(sql, dog_hash[:name], dog_hash[:breed])
    if row.empty?
      dog = self.create(dog_hash)
    else
      dog_data = row[0]
      dog = self.new_from_db(dog_data)
      dog.update
      dog
    end
    dog
  end

  def update
    sql = <<-SQL
    UPDATE dogs
    SET name = ?, breed = ?
    WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end




end
