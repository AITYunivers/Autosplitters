<!-- omit from toc -->
# Uhara for Clickteam Fusion 2.5
This is a custom version of [Uhara 9](https://github.com/ru-mii/uhara) made specifically for use with Clickteam Fusion 2.5.
It was made by [AITYunivers](https://github.com/AITYunivers), but all credit for Uhara as a whole goes to [ru-mii](https://github.com/ru-mii).

Source Code: https://github.com/AITYunivers/uharaClickteamBeta

<!-- omit from toc -->
## API

<!-- omit from toc -->
### Table of Contents
- [WatchGlobalVariable](#watchglobalvariable)
- [GetGlobalVariable](#getglobalvariable)
- [WatchGlobalString](#watchglobalstring)
- [GetGlobalString](#getglobalstring)
- [WatchAlterableVariable](#watchalterablevariable)
- [GetAlterableVariable](#getalterablevariable)
- [WatchAnimation](#watchanimation)
- [GetAnimation](#getanimation)
- [WatchPositionX](#watchpositionx)
- [GetPositionX](#getpositionx)
- [WatchPositionY](#watchpositiony)
- [GetPositionY](#getpositiony)
- [WatchCounter](#watchcounter)
- [GetCounter](#getcounter)
- [WatchString](#watchstring)
- [GetString](#getstring)
- [WatchVisibility](#watchvisibility)
- [GetVisibility](#getvisibility)
- [WatchMovementSpeed](#watchmovementspeed)
- [GetMovementSpeed](#getmovementspeed)
- [WatchObjectCount](#watchobjectcount)
- [GetObjectCount](#getobjectcount)
- [WatcherExists](#watcherexists)
- [RemoveOldWatcher](#removeoldwatcher)
- [ClearWatchers](#clearwatchers)
- [Popup](#popup)

### WatchGlobalVariable

```cs
public void WatchGlobalVariable(string watcherName, int globalVarIndex)
```
Lets you set a watcher for a global value

<!-- omit from toc -->
### Parameters
- watcherName : The name of the watcher, to be called using `current.` or `old.`
- globalVarIndex : The index of the global variable, where Global Value A is 0

### GetGlobalVariable

```cs
public double GetGlobalVariable(int globalVarIndex)
```
Lets you get a global value, without setting a watcher

<!-- omit from toc -->
### Parameters
- globalVarIndex : The index of the global variable, where Global Value A is 0

### WatchGlobalString

```cs
public void WatchGlobalString(string watcherName, int globalStrIndex)
```
Lets you set a watcher for a global string

<!-- omit from toc -->
### Parameters
- watcherName : The name of the watcher, to be called using `current.` or `old.`
- globalStrIndex : The index of the global string, where Global String A is 0

### GetGlobalString

```cs
public string GetGlobalString(int globalStrIndex)
```
Lets you get a global string, without setting a watcher

<!-- omit from toc -->
### Parameters
- globalStrIndex : The index of the global string, where Global String A is 0

### WatchAlterableVariable

```cs
public void WatchAlterableVariable(string watcherName, string objectName, int altVarIndex, int instanceIndex = 0)
```
Lets you set a watcher for an object instance's alterable value

If the version of Clickteam Fusion used is older than 292, the object specified must be an Active object, otherwise it will not create a watcher

<!-- omit from toc -->
### Parameters
- watcherName : The name of the watcher, to be called using `current.` or `old.`
- objectName : The name of the object
- altVarIndex : The index of the alterable value, where Alterable Value A is 0
- instanceIndex : (Optional) The index of the instance, defaults to 0

### GetAlterableVariable

```cs
public double GetAlterableVariable(string objectName, int altVarIndex, int instanceIndex = 0)
```
Lets you get an object instance's alterable value, without setting a watcher<br/>
Not recommended if getting more than once, otherwise it may cause lag.

If the version of Clickteam Fusion used is older than 292, the object specified must be an Active object, otherwise it will return 0

<!-- omit from toc -->
### Parameters
- objectName : The name of the object
- altVarIndex : The index of the alterable value, where Alterable Value A is 0
- instanceIndex : (Optional) The index of the instance, defaults to 0

### WatchAnimation

```cs
public void WatchAnimation(string watcherName, string objectName, int instanceIndex = 0)
```

Lets you set a watcher for an active instance's animation index, where

- Stopped = **0**
- Walking = **1**
- Running = **2**
- Appearing = **3**
- Disappearing = **4**
- Bouncing = **5**
- Launching = **6**
- Jumping = **7**
- Falling = **8**
- Climbing = **9**
- Crouching down = **10**
- Stand up = **11**

And user-defined animations index up from **12**

The object specified must be an Active object, otherwise it will not create a watcher<br/>
Support for extensions with Animations is not implemented

<!-- omit from toc -->
### Parameters
- watcherName : The name of the watcher, to be called using `current.` or `old.`
- objectName : The name of the object
- instanceIndex : (Optional) The index of the instance, defaults to 0

### GetAnimation

```cs
public int GetAnimation(string objectName, int instanceIndex = 0)
```

Lets you get an active instance's animation index, without setting a watcher, where

- Stopped = **0**
- Walking = **1**
- Running = **2**
- Appearing = **3**
- Disappearing = **4**
- Bouncing = **5**
- Launching = **6**
- Jumping = **7**
- Falling = **8**
- Climbing = **9**
- Crouching down = **10**
- Stand up = **11**

And user-defined animations index up from **12**<br/>
Not recommended if getting more than once, otherwise it may cause lag.

The object specified must be an Active object, otherwise it will return 0<br/>
Support for extensions with Animations is not implemented

<!-- omit from toc -->
### Parameters
- objectName : The name of the object
- instanceIndex : (Optional) The index of the instance, defaults to 0

### WatchPositionX

```cs
public void WatchPositionX(string watcherName, string objectName, int instanceIndex = 0)
```
Lets you set a watcher for an object instance's X position

<!-- omit from toc -->
### Parameters
- watcherName : The name of the watcher, to be called using `current.` or `old.`
- objectName : The name of the object
- instanceIndex : (Optional) The index of the instance, defaults to 0

### GetPositionX

```cs
public int GetPositionX(string objectName, int instanceIndex = 0)
```
Lets you get an object instance's X position, without setting a watcher<br/>
Not recommended if getting more than once, otherwise it may cause lag.

<!-- omit from toc -->
### Parameters
- objectName : The name of the object
- instanceIndex : (Optional) The index of the instance, defaults to 0

### WatchPositionY

```cs
public void WatchPositionY(string watcherName, string objectName, int instanceIndex = 0)
```
Lets you set a watcher for an object instance's Y position

<!-- omit from toc -->
### Parameters
- watcherName : The name of the watcher, to be called using `current.` or `old.`
- objectName : The name of the object
- instanceIndex : (Optional) The index of the instance, defaults to 0

### GetPositionY

```cs
public int GetPositionY(string objectName, int instanceIndex = 0)
```
Lets you get an object instance's Y position, without setting a watcher<br/>
Not recommended if getting more than once, otherwise it may cause lag.

<!-- omit from toc -->
### Parameters
- objectName : The name of the object
- instanceIndex : (Optional) The index of the instance, defaults to 0

### WatchCounter

```cs
public void WatchCounter(string watcherName, string objectName, int instanceIndex = 0)
```
Lets you set a watcher for a counter instance's value

The object specified must be either a Counter, Lives, or Score object, otherwise it will not create a watcher

<!-- omit from toc -->
### Parameters
- watcherName : The name of the watcher, to be called using `current.` or `old.`
- objectName : The name of the object
- instanceIndex : (Optional) The index of the instance, defaults to 0

### GetCounter

```cs
public double GetCounter(string objectName, int instanceIndex = 0)
```
Lets you get a counter instance's Y position, without setting a watcher<br/>
Not recommended if getting more than once, otherwise it may cause lag.

The object specified must be either a Counter, Lives, or Score object, otherwise it will return 0

<!-- omit from toc -->
### Parameters
- objectName : The name of the object
- instanceIndex : (Optional) The index of the instance, defaults to 0

### WatchString

```cs
public void WatchString(string watcherName, string objectName, int instanceIndex = 0)
```
Lets you set a watcher for a string instance's value

The object specified must be a String object, otherwise it will not create a watcher

<!-- omit from toc -->
### Parameters
- watcherName : The name of the watcher, to be called using `current.` or `old.`
- objectName : The name of the object
- instanceIndex : (Optional) The index of the instance, defaults to 0

### GetString

```cs
public string GetString(string objectName, int instanceIndex = 0)
```
Lets you get a string instance's value, without setting a watcher<br/>
Not recommended if getting more than once, otherwise it may cause lag.

The object specified must be a String object, otherwise it will return an empty string

<!-- omit from toc -->
### Parameters
- objectName : The name of the object
- instanceIndex : (Optional) The index of the instance, defaults to 0

### WatchVisibility

```cs
public void WatchVisibility(string watcherName, string objectName, int instanceIndex = 0)
```
Lets you set a watcher for an object instance's visibility

<!-- omit from toc -->
### Parameters
- watcherName : The name of the watcher, to be called using `current.` or `old.`
- objectName : The name of the object
- instanceIndex : (Optional) The index of the instance, defaults to 0

### GetVisibility

```cs
public bool GetVisibility(string objectName, int instanceIndex = 0)
```
Lets you get an object instance's visibility, without setting a watcher<br/>
Not recommended if getting more than once, otherwise it may cause lag.

<!-- omit from toc -->
### Parameters
- objectName : The name of the object
- instanceIndex : (Optional) The index of the instance, defaults to 0

### WatchMovementSpeed

```cs
public void WatchMovementSpeed(string watcherName, string objectName, int instanceIndex = 0)
```
Lets you set a watcher for an object instance's movement speed

The object specified cannot be a Backdrop, Quick Backdrop, or Extension object, otherwise it will not create a watcher<br/>
Support for extensions with Movements is not implemented

<!-- omit from toc -->
### Parameters
- watcherName : The name of the watcher, to be called using `current.` or `old.`
- objectName : The name of the object
- instanceIndex : (Optional) The index of the instance, defaults to 0

### GetMovementSpeed

```cs
public int GetMovementSpeed(string objectName, int instanceIndex = 0)
```
Lets you get an object instance's movement speed, without setting a watcher<br/>
Not recommended if getting more than once, otherwise it may cause lag.

The object specified cannot be a Backdrop, Quick Backdrop, or Extension object, otherwise it will not create a watcher<br/>
Support for extensions with Movements is not implemented

<!-- omit from toc -->
### Parameters
- objectName : The name of the object
- instanceIndex : (Optional) The index of the instance, defaults to 0

### WatchObjectCount

```cs
public void WatchObjectCount(string watcherName, string objectName)
```
Lets you set a watcher for how many instances an object has

<!-- omit from toc -->
### Parameters
- watcherName : The name of the watcher, to be called using `current.` or `old.`
- objectName : The name of the object

### GetObjectCount

```cs
public int GetObjectCount(string objectName)
```
Lets you get how many instances an object has, without setting a watcher<br/>
Not recommended if getting more than once, otherwise it may cause lag.

<!-- omit from toc -->
### Parameters
- objectName : The name of the object

### WatcherExists

```cs
public bool WatcherExists(string watcherName)
```
Lets you check if a watcher currently exists and is being updated by Uhara

<!-- omit from toc -->
### Parameters
- watcherName : The name of the watcher

### RemoveOldWatcher

```cs
public void RemoveOldWatcher(string watcherName)
```
Removes a watcher if it currently exists and is being updated by Uhara.

This is highly recommended for when old watcher variables or unavailable, or no longer being used. Otherwise, they will keep getting read every tick.

<!-- omit from toc -->
### Parameters
- watcherName : The name of the watcher

### ClearWatchers

```cs
public void ClearWatchers()
```
Clears all pre-existing watchers that are being updated by Uhara.

### Popup

```cs
public DialogResult Popup(string text, string caption)
```
Gives a popup to the user, linked to the Clickteam application<br/>
Similar to MessageBox.Show, except it'll show even if LiveSplit isn't in focus