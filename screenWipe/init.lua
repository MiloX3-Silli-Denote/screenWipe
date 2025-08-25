local path = (...); -- the path to this library

local ScreenWipe = {};
local self = ScreenWipe; -- for readability

function ScreenWipe.init()
    self.timeScale = 1; -- scale the animations speed by this

    -- default screen wipe animations, can be automatically added to
    self.defaultWipes = {
        ["default"] = function(time, preWipeFrame)
            local winHeight = love.graphics.getHeight();
            local winLength = love.graphics.getWidth();
            local sqrt2 = math.sqrt(2);

            love.graphics.setColor(1,1,1);
            love.graphics.origin();

            local stencilMask = function()
                love.graphics.rectangle("fill", -(winHeight + 15) * sqrt2 / 2 + (winLength + (winHeight + 15) * sqrt2 * 2) * time, 0, winLength * 2, winHeight);
            end

            love.graphics.stencil(stencilMask, "replace", 1);
            love.graphics.setStencilTest("greater", 0);
            love.graphics.draw(preWipeFrame);
            love.graphics.setStencilTest();

            love.graphics.translate(-(winHeight + 15) * sqrt2 + (winLength + (winHeight + 15) * sqrt2 * 2) * time, winHeight / 2);
            love.graphics.rotate(-math.pi / 4);
            love.graphics.setColor(0.4, 0, 0);
            love.graphics.rectangle("fill", 0,0, winHeight + 30, winHeight + 30);

            love.graphics.origin();
            love.graphics.translate(-winHeight * sqrt2 + (winLength + (winHeight + 15) * sqrt2 * 2) * time, winHeight / 2);
            love.graphics.rotate(-math.pi / 4);
            love.graphics.setColor(1, 0, 0);
            love.graphics.rectangle("fill", 0,0, winHeight, winHeight);
        end;
    };

    -- how long each default wipscreen wipe animation will last by default
    self.defaultWipeTimes = {
        ["default"] = 1.3;
    };

    self.isWiping = false; -- is there a screen wipe happening rn?
    self.time = 0; -- how many seconds (scaled) have passed since the wipe has started
    self.wipeTime = 0; -- how many seconds (unscaled) is the animation long?
    self.preWipeFrame = nil; -- image of the frame that was displayed on the screen after wipeScreen was called
    self.wipeAnimation = nil; -- function to be called to draw the animation, given the animation perun and the preWipeFrame

    self.finishedWipe = false; -- is true for one frame after wipe completes
    self.wipeFinishCallback = nil; -- a function that will be called when the wipe is completed

    return self; -- allow: DepthDrawing = require("screenWipe").init();
end

function ScreenWipe.setTimeScale(newTimeScale)
    self.timeScale = newTimeScale;
end

function ScreenWipe.defineAnimation(name, func, defaultTime)
    assert(self.defaultWipes[name] == nil, "tried to add an animation with the name of one that already exists");
    assert(type(func) == "function", "animation needs to be in the form of a function");

    self.defaultWipes[name] = func;
    if defaultTime then -- if we want to define a default time then place it in the function aswell
        self.defaultWipeTimes[name] = defaultTime;
    end
end

-- if the wipe finished this frame
function ScreenWipe.isWipeFinished()
    return self.finishedWipe;
end

function ScreenWipe.wipeScreen(screenWipeAnimation, wipeTime_callback, callback)
    screenWipeAnimation = screenWipeAnimation or "default";

    local wipeTime = nil;

    if type(wipeTime_callback) == "number" then
        wipeTime = wipeTime_callback;
    else
        callback = wipeTime_callback;
    end

    if not wipeTime then
        assert(type(screenWipeAnimation) == "string", "cannot assume screen wipe time with function defined in screen wipe call");
        assert(self.defaultWipeTimes[screenWipeAnimation], "could not assume screen wipe time from default animations");

        wipeTime = self.defaultWipeTimes[screenWipeAnimation];
    end

    -- get the screen that will be drawn this frame
    love.graphics.captureScreenshot(
        function(imgData)
            self.preWipeFrame = love.graphics.newImage(imgData);

            self.isWiping = true;
            self.time = 0;
            self.wipeTime = wipeTime;
            self.wipeFinishCallback = callback;

            if type(screenWipeAnimation) == "string" then
                self.wipeAnimation = self.defaultWipes[screenWipeAnimation];
            elseif type(screenWipeAnimation) == "function" then
                self.wipeAnimation = screenWipeAnimation;
            else
                error("animation or defaultr animation not provided for screen wipe");
            end
        end
    );
end

function ScreenWipe.draw()
    if not self.isWiping then
        self.finishedWipe = false;

        return;
    end

    self.time = self.time + love.timer.getDelta() * self.timeScale;

    if self.time >= self.wipeTime then
        self.isWiping = false;

        if self.wipeFinishCallback then
            self.wipeFinishCallback();
            self.wipeFinishCallback = nil;
        end

        self.finishedWipe = true;

        return;
    end

    local perun = self.time / self.wipeTime;

    -- check if _G.DepthTester is defined
    -- this is another library I created for easier love utilization
    -- it moves where the origin is though so we disable it here to allow
    -- usage of this library without it and to not need any modifications to code
    -- if you move an animation from a script w/ it 2 one w/o it
    if _G.DepthTester then
        local wasEnabled = DepthTester.isEnabled();

        love.graphics.push();

        DepthTester.disable();

        love.graphics.origin();
        love.graphics.setColor(1,1,1);

        self.wipeAnimation(perun, self.preWipeFrame);

        if wasEnabled then
            DepthTester.enable();
        end

        love.graphics.pop();
    else
        love.graphics.push();
        love.graphics.origin();
        love.graphics.setColor(1,1,1);

        self.wipeAnimation(perun, self.preWipeFrame);

        love.graphics.pop();
    end
end

return ScreenWipe;