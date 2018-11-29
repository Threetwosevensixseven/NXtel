using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using NXtelData;
using NXtelManager.Models;

namespace NXtelManager.Controllers
{
    public class JsonController : Controller
    {
        [Authorize(Roles = "Page Editor")]
        public ActionResult GetPageID(GetDataViewModel Model)
        {
            if (Model == null)
                Model = new GetDataViewModel();
            var route = Route.GetRoute(Model.PageNo, Model.Frame, Model.NextPage, Model.NextFrame);
            Model.PageID = route.GoesToPageID;
            Model.GoesToPageFrameDesc = route.GoesToPageFrameDesc;
            return Json(Model, JsonRequestBehavior.AllowGet);
        }
    }
}