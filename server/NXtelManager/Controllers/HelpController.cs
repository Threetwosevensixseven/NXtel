using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
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
                return new HttpNotFoundResult();
            help.LoadMarkdown();
            return View(help);
        }

        public ActionResult Media(string ID, string ID2)
        {
            var bytes = HelpItem.LoadMedia(ID2, ID);
            if (bytes == null || bytes.Length == 0)
                return new HttpNotFoundResult();
            return base.File(bytes, "application/octet-stream");
        }
    }
}