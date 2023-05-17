// Amanda The Adventurer (FULL GAME) Autosplitter & Load Remover by NERS

state("Amanda The Adventurer")
{
    float velocity : "UnityPlayer.dll", 0x01AF2EC8, 0x38, 0x220, 0x20, 0xD00, 0x0, 0x828, 0xF0; // i had to find a pointer for this, it's impossible to access the player's rigidbody velocity with asl-help
}

startup
{
    Assembly.Load(File.ReadAllBytes("Components/asl-help")).CreateInstance("Unity");
    vars.Helper.GameName = "Amanda The Adventurer";
    vars.Helper.LoadSceneManager = true;
    vars.Helper.AlertLoadless();

    settings.Add("endings", true, "Split on reaching any ending");
    settings.SetToolTip("endings", "The timer will automatically pause and resume between endings if it's set to Game Time\nregardless of this setting.");
}

init
{
    vars.inGame = 999;
    vars.quitToTitle = 0;
    vars.Helper.TryLoad = (Func<dynamic, bool>)(mono =>
    {
        vars.Helper["sceneLoading"] = mono.Make<int>("SceneLoadManager", "_instance", "sceneLoadCoroutine"); // sometimes bools wouldn't work with these for some reason
        vars.Helper["fading"]       = mono.Make<int>("PlayerCamera", "_instance", "fadeRoutine");            // so i changed them 4head
        vars.Helper["inCredits"]    = mono.Make<bool>("CreditsMenu", "_instance", 0x10, 0x39);
        vars.Helper["paused"]       = mono.Make<bool>("MenuManager", "_instance", "GameIsPaused");
        
        vars.Helper["lightOutParticle"] = mono.Make<bool>("GameManager", "_instance", "LightOutParticle", 0x10, 0x56); // used for the monster ending
        vars.Helper["endCamClamp"]      = mono.Make<float>("PlayerInputController", "_instance", "EndCamClamp"); // used for the meat ending, it's the only place where PlayerInputController.Instance.EndCamClamp is 100 instead of 45
        vars.Helper["crouchLerp"]       = mono.Make<float>("PlayerInputController", "_instance", "crouchLerp");
        return true;
    });

    print("[Amanda The Adventurer] Game detected. Module memory size: " + modules.First().ModuleMemorySize);
}

start
{
    return vars.inGame == 1 && (old.velocity == 0 && current.velocity != 0 || old.crouchLerp == 0 && current.crouchLerp != 0);
}

update
{
    current.scene = vars.Helper.Scenes.Active.Index;
    if(current.scene == 1)
    {
        if(old.scene == 0 || vars.inGame == 999) vars.inGame = 1;
        if(old.paused && !current.paused && current.sceneLoading != 0)
        {
            vars.quitToTitle = 1;
            vars.inGame = 0;
        }
        else if(vars.quitToTitle == 1 && vars.inGame == 1 && old.fading != 0 && current.fading == 0) vars.quitToTitle = 2;

        if(!timer.IsGameTimePaused)
        {
            if(current.paused || vars.quitToTitle != 0 || vars.inGame == 0) timer.IsGameTimePaused = true;
        }
        else
        {
            if(vars.inGame == 1 && (old.paused && !current.paused || vars.quitToTitle == 0 && (old.velocity == 0 && current.velocity != 0 || old.crouchLerp == 0 && current.crouchLerp != 0) || vars.quitToTitle == 2))
            {
                timer.IsGameTimePaused = false;
                vars.quitToTitle = 0;
            }
        }
    }
}

split
{
    if(!timer.IsGameTimePaused && vars.inGame == 1 &&
    (!old.inCredits && current.inCredits
    || old.endCamClamp == 45 && current.endCamClamp == 100
    || old.sceneLoading == 0 && current.sceneLoading != 0 && current.lightOutParticle))
    {
        vars.inGame = 0;
        timer.IsGameTimePaused = true;
        return settings["endings"];
    }
}
