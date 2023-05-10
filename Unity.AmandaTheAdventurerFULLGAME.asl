// Amanda The Adventurer (FULL GAME) Autosplitter by NERS

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
    vars.inGame = false;
    vars.Helper.TryLoad = (Func<dynamic, bool>)(mono =>
    {
        vars.Helper["crouchLerp"]       = mono.Make<float>("PlayerInputController", "_instance", "crouchLerp");
        vars.Helper["endCamClamp"]      = mono.Make<float>("PlayerInputController", "_instance", "EndCamClamp"); // used for the meat ending, it's the only place where PlayerInputController.Instance.EndCamClamp is 100 instead of 45
        vars.Helper["inCredits"]        = mono.Make<bool>("CreditsMenu", "_instance", 0x10, 0x39);
        vars.Helper["autosaving"]       = mono.Make<bool>("SaveManager", "_instance", "AutoSaveIcon", 0x10, 0x39);     // used for the
        vars.Helper["lightOutParticle"] = mono.Make<bool>("GameManager", "_instance", "LightOutParticle", 0x10, 0x56); // monster ending
        return true;
    });
}

start
{
    return vars.inGame && ((old.velocity == 0 && current.velocity != 0) || (old.crouchLerp == 0 && current.crouchLerp != 0));
}

update
{
    current.scene = vars.Helper.Scenes.Active.Index;
    if(old.scene == 0 && current.scene == 1)
      vars.inGame = true;
}

split
{
    if(!old.inCredits && current.inCredits
        || old.endCamClamp == 45 && current.endCamClamp == 100
        || !old.autosaving && current.autosaving && current.lightOutParticle)
    {
        vars.inGame = false;
        timer.IsGameTimePaused = true;
        return settings["endings"];
    }
}

isLoading
{
    if(!vars.inGame || !timer.IsGameTimePaused)
        return;

    if(old.velocity == 0 && current.velocity != 0 || old.crouchLerp == 0 && current.crouchLerp != 0)
        timer.IsGameTimePaused = false;
}
