using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using NXtelData;

namespace NXtelManager.Controllers
{
    public class StatisticsController : Controller
    {
        public ActionResult Index()
        {
            return Summary();
        }

        public ActionResult Summary()
        {
            var metrics = Metric.Calculate();
            return View(metrics);
        }
    }
}