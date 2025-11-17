state("FNaF_World"){} // Steam
state("fnaf-world"){} // Gamejolt

startup
{
    Assembly.Load(File.ReadAllBytes("Components/uharaClickteamBeta")).CreateInstance("Main");
    //vars.Uhara.EnableDebug();

    settings.Add("Normal",   false, "Normal Mode Ending");
    settings.Add("Hard",     false, "Hard Mode Ending");
    settings.Add("Fourth",   false, "Fourth Glitch Ending");
        settings.Add("Fourth-Instant",  false, "Split as soon as you enter the Fourth Glitch (100% / 157%)", "Fourth");
    settings.Add("Chip",     false, "Chipper Ending");
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

    refreshRate = 60;

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
}

start 
{  
    vars.OffsetFrame = current.Frame + vars.FrameOffset;
    return vars.OffsetFrame == 27 && old.Frame != current.Frame;
}

update
{
    if (vars.Instance == null)
        return;

    vars.Uhara.Update();

    if (current.Frame == old.Frame)
        return;
    
    vars.OffsetFrame = current.Frame + vars.FrameOffset;
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

    // Create New Character watcher
    if (vars.OffsetFrame == 43)
        vars.Instance.WatchAnimation("NewCharacter", "Active");
    else if (oldOffsetFrame == 43)
        vars.Instance.RemoveOldWatcher("NewCharacter");
}

split
{
    vars.OffsetFrame = current.Frame + vars.FrameOffset;

    // Normal Mode Ending
    if (settings["Normal"] && vars.OffsetFrame == 20 && current.Dialogue == 7 && old.Dialogue != current.Dialogue)
        return true;

    // Hard Mode Ending
    if (settings["Hard"] && vars.OffsetFrame == 21 && current.Dialogue == 7 && old.Dialogue != current.Dialogue)
        return true;

    // Chipper Ending
    if (settings["Chip"] && vars.OffsetFrame == 22 && current.Dialogue == 7 && old.Dialogue != current.Dialogue)
        return true;

    // Lost Ending
    if (settings["Fourth"] && vars.OffsetFrame == 15)
    {
        if (!settings["Fourth-Instant"] && current.LostDialogue == 3 && old.LostDialogue != current.LostDialogue)
            return true;
        else if (settings["Fourth-Instant"] && old.Frame != current.Frame)
            return true;
    }

    // Clock Ending
    if (settings["Clock"] && vars.OffsetFrame == 21 && old.Frame != current.Frame)
        return true;

    // Universe Ending
    if (settings["Universe"] && vars.OffsetFrame == 30 && old.Frame != current.Frame)
        return true;

    // Rainbow Ending
    if (settings["Rainbow"] && vars.OffsetFrame == 45 && old.Frame != current.Frame)
        return true;

    // New Character Split
    if (settings["Chars"] && vars.OffsetFrame == 43 && old.Frame != current.Frame)
    {
        if (current.NewCharacter > 0)
            current.NewCharacter -= 11; // Adjust to skip built-in animations
        current.NewCharacter++; // Adjust to 1-based index
        return settings["Char-" + current.NewCharacter.ToString()];
    }
}

isLoading
{           
    vars.OffsetFrame = current.Frame + vars.FrameOffset;
   
    return current.Frame == -1 ||     // Loading
           vars.OffsetFrame == 9 ||   // Frame: wait
           vars.OffsetFrame == 31;    // Frame: wait 2
}