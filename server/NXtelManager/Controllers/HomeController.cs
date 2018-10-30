using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace NXtelManager.Controllers
{
    public class HomeController : Controller
    {
        public ActionResult Index()
        {
            if (User.Identity.IsAuthenticated && User.IsInRole("Admin"))
                return RedirectToAction("Index", "Server");
            else if (User.Identity.IsAuthenticated && User.IsInRole("Page Editor"))
                return RedirectToAction("Index", "Page");
            else if (User.Identity.IsAuthenticated)
                return RedirectToAction("Index", "Manage");
            else
                return View("Title");
        }
    }
}