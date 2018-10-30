using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using NXtelData;

namespace NXtelManager.Models
{
    public class UserEditModel
    {
        public User User { get; set; }
        public IEnumerable<SelectListItem> Roles { get; set; }
        public string SelectedRolesJSON { get; set; }

        public UserEditModel()
        {
            Roles = GetSelectList(NXtelData.Roles.Load());
            SelectedRolesJSON = "";
        }

        public IEnumerable<SelectListItem> GetSelectList(Roles Items)
        {
            var rv = new List<SelectListItem>();
            if (Items == null) return rv;
            foreach (var item in Items)
            {
                rv.Add(new SelectListItem
                {
                    Value = item.ID.ToString(),
                    Text = (item.Name ?? "").Trim()
                });
            }
            return rv;
        }

        public void SetRoles()
        {
            if (User == null)
                return;
            User.Roles = new List<string>();
            foreach (var rr in (SelectedRolesJSON ?? "").Split(','))
            {
                var role = Roles.FirstOrDefault(r => r.Text == rr.Trim());
                if (role != null)
                    User.Roles.Add(role.Text);
            }
        }
    }
}