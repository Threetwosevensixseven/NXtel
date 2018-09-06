using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace NXtelData
{
    public static class Character
    {
        public static byte Substitute(char Unicode)
        {
            if (Unicode == '’')
                return Convert.ToByte("'"[0]);
            else if (Unicode == '‘')
                return Convert.ToByte("'"[0]);
            return Convert.ToByte('\0');
        }
    }
}
