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
    public class ZoneController : Controller
    {
        public ActionResult Index()
        {
            var zones = Zones.Load();
            return View(zones);
        }

        public ActionResult View(int? ID)
        {
            int id = ID ?? -1;
            var model = new ZoneEditModel();
            model.Zone = Zone.Load(id);
            if (id != -1 && model.Zone.ID <= 0)
                return RedirectToAction("Index");
            return View(model);
        }

        [Authorize(Roles = "Admin,Page Editor")]
        public ActionResult Edit(int? ID, string ID2)
        {
            int id = ID ?? -1;
            var model = new ZoneEditModel();
            var copy = Session["ZoneCopy"] as ZoneEditModel;
            if (copy == null)
                model.Zone = Zone.Load(id);
            else
            {
                model = copy;
                model.Zone.Environment = copy.Zone.Environment;
            }
            Session["ZoneCopy"] = null;
            if (id != -1 && model.Zone.ID <= 0)
                return RedirectToAction("Index");
            model.Permissions = Permissions.Load(User);
            model.Pages = Pages.LoadStubs(-1, string.Join(",", model.Permissions.ZoneIDs));
            return View(model);
        }

        [HttpPost]
        [MultipleButton("delete")]
        [Authorize(Roles = "Admin")]
        public ActionResult Delete(Zone Zone)
        {
            ZoneEditModel model;
            if (Zone == null || Zone.ID <= 0)
                return RedirectToAction("Index");
            string err;
            if (!Zone.Delete(out err))
            {
                ModelState.AddModelError("", err);
                model = new ZoneEditModel();
                model.Zone = Zone;
                return View("Edit", model);
            }
            return RedirectToAction("Index");
        }

        [HttpPost]
        [MultipleButton("Save")]
        [Authorize(Roles = "Admin")]
        public ActionResult Save(ZoneEditModel Model)
        {
            if (ModelState.IsValid)
            {
                string err;
                if (!Zone.Save(Model.Zone, out err))
                {
                    return View("Edit", Model);
                }
                return RedirectToAction("Index");
            }
            return View("Edit", Model);
        }

        [Authorize(Roles = "Admin")]
        public ActionResult Copy(int ID, string ID2)
        {
            if (ID <= 0)
                return RedirectToAction("Index");
            var model = new ZoneEditModel();
            model.Copying = true;
            model.Zone = Zone.Load(ID);
            model.Zone.Environment = ID2;
            model.Zone.ID = -1;
            if (string.IsNullOrWhiteSpace(model.Zone.Environment))
            {
                model.OldDescription = model.Zone.Description;
                model.Zone.Description = "";
            }
            Session["ZoneCopy"] = model;
            return RedirectToAction("Edit");
        }
    }
}