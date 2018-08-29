﻿using System;
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

        public PageEditModel()
        {
            Templates = GetSelectList(NXtelData.Templates.Load());
            Routes = GetSelectList(NXtelData.Routes.MasterList);
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
    }
}