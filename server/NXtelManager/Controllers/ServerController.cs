using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Threading;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Rendering;
using MySqlConnector;
using NXtelData;
using NXtelManager.Attributes;

namespace NXtelManager.Controllers
{
    [Authorize(Roles = "Admin")]
    public class ServerController : Controller
    {
        public ActionResult Index()
        {
            long size = 0;
            try
            {
                size = new FileInfo(Options.LogFile).Length;
            }
            catch { }
            ViewBag.LogFileSize = size;
            return View();
        }

        [HttpPost]
        [MultipleButton("DownloadLog")]
        public ActionResult DownloadLog()
        {
            string fileName = Options.LogFile;
            string ts = DateTime.Now.ToString("_yyyyMMdd_HHmmssfff");
            try
            {
                var fs = System.IO.File.Open(fileName, FileMode.OpenOrCreate, FileAccess.Read, FileShare.ReadWrite);
                return File(fs, "text/plain", Path.GetFileNameWithoutExtension(fileName) + ts + Path.GetExtension(fileName));
            }
            catch (Exception /*ex*/)
            {
            }
            return RedirectToAction("Index");
        }

        public ActionResult Backup()
        {
            string file = Path.Combine(Options.DbBackupDirectory, DateTime.Now.ToString("yyyyMMdd-HHmmss") + ".sql");
            using (MySqlConnection conn = new MySqlConnection(DBOps.ConnectionStringBackup))
            {
                using (MySqlCommand cmd = new MySqlCommand())
                {
                    using (MySqlBackup mb = new MySqlBackup(cmd))
                    {
                        cmd.Connection = conn;
                        conn.Open();
                        mb.ExportToFile(file);
                        conn.Close();
                    }
                }
            }
            return RedirectToAction("Index");
        }

        public ActionResult Restore(string id)
        {
            string file = Path.Combine(Options.DbBackupDirectory, (id ?? "").Trim() + ".sql");
            if (!System.IO.File.Exists(file))
                throw new Exception("File does not exist.");
            using (MySqlConnection conn = new MySqlConnection(DBOps.ConnectionStringBackup))
            {
                using (MySqlCommand cmd = new MySqlCommand())
                {
                    using (MySqlBackup mb = new MySqlBackup(cmd))
                    {
                        cmd.Connection = conn;
                        conn.Open();
                        mb.ImportFromFile(file);
                        conn.Close();
                    }
                }
            }
            return RedirectToAction("Index");
        }

    }
}