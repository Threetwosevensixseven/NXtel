using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using NXtelData;
using NXtelManager.Attributes;
using NXtelManager.Models;

namespace NXtelManager.Controllers
{
    [Authorize]
    public class TemplateController : Controller
    {
        public ActionResult Index()
        {
            var templates = Templates.LoadStubs(true);
            return View(templates);
        }

        public ActionResult Edit(int? ID)
        {
            int id = ID ?? -1;
            var template = Template.Load(id);

            var flat = template.FlattenTemplates();
            string x = "";
            foreach (var t in flat)
                x += t.TemplateID + ": " + t.Description + "\r\n";

            if (id != -1 && template.TemplateID <= 0)
                return RedirectToAction("Index");
            return View(template);
        }

        [HttpPost]
        [MultipleButton("save")]
        public ActionResult Save(Template Template)
        {
            if (ModelState.IsValid)
            {
                string err;
                if (!Template.Save(Template, out err))
                {
                    ModelState.AddModelError("", err);
                    return View("Edit", Template);
                }
                return RedirectToAction("Index");
            }
            return View("Edit", Template);
        }

        [HttpPost]
        [MultipleButton("delete")]
        public ActionResult Delete(Template Template)
        {
            if (Template == null || Template.TemplateID <= 0)
                return RedirectToAction("Index");
            string err;
            if (!Template.Delete(out err))
            {
                ModelState.AddModelError("", err);
                return View("Edit", Template);
            }
            return RedirectToAction("Index");
        }
    }
}