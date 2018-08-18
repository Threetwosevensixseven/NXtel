using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using NXtelData;
using NXtelManager.Attributes;
using NXtelManager.Models;

namespace NXtelManager.Controllers
{
    public class PageController : Controller
    {
        public ActionResult Index()
        {
            var pages = Pages.Load();
            return View(pages);
        }

        public ActionResult Edit(int? ID)
        {
            int id = ID ?? -1;
            var page = Page.Load(id);
            if (id != -1 && page.PageID <= 0)
                return RedirectToAction("Index");
            return View(page);
        }

        [HttpPost]
        [MultipleButton("save")]
        public ActionResult Save(Page Page)
        {
            if (ModelState.IsValid)
            {
                string err;
                if (!Page.Save(Page, out err))
                {
                    ModelState.AddModelError("", err);
                    return View("Edit", Page);
                }
                return RedirectToAction("Index");
            }
            return View("Edit", Page);
        }

        [HttpPost]
        [MultipleButton("delete")]
        public ActionResult Delete(Page Page)
        {
            if (Page == null || Page.PageID <= 0)
                return RedirectToAction("Index");
            string err;
            if (!Page.Delete(out err))
            {
                ModelState.AddModelError("", err);
                return View("Edit", Page);
            }
            return RedirectToAction("Index");
        }
    }
}