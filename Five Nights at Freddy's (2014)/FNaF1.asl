state("FiveNightsatFreddys") {} // Full Release
state("FiveNightsDEMO") {}      // Demo

startup
{
    Assembly.Load(File.ReadAllBytes("Components/uharaClickteamBeta")).CreateInstance("Main");

    settings.Add("Starts", true, "Define what start behaviors you'd like");
        settings.Add("Start-Newspaper",  true, "Start Timer when the newpaper starts to fade in",  "Starts");
        settings.Add("Start-WhatNight",  true, "Start Timer when the Night X screen appears",      "Starts");
        settings.Add("Start-Office",    false, "Start Timer when the office appears (For Death%)", "Starts");

    settings.Add("Splits", true, "Define what split behaviors you'd like");
        settings.Add("Split-Night",        true, "Split at 6AM at the end of nights",                                                "Splits");
        settings.Add("Split-Transitions", false, "Split at the ends of both the 6AM and the Night X screens",                        "Splits");
        settings.Add("Split-Fades",       false, "Split at the starts and ends of selected fades (Will not collide with the above)", "Splits");
            settings.Add("Split-FadeIn-Start",   false, "Split at the start of the Fade In from the Office to the 6AM screen",              "Split-Fades");
            settings.Add("Split-FadeIn-End",     false, "Split at the end of the Fade In from the Office to the 6AM screen",                "Split-Fades");
            settings.Add("Split-FadeOut1-Start", false, "Split at the start of the Fade Out from the 6AM screen to the Night X screen",     "Split-Fades");
            settings.Add("Split-FadeOut1-End",   false, "Split at the end of the Fade Out from the 6AM screen to the Night X screen",       "Split-Fades");
            settings.Add("Split-FadeOut2-Start", false, "Split at the start of the Fade Out from the Night X screen to the loading screen", "Split-Fades");
            settings.Add("Split-FadeOut2-End",   false, "Split at the end of the Fade Out from the Night X screen to the loading screen",   "Split-Fades");
        settings.Add("Split-Death",       false, "Split when the static appears on death (For Death%)",                              "Splits");

    settings.Add("Resets", true, "Define what reset behaviors you'd like");
        settings.Add("Reset-F2",    true, "Reset Timer on F2",    "Resets");
        settings.Add("Reset-Death", true, "Reset Timer on Death", "Resets");

    settings.Add("NoLoads", true, "Pause the timer during loads");
    settings.Add("RefreshX2", false, "Double Autosplitter Refresh Rate from 60tps to 120tps");

    refreshRate = 60;

    if (timer.CurrentTimingMethod == TimingMethod.RealTime)
    {        
        var timingMessage = MessageBox.Show (
            "This autosplitter requires Game Time (IGT) to remove loads.\n"+
            "LiveSplit is currently set to show Real Time (RTA).\n"+
            "Would you like to set the timing method to Game Time?",
            "LiveSplit | Five Nights at Freddy's",
            MessageBoxButtons.YesNo,MessageBoxIcon.Question
        );
        
        if (timingMessage == DialogResult.Yes)
            timer.CurrentTimingMethod = TimingMethod.GameTime;
    }
}

init
{
    // Initialize Uhara Instance
    vars.Instance = vars.Uhara.CreateTool("ClickteamFusion", "Instance");
    vars.Instance.Initialize(tryPointers: new int[] 
    {
        0xAC9AC, // Fusion 284       (v1.132)
        0xA6B4C  // Fusion 281 - 282 (v1.0 - v1.131)
    });

    // Initialize Variables
    vars.HasInit = false;
    vars.Warned = false;
}

start 
{
    vars.OffsetFrame = current.Frame + vars.FrameOffset;
    if (old.Frame != current.Frame)
    {
        if (settings["Start-Newspaper"] && vars.OffsetFrame == 10)
            return true;
        if (settings["Start-WhatNight"] && vars.OffsetFrame == 2)
            return true;
        if (settings["Start-Office"] && vars.OffsetFrame == 3)
            return true;
    }
}

onStart
{
    if (settings["RefreshX2"])
        refreshRate = 120;
    else
        refreshRate = 60;
}

