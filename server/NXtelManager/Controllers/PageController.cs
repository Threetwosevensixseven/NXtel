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
        public ActionResult Edit(int ID)
        {
            var model = new PageEditModel();
            model.Page = Page.Load(ID);
            if (model.Page.PageID <= 0)
                return RedirectToAction("Index", "Pages");
            model.Editor = Editor.LoadDefault();
            return View(model);
        }
    }
}