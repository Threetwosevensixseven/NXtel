using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Threading;
using System.Web;
using System.Web.Mvc;
using NXtelData;
using NXtelManager.Attributes;

namespace NXtelManager.Controllers
{
    [Authorize]
    public class ServerController : Controller
    {
        public ActionResult Index()
        {
            var model = new ServerStatus();
            return View(model); 
        }

        [HttpPost]
        [MultipleButton("Refresh")]
        public ActionResult Refresh(ServerStatus Status)
        {
            var model = new ServerStatus();
            model.StartVisible = Status.StartVisible;
            return View("Index", model);
        }

        [HttpPost]
        [MultipleButton("Start")]
        public ActionResult Start(ServerStatus Status)
        {
            var model = ServerStatus.Start(Status.StartVisible);
            model.StartVisible = Status.StartVisible;
            return View("Index", model);
        }

        [HttpPost]
        [MultipleButton("Stop")]
        public ActionResult Stop(ServerStatus Status)
        {
            var model = ServerStatus.KillAll();
            model.StartVisible = Status.StartVisible;
            return View("Index", model);
        }

        [HttpPost]
        [MultipleButton("Restart")]
        public ActionResult Restart(ServerStatus Status)
        {
            ServerStatus.KillAll();
            var model = ServerStatus.Start(Status.StartVisible);
            model.StartVisible = Status.StartVisible;
            return View("Index", model);
        }
    }
}