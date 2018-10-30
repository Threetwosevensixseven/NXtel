using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace NXtelData
{
    public class Role
    {
        public string ID { get; set; }
        public string Name { get; set; }

        public Role()
        {
            ID = Name = "";
        }
    }
}
