require_relative "../config/environment.rb"
require 'pry'

class Student
  attr_accessor :name, :grade, :id
  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]
  def initialize(name, grade, id = nil)
    @name = name
    @grade = grade
    @id = id
  end


  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS students (
        id INTEGER PRIMARY KEY,
        name TEXT,
        grade TEXT
      )
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE IF EXISTS students
    SQL
    DB[:conn].execute(sql)
  end

  def save
    if self.id
      self.update
    else
      sql = "INSERT INTO students (name, grade) VALUES (?, ?)"
      DB[:conn].execute(sql, @name, @grade)
      @id = DB[:conn].execute('SELECT last_insert_rowid() FROM students')[0][0]
    end
  end

  def self.create(name, grade)
    student = self.new(name, grade)
    student.save
    student
  end


  def self.new_from_db(row)
    id = row[0]
    name = row[1]
    grade = row[2]

    self.new(name, grade, id)
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM students WHERE name = ?"

    record = DB[:conn].execute(sql, name)[0]
    self.new_from_db(record)
  end

  def update
    sql = "UPDATE students SET name = ?, grade = ?, id = ?"
    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end

end
