using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using NXtelData;

namespace NXtelManager.Models
{
    public class FileIndexModel
    {
        public TSFiles Files { get; set; }
        public Permissions Permissions { get; set; }
    }

    public class FileEditModel
    {
        public TSFile File { get; set; }
        public IEnumerable<SelectListItem> Owners { get; set; }
        public Permissions Permissions { get; set; }
        public bool Copying { get; set; }
        public string OldKey { get; set; }

        public FileEditModel()
        {
            Owners = GetSelectList(NXtelData.Users.LoadOwners());
            Permissions = new Permissions();
        }

        public IEnumerable<SelectListItem> GetSelectList(Users Items)
        {
            var rv = new List<SelectListItem>();
            rv.Add(new SelectListItem { Value = "-1", Text = "Unowned" });
            if (Items == null) return rv;
            foreach (var item in Items)
            {
                rv.Add(new SelectListItem
                {
                    Value = item.UserNo.ToString(),
                    Text = (item.Name ?? "").Trim()
                });
            }
            return rv;
        }

        public string GetOwner(int OwnerID)
        {
            var owner = Owners.FirstOrDefault(o => o.Value == OwnerID.ToString());
            return owner == null ? "Unowned" : owner.Text;
        }

    }
}