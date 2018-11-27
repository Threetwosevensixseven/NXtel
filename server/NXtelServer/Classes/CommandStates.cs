using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace NXtelServer.Classes
{
    public enum CommandStates
    {
        RegularRouting = 0,
        InsideStarPageCommand = 1,
        InsideFastTextCommand = 2
    }
}
