{{TOC}}
[TOC]

# Introduction

My stamp collection is based on the theme of Formula 1.

The stamps are catalogued and recorded in an MS Access database.  The information is then published as a web site, organised to show the history of the sport.

# Web Site

The web site which depicts the history of Formula 1 using postage stamps is hosted on my GitHub Pages site at:

>[https://dmfbsh.github.io/](https://dmfbsh.github.io/)

The web site is built using data extracted from the MS Access database.

## Procedure to Build the Web Site

- Flags

>The image files for the flags need to be copied to the web site - there is a function in the MS Access database to do this.

>Once the files have been copied, the images are resized to have a maximum width of 150px.

>Use the Batch Convert function of FastStone viewer, the options file is "F1 Stamps - Flags.ccf" - overwrite the copied files.

![Screenshot05](Screenshot05.JPG)

- Thumbnails

>The image files for the thumbnails need to be copied to the web site - there is a function in the MS Access database to do this.

>Once the files have been copied, the images are resized to have a maximum height of 120px.

>Use the Batch Convert function of FastStone viewer, the options file is "F1 Stamps - Thumbs ht120.ccf" - overwrite the copied files.

![Screenshot07](Screenshot07.JPG)

>The thumbnails must also be cropped to have a maximum width of 200px.

>Use the Batch Convert function of FastStone viewer, the options file is "F1 Stamps - Thumbs crop200.ccf" - overwrite the copied files.

![Screenshot08](Screenshot08.JPG)

- Images

>The image files for the main images need to be copied to the web site, the images are classified as either large or small (small is width is less than 1000px, large is width is 1000px or more).  There is a function in the MS Access database to do this - the large and small images are placed in separate folders.

>Once the files have been copied, the images are resized to have a maximum width of 200px is small or 400px if large.

>Use the Batch Convert function of FastStone viewer, the options file is either "F1 Stamps - Pictures wd200.ccf" or "F1 Stamps - Pictures wd400.ccf" - overwrite the copied files.

![Screenshot06](Screenshot06.JPG)

>The large and small images must then be copied to the parent folder to consolidate into one place.

- Generate YML and HTML

>The YML is generated from the MS Access database.

>The HTML templates for the popups are generated from the MS Access database (because the popups are dynamic in nature).

>The static HTML is then generated using Jekyll.

## Additional Years and Decades

- For each extra year covered by the web site, create a new 2-yearYYYY.html file

- For each extra decade covered by the web site, create a new 2-yearsYYY0.html file

## Sub-Images

Advanced Renamer is used to rename the car and driver sub-images.  Two batch methods are defined:

- F1 Stamps - Cars

- F1 Stamps - Drivers

ARen is set up an external editor in FastStone Image Viewer  - copy the master image, rename with ARen and crop with FastStone Image Viewer.

# Tools

The following tools and applications are used:

- MS Access
- FastStone Image Viewer
- Advanced Renamer
- GitHub Desktop
- UltraEdit
- Typora
