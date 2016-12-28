# Spuristo
Spuristo is a simple tracker of actions.

## Use cases
* Counting the number of some actions. (For example, to show rate dialog after 3 App launches)
* Counting the time between some actions. (For example, counting App usage time or time period when App is in background)

## Installation
#### Drop files to Xcode
Just download the source code from repository and drop all files from "Sources" directory to your Xcode project.

## Usage
##### Create tracker
At first create instance of ```Tracker``` class like this:
```Swift
  let tracker = Tracker(with: "some_key", condition: TrackerCondition.Every(2))
```

##### Get tracker instance
All trackers will be automatically added to tracker pool. And you can get tracker by ```key``` like this:
```Swift
  let tracker = Tracker(for: "some_key")
```

##### Conditions
Condition attribute is enum consists of next cases:
* ```.Once(N: UInt)``` - Checkpiont will be called once after N usages
* ```.Every(N: UInt)``` - Checkpiont will be called after every N usages
* ```.Quadratic(N: UInt)``` - Checkpoint will call every time when usages count is power of N

##### Commits
To commit usage you can call next functions:
```Swift
  tracker.commit()
```
or
```Swift
  tracker.commit(n: UInt)
```
In second case tracker will commit ```n``` times.

##### Checkpoint
Checkpoint is closure calls when usages count satisfies the condition. For example, checkpoint closure will be called if condition is ```.Every(2)``` and action was commited 2 times.
```Swift
  tracker.checkpoint = {
    // Some code
  }
```

##### Other functions
Sets tracker to initial state
```Swift
  func drop()
```
Disable tracker
```Swift
  func disable()
```

##### Getters
* ```usagesCount``` - current usages count
* ```enabled``` - returns TRUE if tracker enabled
* ```key``` - tracker key
* ```condition``` - tracker condition

## License
The MIT License (MIT)

Copyright (c) 2016 Ilya Kharabet

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
