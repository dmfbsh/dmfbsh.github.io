import subprocess
import os
import re
import shutil

IntelliJ  = "C:\\Users\\David\\Documents\\OneDrive\\Documents\\My Documents\\Java-IntelliJ"
exepath   = f"{IntelliJ}\\Obsidian Notebook\\src"
classpath = f"{IntelliJ}\\lib\\commons-cli-1.11.0.jar;{IntelliJ}\\lib\\commons-io-2.22.0.jar;{IntelliJ}\\lib\\log4j-api-2.12.4.jar;{IntelliJ}\\lib\\log4j-core-2.12.4.jar"

Obsidian         = "C:\\Users\\David\\Documents\\NoneDrive\\Obsidian\\Notebook"
database         = f"{Obsidian}\\Churches - Database"
article          = f"{Obsidian}\\Churches - Notebook\\7. History - Main Article.md"
featuredChurches = f"{Obsidian}\\Churches - Notebook\\7. History - Featured Churches.md"
featuredItems    = f"{Obsidian}\\Churches - Notebook\\7. History - Featured Items.md"
subImagesCSV     = f"{Obsidian}\\Churches - Files\\Churches-SubImages.csv"

GitHub   = "C:\\Users\\David\\Documents\\NoneDrive\\GitHub\\dmfbsh.github.io\\churches"
template = f"{GitHub}\\template.html"

mapEmpty   = f"{GitHub}\\images\\Visited_Map_Empty.png";
mapVisited = f"{GitHub}\\images\\Visited_Map.png";

locationsCSVFile = f"{Obsidian}\\Churches - Files\\Churches-Locations.csv";

GPXFileOrganicMapsAll = f"{Obsidian}\\Churches - Files\\Shropshire-Churches-OM-All.gpx";
GPXFileOrganicMapsNot = f"{Obsidian}\\Churches - Files\\Shropshire-Churches-OM-Not.gpx";
GPXFileOrganicMapsVis = f"{Obsidian}\\Churches - Files\\Shropshire-Churches-OM-Vis.gpx";

def option1():
  print("1. Generate the featured churches and items markdown files in the notebook.")
  JavaClass = f"{exepath}\\ChurchesHistoryFeatured.java"
  subprocess.run(["java", "-cp", classpath, JavaClass, "-article", article, "-churches", featuredChurches, "-items", featuredItems])

def option2():
  print("2. Generate the maps for the the WebSite and Organic Maps")
  JavaClass = f"{exepath}\\ChurchesDatabaseMaps.java"
  subprocess.run(["java", "-cp", classpath, JavaClass, "-imgbase", mapEmpty, "-imghtml", mapVisited, "-locations", locationsCSVFile, "-database", database, "-omall", GPXFileOrganicMapsAll, "-omnot", GPXFileOrganicMapsNot, "-omvis", GPXFileOrganicMapsVis])

def option3():
  print("3. Gather the images used in the notebook for the WebSite.")
  JavaClass = f"{exepath}\\ChurchesDatabaseGatherImages.java"
  subprocess.run(["java", "-cp", classpath, JavaClass, "-article", article, "-notebook", Obsidian, "-github", f"{GitHub}\\images"])

def option4():
  print("4. Generate the visited churches pages for the WebSite.")
  JavaClass = f"{exepath}\\ChurchesDatabaseVisited.java"
  subprocess.run(["java", "-cp", classpath, JavaClass, "-db", database, "-html", GitHub])
  JavaClass = f"{exepath}\\ChurchesDatabaseWebSite.java"
  subprocess.run(["java", "-cp", classpath, JavaClass, "-mode", "construct", "-file", f"{GitHub}\\hereford.html", "-template", template])
  subprocess.run(["java", "-cp", classpath, JavaClass, "-mode", "construct", "-file", f"{GitHub}\\lichfield.html", "-template", template])

