using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using NXtelData;

namespace NXtelManager.Controllers
{
    [Authorize]
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
    }
}