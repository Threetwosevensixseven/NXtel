using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Principal;
using System.Text.RegularExpressions;
using System.Web;
using System.Web.Mvc;
using Newtonsoft.Json;
using Newtonsoft.Json.Converters;
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
            var model = new PageIndexModel();
            model.Pages = Pages.LoadStubs();
            model.Permissions = Permissions.Load(User);
            string userID = User.GetUserID();
            model.Pages.ZoneFilter = UserPreferences.Get<int>(userID, "PageIndexZone");
            model.Pages.PrimaryFilter = UserPreferences.Get<bool>(userID, "PageIndexPrimary");
            model.Pages.MineFilter = UserPreferences.Get<bool>(userID, "PageIndexMine");
            return View(model);
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
            {
                model = copy;
                model.Page.Environment = copy.Page.Environment;
            }
            model.SendURL = sendURL;
            Session["PageCopy"] = null;
            if (id != -1 && model.Page.PageID <= 0)
                return RedirectToAction("Index");
            model.Permissions = Permissions.Load(User);
            return View(model);
        }

        [HttpPost]
        [MultipleButton("save")]
        public ActionResult Save(Page Page)
        {
            var perms = Permissions.Load(User);
            bool can = perms.Can(Page);
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
                    model.Permissions = perms;
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
                    model.Permissions = perms;
                    return View("Edit", model);
                }
                if (!can) {
                    ModelState.AddModelError("", "You can't save this page. Check your <a href='"
                        + Url.Action("Index", "Manage")
                        + "' target='_blank'>permissions</a>.");
                    model = new PageEditModel();
                    model.Page = Page;
                    model.Permissions = perms;
                    return View("Edit", model);
                }
                if (Page.PageID <= 0 && Page.OwnerID <= 0)
                    Page.OwnerID = perms.User.UserNo;
                string err;
                if (!Page.Save(Page, out err))
                {
                    ModelState.AddModelError("", err);
                    model = new PageEditModel();
                    model.Page = Page;
                    model.Permissions = perms;
                    return View("Edit", model);
                }
                return RedirectToAction("Index");
            }
            model = new PageEditModel();
            model.Page = Page;
            model.Permissions = perms;
            return View("Edit", model);
        }

        [HttpPost]
        [MultipleButton("delete")]
        public ActionResult Delete(Page Page)
        {
            Page.Fixup();
            var perms = Permissions.Load(User);
            bool can = perms.Can(Page);
            if (!can)
            {
                ModelState.AddModelError("", "You can't delete this page. Check your <a href='"
                    + Url.Action("Index", "Manage")
                    + "' target='_blank'>permissions</a>.");
                var model2 = new PageEditModel();
                model2.Page = Page;
                model2.Permissions = perms;
                return View("Edit", model2);
            }
            PageEditModel model;
            if (Page == null || Page.PageID <= 0)
                return RedirectToAction("Index");
            string err;
            if (!Page.Delete(out err))
            {
                ModelState.AddModelError("", err);
                model = new PageEditModel();
                model.Page = Page;
                model.Permissions = perms;
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

            var model = new PageIndexModel();
            model.Pages = Pages.LoadStubs(ID);
            model.Permissions = Permissions.Load(User);
            ViewBag.ViewZone = zone.Description;
            return View("Index", model);
        }

        public ActionResult Unzoned()
        {
            var model = new PageIndexModel();
            model.Pages = Pages.LoadStubs(-2);
            model.Permissions = Permissions.Load(User);
            ViewBag.ViewZone = "None";
            ViewBag.ViewUnzoned = true;
            return View("Index", model);
        }

        public ActionResult Copy(int ID, string ID2)
        {
            if (ID <= 0)
                return RedirectToAction("Index");
            var model = new PageEditModel();
            model.Copying = true;
            model.Page = Page.Load(ID);
            model.Page.Environment = ID2;
            model.Page.PageID = -1;
            if (string.IsNullOrWhiteSpace(model.Page.Environment))
            {
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
            }
            Session["PageCopy"] = model;
            return RedirectToAction("Edit");
        }
    }
}