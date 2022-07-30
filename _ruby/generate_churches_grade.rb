require 'sqlite3'

def generate_churches_grade(pDBName)

puts "Starting: generate_churches_grade"

db = SQLite3::Database.open pDBName

dstf = "../_data/Shropshire_Notebook-Churches_Grade.yml"
dsth = File.open(dstf, "w:UTF-8")

curr_grade = ''
results = db.query "SELECT name, grade, photo FROM GoogleMap WHERE photo IS NOT NULL ORDER By grade, name"
results.each { |row|
  if curr_grade != row[1]
    curr_grade = row[1]
    dsth.write("- Grade: " + row[1] + "\n") unless dsth.nil?
    dsth.write("  Churches: " + "\n") unless dsth.nil?
  end
  dsth.write("  - Church: " + row[0] + "\n") unless dsth.nil?
  dsth.write("    Photo: " + row[2] + "\n") unless dsth.nil?
}

dsth.close unless dsth.nil?

puts "Done: generate_churches_grade"

end
