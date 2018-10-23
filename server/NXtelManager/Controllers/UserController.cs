using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using NXtelData;

namespace NXtelManager.Controllers
{
    public class UserController : Controller
    {
        [Authorize(Roles = "Admin")]
        public ActionResult Index()
        {
            var users = Users.Load();
            return View(users);
        }

        public ActionResult Edit(string ID)
        {
            return View();
        }
    }
}