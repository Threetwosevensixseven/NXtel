using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Principal;
using System.Text.RegularExpressions;
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
            string id = User.GetUserID();
            var pages = Pages.LoadStubs();
            string userID = User.GetUserID();
            pages.ZoneFilter = UserPreferences.Get<int>(userID, "PageIndexZone");
            pages.PrimaryFilter = UserPreferences.Get<bool>(userID, "PageIndexPrimary");
            return View(pages);
        }

        public ActionResult Edit(int? ID, string ID2)
        {
            int id = ID ?? -1;
            var model = new PageEditModel();
            bool sendURL = id == -2;
            if (sendURL) id = -1;
            var copy = Session["PageCopy"] as PageEditModel;
            if (copy == null)
                model.Page = Page.Load(id);
            else
                model = copy;
            model.SendURL = sendURL;
            Session["PageCopy"] = null;
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

        public ActionResult Zone(int ID)
        {
            if (ID <= 0)
                return RedirectToAction("Index", "Zone");
            var zone = NXtelData.Zone.Load(ID);
            if (zone == null || zone.ID <= 0)
                return RedirectToAction("Index", "Zone");
            var pages = Pages.LoadStubs(ID);
            ViewBag.ViewZone = zone.Description;
            return View("Index", pages);
        }

        public ActionResult Unzoned()
        {
            var pages = Pages.LoadStubs(-2);
            ViewBag.ViewZone = "None";
            ViewBag.ViewUnzoned = true;
            return View("Index", pages);
        }

        public ActionResult Copy(int ID)
        {
            if (ID <= 0)
                return RedirectToAction("Index");
               var model = new PageEditModel();
            model.Copying = true;
            model.Page = Page.Load(ID);
            model.Page.PageID = -1;
            model.OldTitle = model.Page.Title;
            model.Page.Title = "";
            model.OldPageNo = model.Page.PageNo.ToString();
            model.Page.PageNo = 0;
            model.OldFrame = model.Page.Frame;
            model.Page.Frame = "";
            model.OldToPageNo = model.Page.ToPageNo.ToString();
            model.Page.ToPageNo = 0;
            model.OldToFrame = model.Page.ToFrame;
            model.Page.ToFrame = "";
            Session["PageCopy"] = model;
            return RedirectToAction("Edit");
        }
    }
}