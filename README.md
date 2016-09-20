# VirtualTourist

VirtualTourist allows users to tap on anywhere on the map and view all the flickr photos that was posted at that location. This is a showcase project of my ability to create a production ready iOS Application that utilizes Core Data and iOS networking to get image data from Flickr. 

I have utilized many different technologies including Core Data, Networking, MapKit,Grand Central Dispatch, Multithreading, Model View Controller (MVC), Asynchronous & Concurrent Multithreading

The main concept I learned from this project is to utilize Core Data to persist data in the app. This is a very useful functionality that allows fast access of data and efficient cache. I exploited both NSUserDefaults and CoreDataManager to persist my Model data. 

Core Data is a framework that you use to manage the model layer objects in your application. It provides generalized and automated solutions to common tasks associated with object life cycle and object graph management, including persistence.


## Installation

1. git clone https://github.com/mmmk84512/VirtualTourist
2. open VirtualTourist.xcodeproj

## Features
- Add a pin to the map by tapping on the map
- Download flickr photos according to geo-location
- Persist new Pins, Settings and Photos to disk
- View pins in a map
- Tap a pin to view photos taken at the location
- Tap a photo to view full screen

## Project Overview

### Travel Locations Map

When the app first starts it will open to the map view. Users will be able to zoom and scroll around the map using standard pinch and drag gestures. The center of the map and the zoom level should be persistent. If the app is turned off, the map should return to the same state when it is turned on again. Tapping and holding the map drops a new pin. Users can place any number of pins on the map. When a pin is tapped, the app will navigate to the Photo Album view associated with the pin.

### Photo Album

If the user taps a pin that does not yet have a photo album, the app will download Flickr images associated with the latitude and longitude of the pin. If no images are found a “No Images” label will be displayed. If there are images, then they will be displayed in a collection view. While the images are downloading, the photo album is in a temporary “downloading” state in which the New Collection button is disabled. The app should determine how many images are available for the pin location, and display a placeholder image for each.

Once the images have all been downloaded, the app should enable the New Collection button at the bottom of the page. Tapping this button should empty the photo album and fetch a new set of images. Note that in locations that have a fairly static set of Flickr images, “new” images might overlap with previous collections of images. Users should be able to remove photos from an album by tapping them. Pictures will flow up to fill the space vacated by the removed photo. All changes to the photo album should be automatically made persistent. Tapping the back button should return the user to the Map view.

If the user selects a pin that already has a photo album then the Photo Album view should display the album and the New Collection button should be enabled.

## Contributing

1. Fork it!
2. Create your feature branch: `git checkout -b my-new-feature`
3. Commit your changes: `git commit -am 'Add some feature'`
4. Push to the branch: `git push origin my-new-feature`
5. Submit a pull request
