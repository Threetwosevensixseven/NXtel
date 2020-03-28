using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using NXtelData;
using NXtelManager.Models;

namespace NXtelManager.Controllers
{
    [Authorize(Roles = "Admin")]
    public class NoticeController : Controller
    {
        public ActionResult Index()
        {
            var model = new NoticeIndexModel();
            model.Notices = Notices.Load();
            model.Zone = Zone.Load(DBSettings.NoticeZone);
            return View(model);
        }

        [HttpPost]
        public JsonResult SaveZone(Zone Zone)
        {
            bool rv = Zone != null;
            if (rv)
                DBSettings.NoticeZone = Zone.ID;
            return Json(rv, JsonRequestBehavior.DenyGet);
        }
    }
}