require 'sqlite3'

def generate_churches_status(pDBName)

puts "Starting: generate_churches_status"

db = SQLite3::Database.open pDBName

dstf = "../_data/Shropshire_Notebook-Churches_Status.yml"
dsth = File.open(dstf, "w:UTF-8")

results = db.query "SELECT count(*) FROM exp_churches WHERE status_visited = 1"
first_result = results.next
dsth.write("AllVisited: " + first_result[0].to_s + "\n") unless dsth.nil?

results = db.query "SELECT count(*) FROM exp_churches WHERE status_visited = 0"
first_result = results.next
dsth.write("AllNotVisited: " + first_result[0].to_s + "\n") unless dsth.nil?

results = db.query "SELECT count(*) FROM exp_churches WHERE status_visited = 1 AND status_not_been_inside = 0"
first_result = results.next
dsth.write("AllInside: " + first_result[0].to_s + "\n") unless dsth.nil?

results = db.query "SELECT count(*) FROM exp_churches WHERE status_visited = 1 AND status_not_been_inside = 1"
first_result = results.next
dsth.write("AllNotInside: " + first_result[0].to_s + "\n") unless dsth.nil?

results = db.query "SELECT count(*) FROM exp_churches WHERE status_visit_planned = 1 OR status_visit_planned_priority = 1"
first_result = results.next
dsth.write("AllPlanned: " + first_result[0].to_s + "\n") unless dsth.nil?

results = db.query "SELECT count(*) FROM exp_churches WHERE status_not_yet_visited = 1"
first_result = results.next
dsth.write("AllNotYet: " + first_result[0].to_s + "\n") unless dsth.nil?

results = db.query "SELECT count(*) FROM exp_churches WHERE status_visited = 1 AND status_not_been_inside = 0"
first_result = results.next
dsth.write("Col1Num: " + first_result[0].to_s + "\n") unless dsth.nil?
col1n = first_result[0]

results = db.query "SELECT count(*) FROM exp_churches WHERE status_visited = 1 AND status_not_been_inside = 1"
first_result = results.next
dsth.write("Col2Num: " + first_result[0].to_s + "\n") unless dsth.nil?
col2n = first_result[0]

results = db.query "SELECT count(*) FROM exp_churches WHERE status_visit_planned_priority = 1"
first_result = results.next
dsth.write("Col3Num: " + first_result[0].to_s + "\n") unless dsth.nil?
col3n = first_result[0]

results = db.query "SELECT count(*) FROM exp_churches WHERE status_visit_planned = 1"
first_result = results.next
dsth.write("Col4Num: " + first_result[0].to_s + "\n") unless dsth.nil?
col4n = first_result[0]

results = db.query "SELECT count(*) FROM exp_churches WHERE status_not_yet_visited = 1"
first_result = results.next
dsth.write("Col5Num: " + first_result[0].to_s + "\n") unless dsth.nil?
col5n = first_result[0]

col1 = db.query "SELECT place, dedication, diocese FROM exp_churches WHERE status_visited = 1 AND status_not_been_inside = 0"
col2 = db.query "SELECT place, dedication, diocese FROM exp_churches WHERE status_visited = 1 AND status_not_been_inside = 1"
col3 = db.query "SELECT place, dedication, diocese FROM exp_churches WHERE status_visit_planned_priority = 1"
col4 = db.query "SELECT place, dedication, diocese FROM exp_churches WHERE status_visit_planned = 1"
col5 = db.query "SELECT place, dedication, diocese FROM exp_churches WHERE status_not_yet_visited = 1"

dsth.write("Churches:\n") unless dsth.nil?

maxrows = 0
if col1n > maxrows
  maxrows = col1n
end
if col2n > maxrows
  maxrows = col2n
end
if col3n > maxrows
  maxrows = col3n
end
if col4n > maxrows
  maxrows = col4n
end
if col5n > maxrows
  maxrows = col5n
end

for i in 1..maxrows do
  col1r = col1.next
  if !col1r.nil?
    dsth.write("  - Col1: " + col1r[0] + ", " + col1r[1] + " (" + col1r[2] + ")\n") unless dsth.nil?
  else
    dsth.write("  - Col1: \n") unless dsth.nil?
  end
  col2r = col2.next
  if !col2r.nil?
    dsth.write("    Col2: " + col2r[0] + ", " + col2r[1] + " (" + col2r[2] + ")\n") unless dsth.nil?
  else
    dsth.write("    Col2: \n") unless dsth.nil?
  end
  col3r = col3.next
  if !col3r.nil?
    dsth.write("    Col3: " + col3r[0] + ", " + col3r[1] + " (" + col3r[2] + ")\n") unless dsth.nil?
  else
    dsth.write("    Col3: \n") unless dsth.nil?
  end
  col4r = col4.next
  if !col4r.nil?
    dsth.write("    Col4: " + col4r[0] + ", " + col4r[1] + " (" + col4r[2] + ")\n") unless dsth.nil?
  else
    dsth.write("    Col4: \n") unless dsth.nil?
  end
  col5r = col5.next
  if !col5r.nil?
    dsth.write("    Col5: " + col5r[0] + ", " + col5r[1] + " (" + col5r[2] + ")\n") unless dsth.nil?
  else
    dsth.write("    Col5: \n") unless dsth.nil?
  end
end

results = db.query "SELECT count(*) FROM exp_churches WHERE status_no_inside_photo = 1"
first_result = results.next
dsth.write("RevisitCount2: " + first_result[0].to_s + "\n") unless dsth.nil?

dsth.write("RevisitCount3: 0\n") unless dsth.nil?

results = db.query "SELECT count(*) FROM exp_churches WHERE status_no_inside_photo = 0 AND status_visited = 1 AND status_not_been_inside = 0"
first_result = results.next
dsth.write("RevisitCount4: " + first_result[0].to_s + "\n") unless dsth.nil?

dsth.close unless dsth.nil?

puts "Done: generate_churches_status"

end
