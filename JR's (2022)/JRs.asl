state("jr-s-final-release-v.1.0"){} // JR's 1.0.0
state("jr-s-v1-1-1"){} // JR's 1.1.1
state("jr-s-v1-2-2"){} // JR's 1.2.2
state("jr-s-v1-2-3"){} // JR's 1.2.3
state("jr-s-v1-3-0"){} // JR's 1.3.0
state("jr-s-v1-3-1"){} // JR's 1.3.1
state("jrs-v1.4.0"){} // JR's 1.4.0
state("jrs-v1.4.1"){} // JR's 1.4.1 Packed
state("jrs-141"){} // JR's 1.4.1 Unpacked

startup
{
    Assembly.Load(File.ReadAllBytes("Components/uharaClickteamBeta")).CreateInstance("Main");
    //vars.Uhara.EnableDebug();
    vars.Mechlus = false;

    vars.JsonAssembly = Assembly.Load(File.ReadAllBytes("System.Text.Json.dll"));
    vars.JsonNodeType = vars.JsonAssembly.GetType("System.Text.Json.Nodes.JsonNode");

    MethodInfo[] methods = ((Type)vars.JsonNodeType).GetMethods(
    BindingFlags.Public | BindingFlags.Static | BindingFlags.NonPublic);

    vars.JsonNodeParse = methods.First(m =>
    {
        if (m.Name != "Parse")
            return false;

        var p = m.GetParameters();
        return p.Length == 3
            && p[0].ParameterType == typeof(string)
            && p[2].ParameterType.Name == "JsonDocumentOptions";
    });

    Type jsonDocumentOptionsType = vars.JsonAssembly.GetType("System.Text.Json.JsonDocumentOptions");
    vars.DefaultDocOptions = Activator.CreateInstance(jsonDocumentOptionsType);

    refreshRate = 60;

    if (timer.CurrentTimingMethod == TimingMethod.RealTime)
    {        
        var timingMessage = MessageBox.Show (
            "This autosplitter requires Game Time (IGT) to remove loads.\n"+
            "LiveSplit is currently set to show Real Time (RTA).\n"+
            "Would you like to set the timing method to Game Time?",
            "LiveSplit | JR's",
            MessageBoxButtons.YesNo,MessageBoxIcon.Question
        );
        
        if (timingMessage == DialogResult.Yes)
            timer.CurrentTimingMethod = TimingMethod.GameTime;
    }
}

init
{
    vars.Instance = vars.Uhara.CreateTool("ClickteamFusion", "Instance");
    vars.VersionMappings = vars.JsonNodeParse.Invoke(null, new object[]
    {
        File.ReadAllText("Components/JRsVersionMappings.json"),
        //File.ReadAllText("E:\\Autosplitters\\JR's (2022)\\JRsVersionMappings.json"),
        null,
        vars.DefaultDocOptions
    });
    vars.VersionMappings = vars.VersionMappings[game.ProcessName];
}

update
{
    if (vars.Instance == null)
        return;

    vars.Uhara.Update();

    if (current.Frame == old.Frame)
        return;

    if (current.Frame == vars.VersionMappings["Menu Screen"].GetValue<int>())
    {
        // Create TitleBtnClicked watcher
        string mapping = vars.VersionMappings["TitleBtnClicked"].ToString();
        vars.Mechlus = mapping == "MECHLUS";
        if (!vars.Mechlus)
            vars.Instance.WatchAlterableVariable("TitleBtnClicked", mapping, 0);

        // Create FailedToEraseSave watcher
        vars.Instance.WatchVisibility("FailedToEraseSave", vars.VersionMappings["FailedToEraseSave"].ToString());
    }
    else if (old.Frame == vars.VersionMappings["Menu Screen"].GetValue<int>())
    {
        vars.Instance.RemoveOldWatcher("TitleBtnClicked");
        vars.Instance.RemoveOldWatcher("FailedToEraseSave");
    }

    // Create CarrotEnding watcher
    if (current.Frame == vars.VersionMappings["Bonnie's Carrot Craze"].GetValue<int>())
        vars.Instance.WatchAlterableVariable("CarrotEnding", vars.VersionMappings["CarrotEnding"].ToString(), 0);
    else if (old.Frame == vars.VersionMappings["Bonnie's Carrot Craze"].GetValue<int>())
        vars.Instance.RemoveOldWatcher("CarrotEnding");
}

start
{
    // Split when pressing New Game from the Menu Screen
    if (!vars.Mechlus && current.Frame == vars.VersionMappings["Menu Screen"].GetValue<int>())
    {
        // New Game button clicked
        if (current.TitleBtnClicked == 1 && current.TitleBtnClicked != old.TitleBtnClicked)
        {
            // Ensure the runner has erased their save
            if (current.FailedToEraseSave)
            {
                var timingMessage = MessageBox.Show (
                    "It seems you attempted to start a new game without erasing your old save!\n"+
                    "This game's rules require that you erase your save before each New Game run.",
                    "LiveSplit | JR's",
                    MessageBoxButtons.OK, MessageBoxIcon.Error
                );
            }
            else
                return true;
        }
    }
    else if (vars.Mechlus && current.Frame == vars.VersionMappings["Menu Screen"].GetValue<int>() && old.Frame != current.Frame)
        vars.StoredFTES = current.FailedToEraseSave;

    // Mechlus removed the fade in 1.3.X updates, I fucking hate him so much
    if (vars.Mechlus && old.Frame != current.Frame && current.Frame == 26)
    {
        // Ensure the runner has erased their save
        if (vars.StoredFTES)
        {
            var timingMessage = MessageBox.Show (
                "It seems you attempted to start a new game without erasing your old save!\n"+
                "This game's rules require that you erase your save before each New Game run.",
                "LiveSplit | JR's",
                MessageBoxButtons.OK, MessageBoxIcon.Error
            );
        }
        else
            return true;
    }
}

split
{
    // Split at 6AM on Nights 1-5
    if (current.Frame != old.Frame && current.Frame == vars.VersionMappings["6-AM"].GetValue<int>())
        return true;

    // Split at 6AM on Night 6
    if (current.Frame != old.Frame && current.Frame == vars.VersionMappings["Boss 6AM"].GetValue<int>())
        return true;

    // Split at Bonnie's Carrot Craze's True Ending
    if (current.Frame != old.Frame && current.Frame == vars.VersionMappings["BCC Ending"].GetValue<int>())
        return true;

    // Split at 6AM on SR's
    if (current.Frame != old.Frame && current.Frame == vars.VersionMappings["6-AM SR's"].GetValue<int>())
        return true;

    // Split at Bonnie's Carrot Craze's Carrot Ending
    if (current.Frame != old.Frame && current.Frame == vars.VersionMappings["Bonnie's Carrot Craze"].GetValue<int>())
        if (current.CarrotEnding == 1)
            return true;
}

isLoading
{
    return current.Frame == -1;
}