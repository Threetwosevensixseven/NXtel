using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TTConv.Classes
{
    public enum Formats
    {
        [Description("Teletext 7-bit format")]
        TT7,

        [Description("Teletext 8-bit format")]
        TT8,

        [Description("Teletext URL format")]
        TTU
    }
}
