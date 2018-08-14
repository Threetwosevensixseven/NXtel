using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using NXtelData;
using NXtelManager.Models;

namespace NXtelManager.Controllers
{
    public class PagesController : Controller
    {
        // GET: Page
        public ActionResult Index()
        {
            var pages = Pages.Load();
            return View(pages);
        }
    }
}