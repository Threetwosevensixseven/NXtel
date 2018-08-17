using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using NXtelData;
using NXtelManager.Models;

namespace NXtelManager.Controllers
{
    public class TemplateController : Controller
    {
        public ActionResult Index()
        {
            var templates = Templates.Load();
            return View(templates);
        }

        public ActionResult Edit(int? ID)
        {
            int id = ID ?? -1;
            var model = new TemplateEditModel();
            model.Template = Template.Load(id);
            if (id != -1 && model.Template.TemplateID <= 0)
                return RedirectToAction("Index");
            return View(model);
        }

        [HttpPost]
        public ActionResult Edit(Template Template)
        {
            if (ModelState.IsValid)
            {
                Template.Save(Template);
            }
            var model = new TemplateEditModel();
            model.Template = Template;
            return View(model);
        }
    }
}