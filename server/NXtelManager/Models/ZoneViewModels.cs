using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using NXtelData;

namespace NXtelManager.Models
{
    public class ZoneEditModel
    {
        public Zone Zone { get; set; }
        public Permissions Permissions { get; set; }
        public Pages Pages { get; set; }
        public bool Copying { get; set; }
        public string OldDescription { get; set; }

        public ZoneEditModel()
        {
            Permissions = new Permissions();
            Pages = new Pages();
        }
    }
}