update
{
    if (vars.Instance == null)
        return;

    vars.Uhara.Update();

    // Compatibility for older versions without the warning frame
    vars.FrameOffset = current.FrameCount == 16 ? 1 : 0;
    vars.OffsetFrame = current.Frame + vars.FrameOffset;
    
    if (current.Frame == old.Frame && vars.HasInit)
        return;
    
    int oldOffsetFrame = old.Frame + vars.FrameOffset;
    vars.HasInit = true;
    
    // Warn if using an invalid version of FNaF 1
    if (!vars.Warned && vars.OffsetFrame == 1)
    {
        string version = vars.Instance.GetString("String");
        bool isDemo = vars.Instance.GetCounter("DEMO?") == 1;

        // Check if version was actually properly read
        if (version != "v 1.132" && version != "" || isDemo)
        {
            var timingMessage = vars.Instance.Popup(
                @"It seems you're using a version of Five Nights at Freddy's, not allowed in speedrunning.
                
                Required version: v 1.132
                Current version: " + version + (isDemo ? " Demo" : ""),
                "LiveSplit | Five Nights at Freddy's"
            );
        }

        // Retry next time if the version wasn't properly read
        vars.Warned = version != "";
    }

    // Create Time of Day watcher
    if (vars.OffsetFrame == 3)
        vars.Instance.WatchCounter("TimeOfDay", "time of day");
    else if (oldOffsetFrame == 3)
        vars.Instance.RemoveOldWatcher("TimeOfDay");

    // Create Count of 'Active' watcher for Split on Death
    if (vars.OffsetFrame == 5)
        vars.Instance.WatchObjectCount("DeathAnimCount", "Active");
    else if (oldOffsetFrame == 5)
        vars.Instance.RemoveOldWatcher("DeathAnimCount");

    // Reset Fade Split Variables 
    if (vars.OffsetFrame == 3)
    {
        vars.StartedFade1 = false;
        vars.StartedFade2 = false;
    }
}

split
{
    vars.OffsetFrame = current.Frame + vars.FrameOffset;
    bool uniqueFrame = old.Frame != current.Frame;

    if (settings["Split-Night"])
    {
        // Split at 6AM if possible
        if (vars.OffsetFrame == 3)
        {
            if (current.TimeOfDay == 6 && old.TimeOfDay == 6)
            {
                vars.ShouldSplit = false;
                return true;
            }

            vars.ShouldSplit = true;
        }
        // Otherwise, just split after the frame change
        else if (vars.OffsetFrame == 6 && vars.ShouldSplit && uniqueFrame)
        {
            vars.ShouldSplit = false;
            return true;
        }
    }
    
    if (settings["Split-Transitions"])
    {
        // Split when the Night X screen appears, indicating the end of the 6 AM screen
        if (vars.OffsetFrame == 2 && uniqueFrame)
            return true;
        
        // Split when the Loading screen appears, indicating the end of the Night X screen
        else if (vars.OffsetFrame == 7 && uniqueFrame)
            return true;
    }

    if (settings["Split-Fades"])
    {
        int oldOffsetFrame = old.Frame + vars.FrameOffset;
        bool uniqueState = old.AppRunningState != current.AppRunningState;

        // Don't run the ones that would collide with the Night split, essentially being the exact same
        if (!settings["Split-Night"])
        {
            // Start Fade In on 6AM screen
            if (settings["Split-FadeIn-Start"] && vars.OffsetFrame == 6 && current.AppRunningState == 2 && uniqueState)
                return true;
        }

        // Start Fade Out on 6AM screen
        if (settings["Split-FadeOut1-Start"] && vars.OffsetFrame == 6 && current.AppRunningState == 4 && uniqueState)
        {
            vars.StartedFade1 = true;
            return true;
        }

        // Start Fade Out on Night X screen
        if (settings["Split-FadeOut2-Start"] && vars.OffsetFrame == 2 && current.AppRunningState == 4 && uniqueState)
        {
            vars.StartedFade2 = true;
            return true;
        }

        // End Fade In on 6AM screen
        if (settings["Split-FadeIn-End"] && vars.OffsetFrame == 6 && old.AppRunningState == 2 && uniqueState)
            return true;

        // Don't run the ones that would collide with the Transitions splits, essentially being the exact same
        if (!settings["Split-Transitions"])
        {
            // End Fade Out on 6AM screen
            if (settings["Split-FadeOut1-End"])
            {
                if (vars.OffsetFrame == 6 && old.AppRunningState == 4 && uniqueState)
                    return true;
                else if (vars.OffsetFrame != 6 && oldOffsetFrame == 6 && vars.StartedFade1)
                    return true;
            }

            // End Fade Out on Night X screen
            if (settings["Split-FadeOut2-End"])
            {
                if (vars.OffsetFrame == 2 && old.AppRunningState == 4 && uniqueState)
                    return true;
                else if (vars.OffsetFrame != 2 && oldOffsetFrame == 2 && vars.StartedFade2)
                    return true;
            }
        }
    }

    if (settings["Split-Death"])
    {
        // Split when the death static appears
        if (vars.OffsetFrame == 4 && uniqueFrame)
            return true;
        
        // Freddy's Jumpscare is in a different frame, so wait until the static is visible
        else if (vars.OffsetFrame == 5 && current.DeathAnimCount == 0 && old.DeathAnimCount != current.DeathAnimCount)
            return true;
    }
}

reset
{
    vars.OffsetFrame = current.Frame + vars.FrameOffset;
    if (old.Frame != current.Frame)
    {
        if (settings["Reset-F2"] && current.Frame == 0)
            return true;
        if (settings["Reset-Death"] && (vars.OffsetFrame == 4 || vars.OffsetFrame == 5))
            return true;
    }
}

isLoading
{           
    if (!settings["NoLoads"])
        return false;

    vars.OffsetFrame = current.Frame + vars.FrameOffset;
    return current.Frame == -1 || vars.OffsetFrame == 7;
}