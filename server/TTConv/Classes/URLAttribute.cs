using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TTConv.Classes
{
    public class URLAttribute : Attribute
    {
        public string URL {get; set;}

        public URLAttribute(string URL)
        {
            this.URL = URL; 
        }
    }
}
