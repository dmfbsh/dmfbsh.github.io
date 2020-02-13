
Dir.glob("../_data_source/*.md") do |srcfn|

  puts "Processing: " + srcfn

  srcf = srcfn
  dstf = "../_data/" + srcfn[15..-4] + ".yml"

  dsth = File.open(dstf, "w:UTF-8")
  
  tmp = ""
  ctype = ""
  simage = "no"

  File.readlines(srcf).each do |line|
    if line.start_with?("<!--")
      tmp = "- " + line[4..-5] + line[-1..-1]
      dsth.write(tmp) unless dsth.nil?
      ctype = line
      simage = "no"
    elsif line.start_with?("# Date:")
      tmp = "  " + line[2..-1]
      dsth.write(tmp) unless dsth.nil?
      if ctype.start_with?("<!--Type: Header")
        tmp = "  Description: |"
        dsth.write(tmp) unless dsth.nil?
      end
    elsif line.start_with?("# Name:")
      tmp = "  " + line[2..-1]
      dsth.write(tmp) unless dsth.nil?
      if ctype.start_with?("<!--Type: Item")
        tmp = "  Description: |"
        dsth.write(tmp) unless dsth.nil?
      end
      if ctype.start_with?("<!--Type: Quote")
        tmp = "  Description: |"
        dsth.write(tmp) unless dsth.nil?
      end
    elsif line.start_with?("![](")
      tmp = "  Thumbnail: " + line[line.rindex("/")+1..-3] + line[-1..-1]
      tmp = tmp.gsub("%20", " ")
      dsth.write(tmp) unless dsth.nil?
    elsif line.start_with?("# Width:")
      tmp = "  " + line[2..-1]
      dsth.write(tmp) unless dsth.nil?
    elsif line.start_with?("# Offset:")
      tmp = "  " + line[2..-1]
      dsth.write(tmp) unless dsth.nil?
    elsif line.start_with?("# Sub-Image:")
      if simage == "no"
        simage = "yes"
        dsth.write("  Sub-Images:\n") unless dsth.nil?
      end
      tmp = "    - " + line[2..-1]
      dsth.write(tmp) unless dsth.nil?
    else
      tmp = line
      if line.length > 1
        tmp = "    " + tmp
      end
      dsth.write(tmp) unless dsth.nil?
    end
  end

  dsth.close unless dsth.nil?

end

puts "Done: convert_md_to_yml"
