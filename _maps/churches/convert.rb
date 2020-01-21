
fi = File.open("C:/Users/David/Documents/OneDrive/Documents/My Documents/3. Shropshire/Maps - Churches/Churches.csv", "r")
fo = File.open("C:/Users/David/Documents/OneDrive/Documents/My Documents/3. Shropshire/Maps - Churches/Shropshire - Churches.gpx", "w:UTF-8")

fo.write("<?xml version=\"1.0\"?>\n") unless fo.nil?
fo.write("<gpx>\n") unless fo.nil?

fi.each_line { |line|

  fields = line.split(',')
  wpt = "<wpt lat=\"" + fields[0].strip + "\" lon=\"" + fields[1].strip + "\">\n"
  fo.write(wpt)
  fo.write("<name>" + fields[2].strip + "</name>\n")
  fo.write("<sym>" + fields[3].strip + "</sym>\n")
  fo.write("</wpt>\n")

}

fi.close
fo.write("</gpx>\n") unless fo.nil?
fo.close