def option5():
  print("5. Generate the WebSite.")
  JavaClass = f"{exepath}\\ChurchesDatabaseWebSite.java"
  subprocess.run(["java", "-cp", classpath, JavaClass, "-mode", "split", "-file", article, "-sep", "___", "-folder", GitHub])
  print("Deleting : ", f'{GitHub}\\11.html')
  os.remove(f'{GitHub}\\11.html')
  print("Deleting : ", f'{GitHub}\\12.html')
  os.remove(f'{GitHub}\\12.html')
  JavaClass = f"{exepath}\\ChurchesFeaturedItems.java"
  subprocess.run(["java", "-cp", classpath, JavaClass, "-markdown", featuredItems, "-html", f"{GitHub}\\18.html"])
  JavaClass = f"{exepath}\\ChurchesDatabaseWebSite.java"
  print("Deleting : ", f'{GitHub}\\index.html')
  os.remove(f'{GitHub}\\index.html')
  print("Copying : ", f'{GitHub}\\index.html')
  shutil.copyfile(f'{GitHub}\\index.md', f'{GitHub}\\index.html')
  subprocess.run(["java", "-cp", classpath, JavaClass, "-mode", "convert", "-file", f"{GitHub}\\index.html"])
  subprocess.run(["java", "-cp", classpath, JavaClass, "-mode", "construct", "-file", f"{GitHub}\\index.html", "-template", template])
  print("Deleting : ", f'{GitHub}\\visiting.html')
  os.remove(f'{GitHub}\\visiting.html')
  print("Copying : ", f'{GitHub}\\visiting.html')
  shutil.copyfile(f'{GitHub}\\visiting.md', f'{GitHub}\\visiting.html')
  subprocess.run(["java", "-cp", classpath, JavaClass, "-mode", "convert", "-file", f"{GitHub}\\visiting.html"])
  subprocess.run(["java", "-cp", classpath, JavaClass, "-mode", "construct", "-file", f"{GitHub}\\visiting.html", "-template", template])
  print("Deleting : ", f'{GitHub}\\about.html')
  os.remove(f'{GitHub}\\about.html')
  print("Copying : ", f'{GitHub}\\about.html')
  shutil.copyfile(f'{GitHub}\\about.md', f'{GitHub}\\about.html')
  subprocess.run(["java", "-cp", classpath, JavaClass, "-mode", "convert", "-file", f"{GitHub}\\about.html"])
  subprocess.run(["java", "-cp", classpath, JavaClass, "-mode", "construct", "-file", f"{GitHub}\\about.html", "-template", template])
  for filename in os.listdir(GitHub):
    if re.search(r"[0-9]\.html", filename):
      subprocess.run(["java", "-cp", classpath, JavaClass, "-mode", "convert", "-file", f"{GitHub}\\{filename}"])
      subprocess.run(["java", "-cp", classpath, JavaClass, "-mode", "construct", "-file", f"{GitHub}\\{filename}", "-template", template])

def option8():
  print("8. Build the list of sub-images.")
  JavaClass = f"{exepath}\\ChurchesDatabaseSubImages.java"
  subprocess.run(["java", "-cp", classpath, JavaClass, "-db", database, "-csv", subImagesCSV])

sel = 0
while sel != 9:

  print ("Churches Notebook scripting functions.")
  print ("Select an option : ")
  print ("1. Generate the featured churches and items markdown files in the notebook.")
  print ("2. Generate the maps for the the WebSite and Organic Maps")
  print ("3. Gather the images used in the notebook for the WebSite.")
  print ("4. Generate the visited churches pages for the WebSite.")
  print ("5. Generate the WebSite.")
  print ("8. Build the list of sub-images.")
  print ("9. Exit.")

  notValid = True
  while notValid == True:
    inp = input("Select an option : ")
    try:
      sel = int(inp)
    except ValueError:
      sel = 0
    if (0 < sel <= 5) or (8 <= sel <= 9):
      notValid = False
    else:
      print("Wrong input, please try again.")
  if sel == 1:
    option1()
  elif sel == 2:
    option2()
  elif sel == 3:
    option3()
  elif sel == 4:
    option4()
  elif sel == 5:
    option5()
  elif sel == 8:
    option8()
