using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Principal;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Rendering;
using NXtelData;

namespace NXtelManager.Controllers
{
    [Authorize]
    public class UserPreferenceController : Controller
    {
        public ActionResult Get(string ID)
        {
            if (string.IsNullOrWhiteSpace(ID))
                return AllowGet(null);
            try
            {
                string userID = User.GetUserID();
                string val = UserPreferences.Get(userID, ID);
                return AllowGet(val);
            }
            catch { }
            return AllowGet(null);
        }

        public ActionResult Set(UserPreferences Pref)
        {
            if (Pref == null || string.IsNullOrWhiteSpace(Pref.Key))
                return AllowGet(false);
            try
            {
                string userID = User.GetUserID();
                UserPreferences.Set(userID, Pref.Key, (Pref.Value ?? "").ToString());
                return AllowGet(true);
            }
            catch (Exception /*ex*/)
            {
            }
            return AllowGet(false);
        }

        private ActionResult AllowGet(object Value)
        {
            return Json(Value);
        }

        private ActionResult DenyGet(object Value)
        {
            return Json(Value);
        }
    }
}