using System;
using System.Collections.Generic;
using System.Linq;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Rendering;
using NXtelData;

namespace NXtelManager.Controllers
{
    public class HelpController : Controller
    {
        public ActionResult Topics()
        {
            var items = HelpItems.Load();
            return View(items);
        }

        public ActionResult Topic(string ID)
        {
            var items = HelpItems.Load();
            string id = (ID ?? "").Trim().ToLower();
            var help = items.FirstOrDefault(h => id == h.Slug.ToLower());
            if (help == null)
                return new NotFoundResult();
            help.LoadMarkdown();
            return View(help);
        }

        public ActionResult Media(string ID, string ID2)
        {
            var bytes = HelpItem.LoadMedia(ID2, ID);
            if (bytes == null || bytes.Length == 0)
                return new NotFoundResult();
            return base.File(bytes, "application/octet-stream");
        }
    }
}