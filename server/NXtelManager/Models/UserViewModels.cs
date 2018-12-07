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
        public string SelectedPageRanges { get; set; }

        public UserEditModel()
        {
            Roles = GetSelectList(NXtelData.Roles.Load());
            SelectedRolesJSON = SelectedPageRanges = "";
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

        public void Fixup()
        {
            // Set Roles
            if (User == null)
                return;
            User.Roles = new List<string>();
            foreach (var rr in (SelectedRolesJSON ?? "").Split(','))
            {
                var role = Roles.FirstOrDefault(r => r.Text == rr.Trim());
                if (role != null)
                    User.Roles.Add(role.Text);
            }

            // Set Page Ranges
            var prs = new List<UserPageRange>();
            foreach (var pr in (this.SelectedPageRanges ?? "").Split(';'))
            {
                var fields = (pr ?? "").Split(',');
                int id = 0, from = 0, to = 0;
                int.TryParse(fields[0], out id);
                if (fields.Length > 1)
                    int.TryParse(fields[1], out from);
                if (fields.Length > 2)
                    int.TryParse(fields[2], out to);
                if (from > 0 && to > 0)
                    prs.Add(new UserPageRange(id, from, to));
            }
            User.PageRanges = new UserPageRanges();
            User.PageRanges.AddRange(prs.OrderBy(r => r.Sort));
        }
    }
}