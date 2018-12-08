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
    [Authorize(Roles = "Page Editor")]
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
            var model = new TemplateEditModel();
            bool sendURL = id == -2;
            if (sendURL) id = -1;
            var copy = Session["TemplateCopy"] as TemplateEditModel;
            if (copy == null)
                model.Template = Template.Load(id);
            else
                model = copy;
            model.SendURL = sendURL;
            Session["TemplateCopy"] = null;
            if (id != -1 && model.Template.TemplateID <= 0)
                return RedirectToAction("Index");
            return View(model);
        }

        [HttpPost]
        [MultipleButton("save")]
        public ActionResult Save(Template Template)
        {
            TemplateEditModel model;
            Template.Fixup();
            if (ModelState.IsValid)
            {
                string err;
                if (!Template.Save(Template, out err))
                {
                    ModelState.AddModelError("", err);
                    model = new TemplateEditModel();
                    model.Template = Template;
                    return View("Edit", model);
                }
                return RedirectToAction("Index");
            }
            model = new TemplateEditModel();
            model.Template = Template;
            return View("Edit", model);
        }

        [HttpPost]
        [MultipleButton("delete")]
        public ActionResult Delete(Template Template)
        {
            TemplateEditModel model;
            if (Template == null || Template.TemplateID <= 0)
                return RedirectToAction("Index");
            string err;
            if (!Template.Delete(out err))
            {
                ModelState.AddModelError("", err);
                model = new TemplateEditModel();
                model.Template = Template;
                return View("Edit", model);
            }
            return RedirectToAction("Index");
        }

        //[HttpPost]
        //[MultipleButton("copy")]
        //public ActionResult Copy(TemplateEditModel Model)
        //{
        //    if (Model.CopyTemplateID <= 0)
        //        return RedirectToAction("Index");
        //    var model = new TemplateEditModel();
        //    model.Copying = true;
        //    model.Template = Template.Load(Model.CopyTemplateID);
        //    model.Template.TemplateID = -1;
        //    model.OldDescription = model.Template.Description;
        //    model.Template.Description = "";
        //    return View("Edit", model);
        //}

        public ActionResult Copy(int ID)
        {
            if (ID <= 0)
                return RedirectToAction("Index");
            var model = new TemplateEditModel();
            model.Copying = true;
            model.Template = Template.Load(ID);
            model.Template.TemplateID = -1;
            model.OldDescription = model.Template.Description;
            model.Template.Description = "";
            Session["TemplateCopy"] = model;
            return RedirectToAction("Edit");
        }
    }
}