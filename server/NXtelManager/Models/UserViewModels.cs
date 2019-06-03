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
        public IEnumerable<SelectListItem> Templates { get; set; }
        public Templates TemplateList { get; set; }
        public IEnumerable<SelectListItem> Zones { get; set; }
        public Zones ZoneList { get; set; }
        public IEnumerable<SelectListItem> Files { get; set; }
        public TSFiles FileList { get; set; }
        public string SelectedRolesJSON { get; set; }
        public string SelectedPermissions { get; set; }

        public UserEditModel()
        {
            Roles = GetSelectList(NXtelData.Roles.Load());
            TemplateList = NXtelData.Templates.LoadStubs();
            Templates = GetSelectList(TemplateList);
            ZoneList = NXtelData.Zones.Load();
            Zones = GetSelectList(ZoneList);
            FileList = TSFiles.LoadStubs();
            Files = GetSelectList(FileList);
            SelectedRolesJSON = SelectedPermissions = "";
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

        public IEnumerable<SelectListItem> GetSelectList(Zones Items)
        {
            var rv = new List<SelectListItem>();
            if (Items == null) return rv;
            foreach (var item in Items)
            {
                rv.Add(new SelectListItem
                {
                    Value = item.ID.ToString(),
                    Text = (item.Description ?? "").Trim()
                });
            }
            return rv;
        }
        public IEnumerable<SelectListItem> GetSelectList(TSFiles Items)
        {
            var rv = new List<SelectListItem>();
            if (Items == null) return rv;
            foreach (var item in Items)
            {
                rv.Add(new SelectListItem
                {
                    Value = item.TeleSoftwareID.ToString(),
                    Text = (item.Key ?? "").Trim()
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

            // Set Permissions
            var perms = new List<Permission>();
            try
            {
                if (string.IsNullOrWhiteSpace(this.SelectedPermissions))
                    this.SelectedPermissions = "{}";
                perms = Newtonsoft.Json.JsonConvert.DeserializeObject<List<Permission>>(this.SelectedPermissions);
            }
            catch { }
            User.Permissions = new Permissions();
            User.Permissions.AddRange(perms.OrderBy(r => r.Sort));
        }
    }
}