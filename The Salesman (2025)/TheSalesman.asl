state("The Salesman"){}

startup
{
    // Load Uhara and setup settings
	Assembly.Load(File.ReadAllBytes("Components/uhara9")).CreateInstance("Main");
	settings.Add("splitDays", true, "Split at the end each day");
	settings.Add("iL", false, "Start at the beginning of a day (IL)");
}

init
{
    // Initialize Uhara Tools
    vars.JitSave = vars.Uhara.CreateTool("Unity", "DotNet", "JitSave");
	vars.Utils = vars.Uhara.CreateTool("Unity", "Utils");
    vars.Instance = vars.Uhara.CreateTool("Unity", "DotNet", "Instance");

    // List meant for preventing double splits
    vars.DaysSplit = new List<int>();

    // Variable Initialization to avoid null references
    current.ActiveScene = "";
    current.funcSetAlpha = null;

    // Watch whether or not the player can move
    vars.Instance.Watch<bool>("CanPlayerMove", "FirstPersonController", "CanMove");

    // Watch whether or not the player can scroll through the phone
    vars.Instance.Watch<bool>("CanPlayerScroll", "PhoneScroll", "hasVid");

    // Watch current Dialogue Node name for the MERCY ending and the start split
    var ptr_dialogueNode = vars.Instance.Get("NarrativeHandler", "dialogueRunner", "dialogue", "vm", "state", "currentNodeName", "0x14");
    vars.Resolver.WatchString("DialogueNode", ptr_dialogueNode.Base, ptr_dialogueNode.Offsets);

    // Watch for calls to SetAlpha for the MERCY ending
	vars.JitSave.SetOuter("UnityEngine.UIModule.dll", "UnityEngine");
    IntPtr SetAlpha = vars.JitSave.AddFlag("CanvasRenderer", "SetAlpha");
    vars.JitSave.ProcessQueue();
    vars.Resolver.Watch<ulong>("funcSetAlpha", SetAlpha);
}

update
{
    vars.Uhara.Update();

    // Update ActiveScene/LoadingScene so we can have an old variable to compare against in split
	current.ActiveScene = vars.Utils.GetActiveSceneName() ?? current.ActiveScene;
	current.LoadingScene = vars.Utils.GetLoadingSceneName() ?? current.LoadingScene;
}

start
{
    if (vars.DaysSplit.Count > 0)
        vars.DaysSplit.Clear();

    // Start if the player gains control at the start of Days 2-6 (IL Only)
    if (settings["iL"] && current.CanPlayerMove && !old.CanPlayerMove)
    {
        List<string> days = new List<string>()
        {
            "Day_2", "Day_3", "Day_4", "Day_5", "Day_6"
        };

        if (days.Contains(old.Dialogue))
            return true;
    }

    // Start if the player is allowed to doomscroll at the start of Day 7 (IL Only)
    if (settings["iL"] && current.hasVid && !old.hasVid && current.DialogueNode == "Day_7")
        return true;

    // Start if the player gains control at the start of Day 1
    return current.CanPlayerMove && !old.CanPlayerMove && old.DialogueNode == "Day_1";
}

split
{
    // New Day Split
    if (settings["splitDays"] && current.ActiveScene != old.ActiveScene)
    {
        // Check if the scene is a day
        if (current.ActiveScene.StartsWith("Day "))
        {
            // Only split if it's Day 2-7
            int day = int.Parse(current.ActiveScene.Split(' ')[1]);
            if (day > 1 && day <= 7 && !vars.DaysSplit.Contains(day))
            {
                vars.DaysSplit.Add(day);
                return true;
            }
        }
    }

    // MERCY Ending Split
    if (current.ActiveScene == "Day 7" && current.DialogueNode == "Day_7_No" && current.funcSetAlpha != old.funcSetAlpha)
        return true;
}

isLoading
{
    // Generic loading detection
	return current.ActiveScene != current.LoadingScene;
}

reset
{
    // Reset when returning to the Main Menu, this can be disabled if desired
	return current.ActiveScene == "Main Menu" && current.ActiveScene != old.ActiveScene;
}