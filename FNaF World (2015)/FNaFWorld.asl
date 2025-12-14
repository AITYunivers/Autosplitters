state("FNaF_World"){} // Steam
state("fnaf-world"){} // Gamejolt

startup
{
    Assembly.Load(File.ReadAllBytes("Components/uharaClickteamBeta")).CreateInstance("Main");

    settings.Add("Normal",   false, "Normal Mode Ending");
        settings.Add("Normal-Instant", false, "Split when the Victory screen stops moving (Hard Mode Categories)", "Normal");
    settings.Add("Hard",     false, "Hard Mode Ending");
        settings.Add("Hard-Instant",   false, "Split when the Victory screen stops moving (100% / 157%)", "Hard");
    settings.Add("Fourth",   false, "Fourth Glitch Ending");
        settings.Add("Fourth-Instant", false, "Split as soon as you enter the Fourth Glitch (100% / 157%)", "Fourth");
    settings.Add("Chip",     false, "Chipper Ending");
        settings.Add("Chip-Instant",   false, "Split when the Victory screen stops moving (100% / 157%)", "Chip");
    settings.Add("Clock",    false, "Clock Ending");
    settings.Add("Universe", false, "Universe Ending");
    settings.Add("Rainbow",  false, "Rainbow Ending");
    settings.Add("Chars",    false, "Split At New Character Screen After Minigames");
        settings.Add("Char-1",  true, "Jack-O-Bonnie", "Chars");
        settings.Add("Char-2",  true, "Jack-O-Chica", "Chars");
        settings.Add("Char-3",  true, "Animdude", "Chars");
        settings.Add("Char-4",  true, "Chipper", "Chars");
        settings.Add("Char-5",  true, "Nightmare Balloon Boy", "Chars");
        settings.Add("Char-6",  true, "Nightmarionne", "Chars");
        settings.Add("Char-7",  true, "Coffee", "Chars");
        settings.Add("Char-8",  true, "Purple Guy", "Chars");
    settings.Add("ILs", true, "Specific timings for Individual Levels");
        settings.Add("IL-1",  false, "Chica's Magic Rainbow", "ILs");
        settings.Add("IL-2",  false, "Foxy Fighters", "ILs");
        settings.Add("IL-3",  false, "Foxy.EXE", "ILs");
        settings.Add("IL-4",  false, "Freddy in Space", "ILs");

    if (timer.CurrentTimingMethod == TimingMethod.RealTime)
    {        
        var timingMessage = MessageBox.Show (
            "This autosplitter requires Game Time (IGT) to remove loads.\n"+
            "LiveSplit is currently set to show Real Time (RTA).\n"+
            "Would you like to set the timing method to Game Time?",
            "LiveSplit | FNaF World",
            MessageBoxButtons.YesNo,MessageBoxIcon.Question
        );
        
        if (timingMessage == DialogResult.Yes)
            timer.CurrentTimingMethod = TimingMethod.GameTime;
    }
}

init
{
    vars.Instance = vars.Uhara.CreateTool("ClickteamFusion", "Instance");

    // Compatibility for older versions without the warning frame
    vars.FrameOffset = current.FrameCount == 31 ? 1 : 0;
    
    // Initialize variables to avoid errors
    current.NewCharacter = -1;
    current.FoundNewCharacter = -1;
    current.VictorySpeed = -1;
    current.VictoryStage = 0;
    current.VictoryCount = 0;
    current.inMinigame = false;
}

start 
{  
    if (settings["ILS"])
    {
        // Chica's Magic Rainbow
        if (settings["IL-1"] && vars.OffsetFrame == 44 && old.Frame != current.Frame)
            return true;

        // Foxy Fighters
        if (settings["IL-2"] && vars.OffsetFrame == 35 && old.Frame != current.Frame)
            return true;

        // Foxy.EXE
        if (settings["IL-3"] && vars.OffsetFrame == 41 && old.Frame != current.Frame)
            return true;

        // Freddy in Space
        if (settings["IL-4"] && vars.OffsetFrame == 38 && old.Frame != current.Frame)
            return true;
    }

    vars.OffsetFrame = current.Frame + vars.FrameOffset;
    return vars.OffsetFrame == 27 && old.Frame != current.Frame;
}

