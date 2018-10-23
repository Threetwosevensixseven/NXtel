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
    [Authorize(Roles = "PageEditor")]
    public class PageController : Controller
    {
        public ActionResult Index()
        {
            var pages = Pages.LoadStubs();
            return View(pages);
        }

        public ActionResult Edit(int? ID)
        {
            int id = ID ?? -1;
            var model = new PageEditModel();
            model.Page = Page.Load(id);

            var flat = model.Page.FlattenTemplates();
            string x = "";
            foreach (var t in flat)
                x += t.TemplateID + ": " + t.Description + "\r\n";



            if (id != -1 && model.Page.PageID <= 0)
                return RedirectToAction("Index");
            return View(model);
        }

        [HttpPost]
        [MultipleButton("save")]
        public ActionResult Save(Page Page)
        {
            PageEditModel model;
            Page.Fixup();
            if (ModelState.IsValid)
            {
                string err;
                if (!Page.Save(Page, out err))
                {
                    ModelState.AddModelError("", err);
                    model = new PageEditModel();
                    model.Page = Page;
                    return View("Edit", model);
                }
                return RedirectToAction("Index");
            }
            model = new PageEditModel();
            model.Page = Page;
            return View("Edit", model);
        }

        [HttpPost]
        [MultipleButton("delete")]
        public ActionResult Delete(Page Page)
        {
            PageEditModel model;
            if (Page == null || Page.PageID <= 0)
                return RedirectToAction("Index");
            string err;
            if (!Page.Delete(out err))
            {
                ModelState.AddModelError("", err);
                model = new PageEditModel();
                model.Page = Page;
                return View("Edit", model);
            }
            return RedirectToAction("Index");
        }
    }
}