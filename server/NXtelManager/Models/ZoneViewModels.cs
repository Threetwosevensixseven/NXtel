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

    public class ZoneLookupModel
    {
        public int id { get; set; }
        public string text { get; set; }

        public ZoneLookupModel()
        {
            id = -1;
            text = "";
        }

        public ZoneLookupModel(Zone Zone) 
            :this()
        {
            if (Zone != null)
            {
                id = Zone.ID;
                text = Zone.Description;
            }
        }

        public static List<ZoneLookupModel> Convert(Zones Zones)
        {
            var rv = new List<ZoneLookupModel>();
            foreach (var zone in Zones ?? new Zones())
                rv.Add(new ZoneLookupModel(zone));
            return rv;
        }
    }
}