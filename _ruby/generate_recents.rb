
hl = Dir.glob("../assets/images/history/2019*.jpg")
ll = Dir.glob("../assets/images/landscape/2019*.jpg")
ml = Dir.glob("../assets/images/miscellaneous/2019*.jpg")

fl = hl + ll + ml
gl = Array.new

fl.each { |ni|
  nf = ni[ni.rindex("/")+1, 100] + "#" + ni[16..ni.rindex("/")-1]
  gl.push(nf)
}

gl = gl.sort { |a, b| b <=> a}

dstf = "../_data/recent.yml"
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
