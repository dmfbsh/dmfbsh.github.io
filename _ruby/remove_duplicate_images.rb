
Dir.glob("../assets/images/history/*.jpg") do |srcfn|

  if srcfn.match(".*_[1-9]\\.jpg")
    puts "Processing: " + srcfn
    delfl = srcfn[0..-7] + ".jpg"
    puts "Deleting: " + delfl
    File.delete(delfl) if File.exist?(delfl)
    puts "Renaming: " + srcfn + " TO " + delfl
    File.rename(srcfn, delfl)
  end

end

puts "Done: remove_duplicate_images"
