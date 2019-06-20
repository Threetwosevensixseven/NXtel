using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net.Mime;
using System.Security.Principal;
using System.Web;
using System.Web.Mvc;
using NXtelData;
using NXtelManager.Attributes;
using NXtelManager.Models;

namespace NXtelManager.Controllers
{
    [Authorize(Roles = "Page Editor")]
    public class FileController : Controller
    {
        public ActionResult Index()
        {
            var model = new FileIndexModel();
            model.Files = TSFiles.LoadStubs();
            model.Permissions = Permissions.Load(User);
            string userID = User.GetUserID();
            model.Files.MineFilter = UserPreferences.Get<bool>(userID, "PageIndexMine");
            return View(model);
        }

        public ActionResult Edit(int? ID)
        {
            int id = ID ?? -1;
            var model = new FileEditModel();

            var copy = Session["FileCopy"] as FileEditModel;
            if (copy == null)
                model.File = TSFile.Load(id);
            else
            {
                model = copy;
                model.File.Environment = copy.File.Environment;
            }
            Session["FileCopy"] = null;
            if (id != -1 && model.File.TeleSoftwareID <= 0)
                return RedirectToAction("Index");
            model.Permissions = Permissions.Load(User);
            return View(model);
        }

        [HttpPost]
        [MultipleButton("save")]
        public ActionResult Save(TSFile File)
        {
            var perms = Permissions.Load(User);
            bool can = perms.Can(File);
            FileEditModel model;
            if (ModelState.IsValid)
            {
                if (!can)
                {
                    ModelState.AddModelError("", "You can't save this file. Check your <a href='"
                        + Url.Action("Index", "Manage")
                        + "' target='_blank'>permissions</a>.");
                    model = new FileEditModel();
                    model.File = File;
                    model.Permissions = perms;
                    if (model.File.CopyingFromID > 0)
                    {
                        var cf = TSFile.Load(model.File.CopyingFromID);
                        model.File.FileName = cf.FileName;
                        model.File.Contents = cf.Contents;
                    }
                    return View("Edit", model);
                }
                File.Contents = new byte[0];
                File.FileName = "";
                try
                {
                    if (Request.Files.Count > 0)
                    {
                        HttpPostedFileBase objFiles = Request.Files["Contents"];
                        using (var binaryReader = new BinaryReader(objFiles.InputStream))
                        {
                            File.Contents = binaryReader.ReadBytes(objFiles.ContentLength);
                        }
                        File.FileName = Path.GetFileName(objFiles.FileName);
                    }
                }
                catch
                {
                    File.Contents = new byte[0];
                    File.FileName = "";
                }
                if (File.Contents == null || File.Contents.Length == 0)
                {
                    var existing = TSFile.Load(File.TeleSoftwareID);
                    File.Contents = existing.Contents;
                    File.FileName = existing.FileName;
                }
                string err;
                if (File.TeleSoftwareID <= 0 && File.OwnerID <= 0)
                    File.OwnerID = perms.User.UserNo;
                if (File.CopyingFromID > 0)
                {
                    var cf = TSFile.Load(File.CopyingFromID);
                    File.FileName = cf.FileName;
                    File.Contents = cf.Contents;
                }
                if (!TSFile.Save(File, out err))
                {
                    ModelState.AddModelError("", err);
                    model = new FileEditModel();
                    model.File = File;
                    model.Permissions = perms;
                    if (model.File.CopyingFromID > 0)
                    {
                        var cf = TSFile.Load(model.File.CopyingFromID);
                        model.File.FileName = cf.FileName;
                        model.File.Contents = cf.Contents;
                    }
                    return View("Edit", model);
                }
                return RedirectToAction("Index");
            }
            model = new FileEditModel();
            if (File == null)
                model.File = new TSFile();
            if (File.TeleSoftwareID > 0)
                File = TSFile.Load(File.TeleSoftwareID);
            model.File = File;
            model.Permissions = perms;
            if (model.File.CopyingFromID > 0)
            {
                var cf = TSFile.Load(model.File.CopyingFromID);
                model.File.FileName = cf.FileName;
                model.File.Contents = cf.Contents;
            }
            return View("Edit", model);
        }

        [HttpPost]
        [MultipleButton("delete")]
        public ActionResult Delete(TSFile File)
        {
            var perms = Permissions.Load(User);
            bool can = perms.Can(File);
            if (!can)
            {
                ModelState.AddModelError("", "You can't delete this file. Check your <a href='"
                    + Url.Action("Index", "Manage")
                    + "' target='_blank'>permissions</a>.");
                var model2 = new FileEditModel();
                model2.File = File;
                model2.Permissions = perms;
                return View("Edit", model2);
            }
            FileEditModel model;
            if (File == null || File.TeleSoftwareID <= 0)
                return RedirectToAction("Index");
            string err;
            if (!File.Delete(out err))
            {
                ModelState.AddModelError("", err);
                model = new FileEditModel();
                model.File = File;
                model.Permissions = perms;
                return View("Edit", model);
            }
            return RedirectToAction("Index");
        }

        public ActionResult Download(int? ID)
        {
            int id = ID ?? -1;
            var model = new FileEditModel();
            model.File = TSFile.Load(id);
            if (id != -1 && model.File.TeleSoftwareID <= 0)
                return RedirectToAction("Index");
            return File(model.File.Contents, MediaTypeNames.Application.Octet, model.File.FileName);
        }

        public ActionResult Copy(int ID, string ID2)
        {
            if (ID <= 0)
                return RedirectToAction("Index");
            var model = new FileEditModel();
            model.Copying = true;
            model.File = TSFile.Load(ID);
            model.File.Environment = ID2;
            model.File.CopyingFromID = model.File.TeleSoftwareID;
            model.File.TeleSoftwareID = -1;
            if (string.IsNullOrWhiteSpace(model.File.Environment))
            {
                model.OldKey = model.File.Key;
                model.File.Key = "";
            }
            Session["FileCopy"] = model;
            return RedirectToAction("Edit");
        }
    }
}