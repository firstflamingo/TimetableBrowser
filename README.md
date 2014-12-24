TimetableBrowser
================

Bliksem Labs has put quite some effort in designing a container format which can host public transport schedules dubbed: timetable.dat.
The format is binary and uses lossy compression techniques which matches with rrrr, their routing engine.
Opposed to text-based formats such as GTFS or NeTEx, it is not easy to review by the human eye. 
TimetableBrowser is an OS-X application build by First Flamingo Enterprise B.V. for browsing through timetable.dat.

Compiling from source
---------------------

Create a location where you want to host your files.
```mkdir TimetableBrowser; cd TimetableBrowser```

Checkout this repository:
```git clone https://github.com/firstflamingo/TimetableBrowser```

Checkout the rrrr_cocoa_wrapper:
```git clone https://github.com/firstflamingo/rrrr_cocoa_wrapper```

Checkout the rrrr ansi branch:
```git clone -b ansi http://github.com/bliksemlabs/rrrr```

You can now open TimetableBrowser.xcodeproj in Xcode, and are ready to go.
