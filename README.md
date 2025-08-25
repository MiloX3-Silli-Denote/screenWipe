# screenWipe
love2d library for a screenwipe visual

## Usage
download and add the 'screenWipe' folder to your project and add ```ScreenWipe = require("screenWipe").init()``` to your main file and add ```ScreenWipe.draw()``` to the end of your love.draw callback

to perform a screen wipe call ```ScreenWipe.wipeScreen(screenWipe, [wipeTime, finishCallback]);``` with the 'screenWipe' arg being the name of a defined screen wipe animation, or a function that will do the animation, 'wipeTime' is the amount of seconds that the animation will last (each screenWipe can have a default amount of time incase one isnt defined when wipeScreen is called, but if there is not a default one and one is not given as an argument, then it will error), 'finishCallback' is an optional function that will be called once the animation has completed.

Speed up all animations by calling ```ScreenWipe.setTimeScale(newTimeScale)```, the argument given will be multiplied by loves deltatime every frame (if you set it to 2 then animations will play 2x as fast)

Define a new animation with a name by calling ```ScreenWipe.defineAnimation(name, animationFunction, [defaultTime]);``` 'name' is the pair to use for finding it with wipeScreen, 'animationFunction' is the function that will be called to play the animation, and 'defaultTime' is the default amount of time that the animation will be played for if one isnt defined in wipeScreen.

### Animation functions
When defining an animation or providing a new animation directly to the wipeScreen function, the callable function provided will be called with 2 arguments every frame: 1. a time value of how much of the animation has completed (always between 0 and 1) 2. an image object of the frame that was displayed on the window imedietly after wipeScreen was called. the function is always the last drawn item.

for creating a draworder and remembering where you want to place the wipeScreen call, its important to remember that the wip screen will occur on the *next frame* the timeline will look something like this.

frame starts->wipeScreen is called->frame is drawn to window and saved->frame ends->next frame starts->...->screen wipe animation plays at t>0

it is also useful to remember that t=0 and t=1 will never be given to the animation function as those frames are intended to be 100% prewipe frame, or 100% post wipe frame

### Callbacks and finishing the animation

When the animation finishes, if a callback was given to the wipeScreen function, then it will be called during the end of the love draw callback (when it wouldve drawn), and ScreenWipe will set a flag that for the frame after that wouldve occured, calling ```ScreenWipe.isWipeFinished()``` will return true.
