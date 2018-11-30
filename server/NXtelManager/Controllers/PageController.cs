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
    [Authorize(Roles = "Page Editor")]
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
                new TSEncoder().Encode(ref Page);
                if (Page.NormalisedFromPageFrameNo > Page.NormalisedToPageFrameNo)
                {
                    ModelState.AddModelError("", "To Page No/Frame cannot be before From Page No/Frame.");
                    model = new PageEditModel();
                    model.Page = Page;
                    return View("Edit", model);
                }
                if (!Page.IsPageRangeValid())
                {
                    if (Page.PageAndFrame == Page.ToPageAndFrame)
                    {
                        ModelState.AddModelError("", "An existing page range overlaps with page "
                            + Page.PageAndFrame + ".");
                    }
                    else
                    {
                        ModelState.AddModelError("", "An existing page range overlaps with the range "
                            + Page.PageAndFrame + " to " + Page.ToPageAndFrame + ".");
                    }
                    model = new PageEditModel();
                    model.Page = Page;
                    return View("Edit", model);
                }
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

        public ActionResult Route(PageRouteViewModel Model)
        {
            if (Model == null)
                Model = new PageRouteViewModel();
            var route = NXtelData.Route.GetRoute(Model.CurrentPageNo, Model.CurrentFrame, 
                Model.PageNo, Model.Frame, Model.NextPage, Model.NextFrame);
            Model.PageID = route.GoesToPageID;
            Model.GoesToPageFrameDesc = route.GoesToPageFrameDesc;
            return Json(Model, JsonRequestBehavior.AllowGet);
        }

    }
}