update
{
    if (vars.Instance == null)
        return;

    vars.Uhara.Update();
    vars.OffsetFrame = current.Frame + vars.FrameOffset;

    // Watch victory speed to check if it stops
    if (current.Frame == old.Frame)
    {
        if (vars.OffsetFrame == 5 && current.VictoryStage >= 2 && !vars.Instance.WatcherExists("VictorySpeed") && current.VictoryCount > 0)
            vars.Instance.WatchMovementSpeed("VictorySpeed", "victory");
            
        return;
    }
    
    int oldOffsetFrame = old.Frame + vars.FrameOffset;

    // Create Dialogue watcher
    if (vars.OffsetFrame >= 20 && vars.OffsetFrame <= 22)
        vars.Instance.WatchCounter("Dialogue", "text");
    else if (oldOffsetFrame >= 20 && oldOffsetFrame <= 22)
        vars.Instance.RemoveOldWatcher("Dialogue");

    // Create Lost Dialogue watcher
    if (vars.OffsetFrame == 15)
        vars.Instance.WatchCounter("LostDialogue", "chat");
    else if (oldOffsetFrame == 15)
        vars.Instance.RemoveOldWatcher("LostDialogue");

    // Create Found New Character watcher
    current.inMinigame = 
        vars.OffsetFrame == 35 ||   // Foxy Fighters
        vars.OffsetFrame == 38 ||   // Freddy in Space
        vars.OffsetFrame == 41 ||   // Foxy.EXE
        vars.OffsetFrame == 44;     // Chica's Magic Rainbow

    if (current.inMinigame)
        vars.Instance.WatchCounter("FoundNewCharacter", "found new");
    else if (old.inMinigame)
        vars.Instance.RemoveOldWatcher("FoundNewCharacter");

    // Create Battle watchers
    if (vars.OffsetFrame == 5)
    {
        vars.Instance.WatchObjectCount("VictoryCount", "victory");
        vars.Instance.WatchCounter("VictoryStage", "victory stage");
        vars.Instance.WatchCounter("Boss", "boss");
    }
    else if (oldOffsetFrame == 5)
    {
        vars.Instance.RemoveOldWatcher("VictoryCount");
        vars.Instance.RemoveOldWatcher("VictoryStage");
        vars.Instance.RemoveOldWatcher("Boss");

        vars.Instance.RemoveOldWatcher("VictorySpeed");
        current.VictorySpeed = -1;
    }

    // ILs
    if (settings["ILs"])
    {
        // Create Chica's Magic Rainbow WIN watcher
        if (settings["IL-1"])
        {
            if (vars.OffsetFrame == 44)
                vars.Instance.WatchCounter("CMRWin", "WIN");
            else if (oldOffsetFrame == 44)
                vars.Instance.RemoveOldWatcher("CMRWin");
        }

        // Create Foxy Fighters Souldozer HP watcher
        if (settings["IL-2"])
        {
            if (vars.OffsetFrame == 35)
                vars.Instance.WatchAlterableVariable("FFSouldozerHP", "souldozer", 0);
            else if (oldOffsetFrame == 35)
                vars.Instance.RemoveOldWatcher("FFSouldozerHP");
        }

        // Create Foxy.EXE Area watcher
        if (settings["IL-3"])
        {
            if (vars.OffsetFrame == 41)
                vars.Instance.WatchCounter("EXEArea", "area");
            else if (oldOffsetFrame == 41)
                vars.Instance.RemoveOldWatcher("EXEArea");
        }

        // Create Freddy in Space Scott HP watcher
        if (settings["IL-4"])
        {
            if (vars.OffsetFrame == 38)
                vars.Instance.WatchAlterableVariable("FISScottHP", "Active 14", 0);
            else if (oldOffsetFrame == 38)
                vars.Instance.RemoveOldWatcher("FISScottHP");
        }
    }
}

split
{
    vars.OffsetFrame = current.Frame + vars.FrameOffset;

    // Normal Mode Ending
    if (settings["Normal"])
    {
        if (!settings["Normal-Instant"] && vars.OffsetFrame == 20 && current.Dialogue == 7 && old.Dialogue != current.Dialogue)
            return true;
        else if (settings["Normal-Instant"] && vars.OffsetFrame == 5 && current.Boss == 14 && current.VictorySpeed == 0 && old.VictorySpeed != current.VictorySpeed)
            return true;
    }

    // Hard Mode Ending
    if (settings["Hard"])
    {
        if (!settings["Hard-Instant"] && vars.OffsetFrame == 21 && current.Dialogue == 7 && old.Dialogue != current.Dialogue)
            return true;
        else if (settings["Hard-Instant"] && vars.OffsetFrame == 5 && current.Boss == 10 && current.VictorySpeed == 0 && old.VictorySpeed != current.VictorySpeed)
            return true;
    }

    // Chipper Ending
    if (settings["Chip"])
    {
        if (!settings["Chip-Instant"] && vars.OffsetFrame == 22 && current.Dialogue == 7 && old.Dialogue != current.Dialogue)
            return true;
        else if (settings["Chip-Instant"] && vars.OffsetFrame == 5 && current.Boss == 15 && current.VictorySpeed == 0 && old.VictorySpeed != current.VictorySpeed)
            return true;
    }

    // Lost Ending
    if (settings["Fourth"] && vars.OffsetFrame == 15)
    {
        if (!settings["Fourth-Instant"] && current.LostDialogue == 3 && old.LostDialogue != current.LostDialogue)
            return true;
        else if (settings["Fourth-Instant"] && old.Frame != current.Frame)
            return true;
    }

    // Clock Ending
    if (settings["Clock"] && vars.OffsetFrame == 29 && old.Frame != current.Frame)
        return true;

    // Universe Ending
    if (settings["Universe"] && vars.OffsetFrame == 30 && old.Frame != current.Frame)
        return true;

    // Rainbow Ending
    if (settings["Rainbow"] && vars.OffsetFrame == 45 && old.Frame != current.Frame)
        return true;

    // New Character Split
    if (settings["Chars"] && vars.OffsetFrame == 43 && old.Frame != current.Frame)
        return settings["Char-" + (current.FoundNewCharacter - 40).ToString()];

    // ILs
    if (settings["ILs"])
    {
        // Chica's Magic Rainbow
        if (settings["IL-1"] && vars.OffsetFrame == 44 && current.CMRWin == 1 && old.CMRWin != current.CMRWin)
            return true;

        // Foxy Fighters
        if (settings["IL-2"] && vars.OffsetFrame == 35 && current.FFSouldozerHP < -2000 && old.FFSouldozerHP >= -2000)
            return true;

        // Foxy.EXE
        if (settings["IL-3"] && vars.OffsetFrame == 41 && current.EXEArea == 4 && old.EXEArea != current.EXEArea)
            return true;

        // Freddy in Space
        if (settings["IL-4"] && vars.OffsetFrame == 38 && current.FISScottHP < -1000 && old.FISScottHP >= -1000)
            return true;
    }
}

isLoading
{           
    vars.OffsetFrame = current.Frame + vars.FrameOffset;
   
    return current.Frame == -1 ||     // Loading
           vars.OffsetFrame == 9 ||   // Frame: wait
           vars.OffsetFrame == 31;    // Frame: wait 2
}