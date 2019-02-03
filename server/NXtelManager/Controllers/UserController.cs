using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.RegularExpressions;
using System.Web;
using System.Web.Mvc;
using NXtelData;
using NXtelManager.Attributes;
using NXtelManager.Models;

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
            var model = new UserEditModel();
            model.User = NXtelData.User.Load(ID);
            if (model.User == null || string.IsNullOrEmpty(model.User.ID))
            {
                return RedirectToAction("Index");
            }
            return View(model);
        }

        [HttpPost]
        [MultipleButton("Delete")]
        public ActionResult Delete(string UserID)
        {
            var user = NXtelData.User.Load(UserID);
            if (user == null || string.IsNullOrEmpty(user.ID) || user.IsAdmin)
            {
                var users2 = Users.Load();
                return View("Index", users2);
            }
            string err;
            NXtelData.User.Delete(UserID, out err);
            var users = Users.Load();
            return View("Index", users);
        }

        [HttpPost]
        [MultipleButton("Confirm")]
        public ActionResult Confirm(string UserID)
        {
            var user = NXtelData.User.Load(UserID);
            if (user == null || string.IsNullOrEmpty(user.ID))
            {
                var users2 = Users.Load();
                return View("Index", users2);
            }
            string err;
            NXtelData.User.Confirm(UserID, out err);
            var users = Users.Load();
            return View("Index", users);
        }

        [HttpPost]
        [MultipleButton("Save")]
        public ActionResult Save(UserEditModel Model)
        {
            Model.Fixup();
            var r = new Regex(@"^(?!\.)(""([^""\r\\]|\\[""\r\\])*""|([-a-z0-9!#$%&'*+/=?^_`{|}~]|(?<!\.)\.)*)(?<!\.)@[a-z0-9][\w\.-]*[a-z0-9]\.[a-z][a-z\.]*[a-z]$", RegexOptions.IgnoreCase);
            if (!r.IsMatch(Model.User.Email))
            {
                ModelState.AddModelError("", "Email Address is not valid.");
            }
            if (ModelState.IsValid)
            {
                string err;
                if (!NXtelData.User.Save(Model.User, out err))
                {
                    ModelState.AddModelError("", err);
                    return View("Edit", Model);
                }
                return RedirectToAction("Index");
            }
            return View("Edit", Model);
        }

        [HttpPost]
        [MultipleButton("DeleteItem")]
        public ActionResult DeleteItem(UserEditModel Model)
        {
            var id = Model == null || Model.User == null ? "" : Model.User.ID;
            return Delete(id);
        }

    }
}