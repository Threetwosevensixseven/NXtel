using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace NXtelData
{
    public static class ZoneExtensions
    {
        public static IEnumerable<SelectListItem> GetSelectList(this Zones Zones, bool Any = true, bool Unzoned = true)
        {
            var rv = new List<SelectListItem>();
            if (Zones == null) return rv;
            if (Any) rv.Add(new SelectListItem { Value = "-1", Text = "Any" });
            if (Unzoned) rv.Add(new SelectListItem { Value = "-2", Text = "Unzoned" });
            foreach (var item in Zones)
            {
                rv.Add(new SelectListItem
                {
                    Value = item.ID.ToString(),
                    Text = (item.Description ?? "").Trim()
                });
            }
            return rv;
        }
    }
}