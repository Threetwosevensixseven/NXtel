using System;
using System.Collections.Generic;
using System.Linq;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Rendering;
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