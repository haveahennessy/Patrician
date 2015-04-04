# Patrician

A Patricia/Radix Tree for Swift.

## Requirements

Patrician, being the aristocrat that it is, prefers iOS 8. However, since there are no external dependencies, it can coaxed into working on iOS 7 fairly easily.

## Why
Patricia trees have a number of benefits over typical dictionaries when it comes to using string keys. Peruse this [wikipedia entry](http://en.wikipedia.org/wiki/Radix_tree) for a more complete story.

## Installation

[Carthage](https://github.com/Carthage/Carthage) is the prefered method of installation.
Add the follwing to your Cartfile:
```
github "haveahennessy/Patrician"
```

And then run:
```
$ carthage update
```

Patrician will be built as a dynamic framework, which can then be added to your application.

## Usage
Patrician provides a single type: ```RadixTree```.  
```RadixTree``` can be used just as you would use the built in ```Dictionary``` type, with one caveat: Keys have to be strings.

## Contact

While Patrician currently serves its intended purpose, it still requires some grooming. Issues, Pull-requests, fan mail, and elitist/patrician hate mail are all welcome.

## Copyright & License

Patrician Library © Copyright 2014, Matt Isaacs.

Licensed under [the MIT license](LICENSE).
