def generate_recents()

puts "Starting: generate_recents"

clp = Dir.glob("../1shropshire/assets/images/churches/20*.jpg")
hlp = Dir.glob("../1shropshire/assets/images/history/20*.jpg")
llp = Dir.glob("../1shropshire/assets/images/landscape/20*.jpg")
mlp = Dir.glob("../1shropshire/assets/images/other/20*.jpg")
plp = Dir.glob("../1shropshire/assets/images/places/20*.jpg")
glp = Dir.glob("../1shropshire/assets/images/gardens/20*.jpg")
flp = Dir.glob("../1shropshire/assets/images/folklore/20*.jpg")

fl = clp + hlp + llp + mlp + plp + glp + flp
gl = Array.new

fl.each { |ni|
  nf = ni[ni.rindex("/")+1, 100] + "#" + ni[29..ni.rindex("/")-1]
  gl.push(nf)
}

gl = gl.sort { |a, b| b <=> a}

dstf = "../_data/Shropshire_Notebook-Recent.yml"
dsth = File.open(dstf, "w")

cnt = 0

gl.each { |mi|
  puts "Including: " + mi[0..mi.index("#")-1]
  mf = mi[mi.index("#")+1, 100] + "/" + mi[0..mi.index("#")-1]
  if cnt < 80
    dsth.write("- Type: Item\n")
    dsth.write("  Thumbnail: " + mf + "\n\n")
  end
  cnt = cnt + 1
}

dsth.close unless dsth.nil?

puts "Done: generate_recents"

end
