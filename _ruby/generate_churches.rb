require 'sqlite3'

def generate_churches(pDBName)

puts "Starting: generate_churches"

db = SQLite3::Database.open pDBName

=begin
dstf = "../_data_source/Shropshire_Notebook-Churches_TEST.md"
dsth = File.open(dstf, "w:UTF-8")

churches = db.query "SELECT place, dedication, diocese, date, notes, photo, subimages_id, status_no_inside_photo FROM exp_churches WHERE category = 'Church' ORDER BY place"
churches.each { |church|
  dsth.write("# Name: " + church[1] + ", " + church[0] + "\n") unless dsth.nil?
  dsth.write("- Diocese: " + church[2] + "\n") unless dsth.nil?
  dsth.write("- Date: " + church[3] + "\n") unless dsth.nil?
  dsth.write("\n") unless dsth.nil?
  dsth.write(church[4] + "\n") unless dsth.nil?
  if church[7] == 1
    dsth.write("\n") unless dsth.nil?
    dsth.write("Note: Have been inside this church, but do not have any interior photos.\n") unless dsth.nil?
  end
  dsth.write("![](../1shropshire/assets/images/churches/" + church[5] + ")\n") unless dsth.nil?
  query = "SELECT Image FROM SubImage WHERE Photo_ID = " + church[6].to_s + ";"
  subimages = db.query query
  subimages.each { |subimage|
    subimage_name = subimage[0][subimage[0].rindex("\\")+1..subimage[0].rindex(".")] + 'jpg'
    dsth.write("- Sub-Image: " + subimage_name + "\n") unless dsth.nil?
  }
  if church[7] == 1
    dsth.write("- Sub-Image: photo-needed.jpg\n") unless dsth.nil?
  end
  dsth.write("\n") unless dsth.nil?
}

dsth.close unless dsth.nil?
=end

dstf = "../_data/Shropshire_Notebook-Churches.yml"
dsth = File.open(dstf, "w:UTF-8")

churches = db.query "SELECT place, dedication, diocese, date, notes, photo, subimages_id, status_no_inside_photo, grade FROM exp_churches WHERE category = 'Church' ORDER BY place"
churches.each { |church|
  dsth.write("- Type: Item\n")
  dsth.write("  Name: " + church[1] + ", " + church[0] + "\n") unless dsth.nil?
  dsth.write("  Grade: " + church[8] + "\n") unless dsth.nil?
  dsth.write("  Diocese: " + church[2] + "\n") unless dsth.nil?
  dsth.write("  Date: " + church[3] + "\n") unless dsth.nil?
  dsth.write("  Description: |\n") unless dsth.nil?
  lines = church[4].split(/\r?\n/)
  desc = ""
  lines.each { |line|
    if line.length > 0
      desc = desc + "    " + line + "\n"
    else
      desc = desc + "\n"
    end
  }
  dsth.write(desc) unless dsth.nil?
  if church[7] == 1
    dsth.write("\n") unless dsth.nil?
    dsth.write("    Note: Have been inside this church, but do not have any interior photos.\n") unless dsth.nil?
  end
  dsth.write("  Thumbnail: " + church[5] + "\n") unless dsth.nil?
  query = "SELECT Image FROM SubImage WHERE Photo_ID = " + church[6].to_s + ";"
  subimages = db.query query
  firstsi = true
  subimages.each { |subimage|
    if firstsi
      dsth.write("  Sub-Images:\n") unless dsth.nil?
      firstsi = false
    end
    subimage_name = subimage[0][subimage[0].rindex("\\")+1..subimage[0].rindex(".")] + 'jpg'
    dsth.write("    - Sub-Image: " + subimage_name + "\n") unless dsth.nil?
  }
  if church[7] == 1
    dsth.write("  Sub-Images:\n") unless dsth.nil?
    dsth.write("    - Sub-Image: photo-needed.jpg\n") unless dsth.nil?
  end
  dsth.write("\n") unless dsth.nil?
}

dsth.close unless dsth.nil?

puts "Done: generate_churches"

end
