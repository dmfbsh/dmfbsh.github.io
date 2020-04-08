
cl = Dir.glob("../1shropshire/assets/images/churches/20*.jpg")
hl = Dir.glob("../1shropshire/assets/images/history/20*.jpg")
ll = Dir.glob("../1shropshire/assets/images/landscape/20*.jpg")
ml = Dir.glob("../1shropshire/assets/images/miscellaneous/20*.jpg")
pl = Dir.glob("../1shropshire/assets/images/places/20*.jpg")
gl = Dir.glob("../1shropshire/assets/images/gardens/20*.jpg")

fl = cl + hl + ll + ml + pl + gl
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
  mf = mi[mi.index("#")+1, 100] + "/" + mi[0..mi.index("#")-1]
  if cnt < 80
    dsth.write("- Type: Item\n")
    dsth.write("  Thumbnail: " + mf + "\n\n")
  end
  cnt = cnt + 1
}

dsth.close unless dsth.nil?

puts "Done: generate_recents"
