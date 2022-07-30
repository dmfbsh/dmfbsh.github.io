require 'sqlite3'

def generate_churches_saint(pDBName)

puts "Starting: generate_churches_saint"

db = SQLite3::Database.open pDBName

dstf = "../_data/Shropshire_Notebook-Churches_Saint.yml"
dsth = File.open(dstf, "w:UTF-8")

curr_saint = ''
results = db.query "SELECT name, dedication1 AS dedication, photo FROM GoogleMap WHERE photo IS NOT NULL UNION SELECT name, dedication2 AS dedication, photo FROM GoogleMap WHERE photo IS NOT NULL AND dedication2 IS NOt NULL ORDER BY dedication, name"
results.each { |row|
  if curr_saint != row[1]
    curr_saint = row[1]
    saint_notes = db.query "SELECT body FROM notes WHERE parent_id = 'a3fa9ffc8a54446992cf11a39506a159' AND title = ?", curr_saint
    saint_note = saint_notes.next
    tnotes = ''
    if saint_note
      tnotes = saint_note[0]
    else
      tnotes = 'TBD'
    end
    snotes = ''
    tnotes.each_line do |line|
      snotes = snotes + "    " + line
    end
    dsth.write("- Saint: " + row[1] + "\n") unless dsth.nil?
    dsth.write("  Description: |" + "\n") unless dsth.nil?
    dsth.write(snotes + "\n");
    dsth.write("  Churches: " + "\n") unless dsth.nil?
  end
  dsth.write("  - Church: " + row[0] + "\n") unless dsth.nil?
  dsth.write("    Photo: " + row[2] + "\n") unless dsth.nil?
}

dsth.close unless dsth.nil?

puts "Done: generate_churches_saint"

end
