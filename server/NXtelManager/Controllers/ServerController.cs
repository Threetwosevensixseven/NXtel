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

        [HttpPost]
        [MultipleButton("DownloadLog")]
        public ActionResult DownloadLog(ServerStatus Status)
        {
            string log = "";
            string fileName = Options.LogFile;
            try
            {
                var fs = System.IO.File.Open(fileName, FileMode.OpenOrCreate, FileAccess.Read, FileShare.ReadWrite);
                return File(fs, "text/plain", Path.GetFileName(fileName));
            }
            catch (Exception ex)
            {
            }
            return RedirectToAction("Index");
        }

        //[HttpPost]
        //[MultipleButton("EmptyLog")]
        //public ActionResult EmptyLog(ServerStatus Status)
        //{
        //    ServerStatus.KillAll();
        //    try
        //    {
        //        if (System.IO.File.Exists(Options.LogFile))
        //            System.IO.File.Delete(Options.LogFile);
        //    }
        //    catch { }
        //    ServerStatus.Start(Status.StartVisible);
        //    var model = new ServerStatus();
        //    model.StartVisible = Status.StartVisible;
        //    return View("Index", model);
        //}
    }
}