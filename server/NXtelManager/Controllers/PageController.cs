using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using NXtelData;
using NXtelManager.Models;

namespace NXtelManager.Controllers
{
    public class PageController : Controller
    {
        public ActionResult Edit(int? ID)
        {
            int id = ID ?? -1;
            var model = new PageEditModel();
            model.Page = Page.Load(id);
            if (id != -1 && model.Page.PageID <= 0)
                return RedirectToAction("Index", "Pages");
            model.Editor = Editor.LoadDefault();
            return View(model);
        }

        [HttpPost]
        public ActionResult Edit(Page Page)
        {
            if (ModelState.IsValid)
            {
                Page.Save(Page);
            }
            var model = new PageEditModel();
            model.Page = Page;
            model.Editor = Editor.LoadDefault();
            return View(model);
        }
    }
}