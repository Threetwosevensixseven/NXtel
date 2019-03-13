using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net.Mime;
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
            var files = TSFiles.LoadStubs();
            return View(files);
        }

        public ActionResult Edit(int? ID)
        {
            int id = ID ?? -1;
            var model = new FileEditModel();
            model.File = TSFile.Load(id);
            if (id != -1 && model.File.TeleSoftwareID <= 0)
                return RedirectToAction("Index");
            return View(model);
        }

        [HttpPost]
        [MultipleButton("save")]
        public ActionResult Save(TSFile File)
        {
            FileEditModel model;
            if (ModelState.IsValid)
            {
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
                if (!TSFile.Save(File, out err))
                {
                    ModelState.AddModelError("", err);
                    model = new FileEditModel();
                    model.File = File;
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
            return View("Edit", model);
        }

        [HttpPost]
        [MultipleButton("delete")]
        public ActionResult Delete(TSFile File)
        {
            FileEditModel model;
            if (File == null || File.TeleSoftwareID <= 0)
                return RedirectToAction("Index");
            string err;
            if (!File.Delete(out err))
            {
                ModelState.AddModelError("", err);
                model = new FileEditModel();
                model.File = File;
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
    }
}