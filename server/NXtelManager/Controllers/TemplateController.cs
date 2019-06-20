using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Principal;
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
            var model = new TemplateIndexModel();
            model.Templates = Templates.LoadStubs(true);
            model.Permissions = Permissions.Load(User);
            string userID = User.GetUserID();
            model.Templates.MineFilter = UserPreferences.Get<bool>(userID, "PageIndexMine");
            return View(model);
        }

        public ActionResult Edit(int? ID, string ID2)
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
            model.Permissions = Permissions.Load(User);
            return View(model);
        }

        [HttpPost]
        [MultipleButton("save")]
        public ActionResult Save(Template Template)
        {
            var perms = Permissions.Load(User);
            bool can = perms.Can(Template);
            TemplateEditModel model;
            Template.Fixup();
            if (ModelState.IsValid)
            {
                if (!can)
                {
                    ModelState.AddModelError("", "You can't save this template. Check your <a href='"
                        + Url.Action("Index", "Manage")
                        + "' target='_blank'>permissions</a>.");
                    model = new TemplateEditModel();
                    model.Template = Template;
                    model.Permissions = perms;
                    return View("Edit", model);
                }
                if (Template.TemplateID <= 0 && Template.OwnerID <= 0)
                    Template.OwnerID = perms.User.UserNo;
                string err;
                if (!Template.Save(Template, out err))
                {
                    ModelState.AddModelError("", err);
                    model = new TemplateEditModel();
                    model.Template = Template;
                    model.Permissions = perms;
                    return View("Edit", model);
                }
                return RedirectToAction("Index");
            }
            model = new TemplateEditModel();
            model.Template = Template;
            model.Permissions = perms;
            return View("Edit", model);
        }

        [HttpPost]
        [MultipleButton("delete")]
        public ActionResult Delete(Template Template)
        {
            Template.Fixup();
            var perms = Permissions.Load(User);
            bool can = perms.Can(Template);
            if (!can)
            {
                ModelState.AddModelError("", "You can't delete this file. Check your <a href='"
                    + Url.Action("Index", "Manage")
                    + "' target='_blank'>permissions</a>.");
                var model2 = new TemplateEditModel();
                model2.Template = Template;
                model2.Permissions = perms;
                return View("Edit", model2);
            }
            TemplateEditModel model;
            if (Template == null || Template.TemplateID <= 0)
                return RedirectToAction("Index");
            string err;
            if (!Template.Delete(out err))
            {
                ModelState.AddModelError("", err);
                model = new TemplateEditModel();
                model.Template = Template;
                model.Permissions = perms;
                return View("Edit", model);
            }
            return RedirectToAction("Index");
        }

        public ActionResult Copy(int ID, string ID2)
        {
            if (ID <= 0)
                return RedirectToAction("Index");
            var model = new TemplateEditModel();
            model.Copying = true;
            model.Template = Template.Load(ID);
            model.Template.Environment = ID2;
            model.Template.CopyingFromID = model.Template.TemplateID;
            model.Template.TemplateID = -1;
            if (string.IsNullOrWhiteSpace(model.Template.Environment))
            {
                model.OldDescription = model.Template.Description;
                model.Template.Description = "";
            }
            Session["TemplateCopy"] = model;
            return RedirectToAction("Edit");
        }
    }
}