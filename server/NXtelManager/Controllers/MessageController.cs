using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using NXtelManager.Attributes;
using NXtelManager.Models;

namespace NXtelManager.Controllers
{
    [Authorize(Roles = "Admin")]
    public class MessageController : Controller
    {
        public ActionResult Compose()
        {
            var model = new MessageComposeModel();
            return View(model);
        }

        [HttpPost]
        [MultipleButton("Save")]
        public ActionResult Save(MessageComposeModel Model)
        {
            if (ModelState.IsValid)
            {
                string err;
                //if (!Model.Zone.Save(out err))
                {
                    return View("Edit", Model);
                }
                return RedirectToAction("Index");
            }
            return View("Edit", Model);
        }

        public ActionResult Drafts()
        {
            return View();
        }

        public ActionResult Read()
        {
            return View();
        }

        public ActionResult Unread()
        {
            return View();
        }
    }
}