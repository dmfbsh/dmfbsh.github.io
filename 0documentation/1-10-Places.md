---
layout: 1documentation
title: Places
---

# Places
{: .mt-4}

An SQLite database of the Places in Shropshire is maintained.

Information is maintained in two places:

- Trello - used to hold textual information about each Place
- Google Maps - used to hold the location of each Place

It is essential that the name of the Place is identical in both Trello and Google Maps as this is what is used to draw the information together.

The information is consolidated using an AutoHotKey application, from this application a GPX file containing the consolidated information can be generated which can then be loaded into the UK Map app on the iOS devices.

The structure of the database is shown below:

<img src="images/picture03.jpg" width="600"/>

To create a new Place or edit an existing Place:

1. Create / edit the Place location as required in Google Maps

2. From Google Maps, save the entire map as a KML file and save to the location:

   `C:\Users\David\Documents\OneDrive\Documents\My Documents\GitHub\dmfbsh.github.io\_maps\Shropshire - Places.kml`

3. Create / edit the Place notes as required in Trello

4. Using the AutoHotKey application import the Place location details from the KML file

5. Using the AutoHotKey application import the Place notes from Trello

6. Using the AutoHotKey application generate the GPX file, this is saved to the Google Drive so that it is available on the iOS devices

7. Import the GPX file into the UK Map app