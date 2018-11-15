using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using NXtelData;

namespace NXtelManager.Models
{
    public class PageEditModel
    {
        public Page Page { get; set; }
        public IEnumerable<SelectListItem> Templates { get; set; }
        public IEnumerable<SelectListItem> Routes { get; set; }
        public IEnumerable<SelectListItem> Files { get; set; }

        public PageEditModel()
        {
            Templates = GetSelectList(NXtelData.Templates.LoadStubs());
            Routes = GetSelectList(NXtelData.Routes.MasterList);
            Files = GetSelectList(NXtelData.TSFiles.LoadStubs());
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

        public IEnumerable<SelectListItem> GetSelectList(Routes Items)
        {
            var rv = new List<SelectListItem>();
            if (Items == null) return rv;
            foreach (var item in Items)
            {
                rv.Add(new SelectListItem
                {
                    Value = item.KeyCode.ToString(),
                    Text = (item.Description ?? "").Trim()
                });
            }
            return rv;
        }

        public IEnumerable<SelectListItem> GetSelectList(TSFiles Files)
        {
            var rv = new List<SelectListItem>();
            rv.Add(new SelectListItem { Value = "-1", Text = "None" });
            if (Files == null) return rv;
            foreach (var item in Files)
            {
                rv.Add(new SelectListItem
                {
                    Value = item.TeleSoftwareID.ToString(),
                    Text = (item.Key ?? "").Trim()
                });
            }
            return rv;
        }
    }
}