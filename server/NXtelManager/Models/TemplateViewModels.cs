using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using NXtelData;

namespace NXtelManager.Models
{
    public class TemplateEditModel
    {
        public Template Template { get; set; }
        public IEnumerable<SelectListItem> Templates { get; set; }
        public bool SendURL { get; set; }
        public int CopyTemplateID { get; set; }
        public bool Copying { get; set; }
        public string OldDescription { get; set; }
        public IEnumerable<SelectListItem> Owners { get; set; }

        public TemplateEditModel()
        {
            Templates = GetSelectList(NXtelData.Templates.LoadStubs());
            Owners = GetSelectList(NXtelData.Users.LoadOwners());
        }

        public IEnumerable<SelectListItem> GetSelectList(Templates Items)
        {
            var rv = new List<SelectListItem>();
            if (Items == null) return rv;
            foreach (var item in Items)
            {
                rv.Add(new SelectListItem
                {
                    Value = item.TemplateID.ToString(),
                    Text = (item.Description ?? "").Trim()
                });
            }
            return rv;
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