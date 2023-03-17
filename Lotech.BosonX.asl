// Boson X Autosplitter by NERS

state("bosonx")
{
    int frames  : "gameoverlayrenderer.dll", 0x107CD8;
    int frames2 : "atioglxx.dll",            0x3816F8C;
    // had to find 2 pointers because sometimes one of them would be invalid for some reason

    byte    started       : "bosonx.exe", 0x11DB24, 0x54, 0xBC, 0x2C;
    string8 percentageStr : "bosonx.exe", 0x11D918, 0x48, 0x10, 0x800, 0x10, 0x8, 0x4E4, 0x2C;
}

startup
{
    print("[Boson X] Autosplitter starting up");

    settings.Add("100percent", true, "Split on reaching 100% completion on each stage");
    settings.Add("200percent", true, "Split on reaching 200% completion on each stage");

    vars.percentage    = 0.00d;
    vars.percentageOld = 0.00d;
    vars.framesOnStart = 0;
}

init
{
    int mms = modules.First().ModuleMemorySize; // 1204224 for v1.2.5
    print("[Boson X] Game detected - module memory size: " + mms);
}

update
{
    try 
    { 
        vars.percentage    = Double.Parse(current.percentageStr); 
        vars.percentageOld = Double.Parse(old.percentageStr); 
    }
    catch(Exception e) {} // this is just so the console doesn't get spammed when the string is a random value (when you're not in a stage or you're dead)

    if(current.started == (old.started + 1)) // just started a stage
    {
        if(current.frames > 0)
            vars.framesOnStart = current.frames;

        if(current.frames2 > 0)
            vars.framesOnStart = current.frames2; 
    }
}

start
{
    // add a delay because you start in the air and timer starts when you touch the ground
    // the "frames" pointer counts up faster than "frames2" so that's why the delay values are different
    return 
        vars.framesOnStart > 0 &&
        ((current.frames >= (vars.framesOnStart + 135)) ||
        (current.frames2 >= (vars.framesOnStart + 75)));
}

split
{
    return
        (settings["100percent"] && vars.percentage >= 100.00 && vars.percentage <= 105.00 && vars.percentageOld < 100.00) ||
        (settings["200percent"] && vars.percentage >= 200.00 && vars.percentage <= 205.00 && vars.percentageOld < 200.00);
}

onReset
{
    vars.framesOnStart = 0;
}