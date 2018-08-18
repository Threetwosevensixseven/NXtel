using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Threading.Tasks;
using MySql.Data.MySqlClient;

namespace NXtelData
{
    public class Page : PageBase
    {
        public int PageID { get; set; }
        public int PageNo { get; set; }
        public int FrameNo { get; set; }
        public string Title { get; set; }
        public byte? DateX { get; set; }
        public byte? DateY { get; set; }
        public byte? TimeX { get; set; }
        public byte? TimeY { get; set; }
        public bool BoxMode { get; set; }
        public Routing Routing { get; set; }

        public Page()
        {
            PageID = -1;
            Title = URL = "";
            Routing = new Routing();
            this.ConvertContentsFromURL();
        }

        public string Frame
        {
            get
            {
                return ((char)Convert.ToByte(((byte)"a"[0]) + FrameNo)).ToString();
            }
            set
            {
                if (value == null || value.Trim().Length == 0)
                {
                    FrameNo = 0;
                    return;
                }
                char chr = (value.Trim().ToLower())[0];
                if (chr < 'a')
                    FrameNo = 0;
                else if (chr > 'z')
                    FrameNo = 25;
                else
                    FrameNo = chr - 'a';
            }
        }

        public static Page Load(int PageNo, int Seq)
        {
            var item = new Page();
            using (var con = new MySqlConnection(DBOps.ConnectionString))
            {
                con.Open();
                string sql = "SELECT * FROM page WHERE PageNo=" + PageNo + " AND Seq=" + Seq;
                var cmd = new MySqlCommand(sql, con);
                using (var rdr = cmd.ExecuteReader())
                {
                    while (rdr.Read())
                    {
                        item.Read(rdr);
                        break;
                    }
                }
            }
            return item;
        }

        public static Page Load(int PageID)
        {
            var item = new Page();
            using (var con = new MySqlConnection(DBOps.ConnectionString))
            {
                con.Open();
                string sql = "SELECT * FROM page WHERE PageID=" + PageID;
                var cmd = new MySqlCommand(sql, con);
                using (var rdr = cmd.ExecuteReader())
                {
                    while (rdr.Read())
                    {
                        item.Read(rdr);
                        break;
                    }
                }
            }
            return item;
        }

        public static bool Save(Page Page, out string Err)
        {
            Err = "";
            try
            {
                if (Page.PageID <= 0)
                    return Page.Create(out Err);
                else
                    return Page.Update(out Err);
            }
            catch (Exception ex)
            {
                Err = ex.Message;
                return false;
            }
        }

        public bool Create(out string Err)
        {
            Err = "";
            try
            {
                using (var con = new MySqlConnection(DBOps.ConnectionString))
                {
                    con.Open();
                    string sql = @"INSERT INTO page
                    (PageNo,FrameNo,Title,Contents,BoxMode,URL)
                    VALUES(@PageNo,@FrameNo,@Title,@Contents,@BoxMode,@URL);
                    SELECT LAST_INSERT_ID();";
                    var cmd = new MySqlCommand(sql, con);
                    cmd.Parameters.AddWithValue("PageNo", PageNo);
                    cmd.Parameters.AddWithValue("FrameNo", FrameNo);
                    cmd.Parameters.AddWithValue("Title", (Title ?? "").Trim());
                    cmd.Parameters.AddWithValue("BoxMode", BoxMode);
                    cmd.Parameters.AddWithValue("URL", (URL ?? "").Trim());
                    cmd.Parameters.AddWithValue("Contents", Contents);
                    int rv = cmd.ExecuteScalarInt32();
                    if (rv > 0)
                        PageID = rv;
                    if (PageID <= 0)
                        Err = "The page could not be saved.";
                    return PageID > 0;
                }
            }
            catch (Exception ex)
            {
                if (ex.Message.ToLower().Contains("duplicate entry"))
                    Err = "Page " + PageNo + Frame + " already exists.";
                else
                    Err = ex.Message;
                return false;
            }
        }

        public bool Update(out string Err)
        {
            Err = "";
            try
            {
                using (var con = new MySqlConnection(DBOps.ConnectionString))
                {
                    con.Open();
                    string sql = @"UPDATE page
                    SET PageNo=@PageNo,FrameNo=@FrameNo,Title=@Title,BoxMode=@BoxMode,
                    URL=@URL,Contents=@Contents
                    WHERE PageID=@PageID;
                    SELECT ROW_COUNT();";
                    var cmd = new MySqlCommand(sql, con);
                    cmd.Parameters.AddWithValue("PageID", PageID);
                    cmd.Parameters.AddWithValue("PageNo", PageNo);
                    cmd.Parameters.AddWithValue("FrameNo", FrameNo);
                    cmd.Parameters.AddWithValue("Title", (Title ?? "").Trim());
                    cmd.Parameters.AddWithValue("BoxMode", BoxMode);
                    cmd.Parameters.AddWithValue("URL", (URL ?? "").Trim());
                    cmd.Parameters.AddWithValue("Contents", Contents);
                    int rv = cmd.ExecuteScalarInt32();
                    if (rv <= 0)
                        Err = "The page could not be saved.";
                    return rv > 0;
                }
            }
            catch (Exception ex)
            {
                if (ex.Message.ToLower().Contains("duplicate entry"))
                    Err = "Page " + PageNo + Frame + " already exists.";
                else
                    Err = ex.Message;
                return false;
            }
        }

        public bool Delete(out string Err)
        {
            Err = "";
            try
            {
                using (var con = new MySqlConnection(DBOps.ConnectionString))
                {
                    con.Open();
                    string sql = @"DELETE FROM page
                    WHERE PageID=@PageID;";
                    var cmd = new MySqlCommand(sql, con);
                    cmd.Parameters.AddWithValue("PageID", PageID);
                    cmd.ExecuteNonQuery();
                    return true;
                }
            }
            catch (Exception ex)
            {
                Err = ex.Message;
                return false;
            }
        }

        public void Read(MySqlDataReader rdr)
        {
            this.PageID = rdr.GetInt32("PageID");
            this.PageNo = rdr.GetInt32("PageNo");
            this.FrameNo = rdr.GetInt32("FrameNo");
            this.Title = rdr.GetString("Title").Trim();
            this.Contents = rdr.GetBytesNullable("Contents");
            this.URL = rdr.GetStringNullable("URL").Trim();
            this.BoxMode = rdr.GetBoolean("BoxMode");
            this.ConvertContentsFromURL();
        }

        private static byte[] GetPage(string Name)
        {
            var fn = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "..", "..", "Pages", Name);
            return File.ReadAllBytes(fn);
        }

        public static byte[] Update(string PageFile, int PageNo, int Seq, string Title)
        {
            var bytes = GetPage(PageFile);
            using (var con = new MySqlConnection(DBOps.ConnectionString))
            {
                con.Open();
                string sql = @"INSERT INTO page
                    (PageNo,Seq,Title,Contents)
                    VALUES (@PageNo,@Seq,@Title,@Contents)
                    ON DUPLICATE KEY UPDATE
                    PageNo=@PageNo,
                    Seq=@Seq,
                    Contents=@Contents;";
                var cmd = new MySqlCommand(sql, con);
                cmd.Parameters.AddWithValue("PageNo", PageNo);
                cmd.Parameters.AddWithValue("Seq", Seq);
                cmd.Parameters.AddWithValue("Title", Title);
                cmd.Parameters.AddWithValue("Contents", bytes);
                cmd.ExecuteNonQuery();
            }
            return bytes;
        }

        public void SetVersion(string Version)
        {
            const int LEN = 9;
            string ver = ("v" + Version.Trim()).PadLeft(LEN);
            for (int i = 0; i < Contents.Length - LEN + 1; i++)
            {
                if (Convert.ToChar(Contents[i]).ToString() == "["
                    && Convert.ToChar(Contents[i + 1]).ToString() == "V"
                    && Convert.ToChar(Contents[i + 2]).ToString() == "E"
                    && Convert.ToChar(Contents[i + 3]).ToString() == "R"
                    && Convert.ToChar(Contents[i + 4]).ToString() == "S"
                    && Convert.ToChar(Contents[i + 5]).ToString() == "I"
                    && Convert.ToChar(Contents[i + 6]).ToString() == "O"
                    && Convert.ToChar(Contents[i + 7]).ToString() == "N"
                    && Convert.ToChar(Contents[i + 8]).ToString() == "]")
                {
                    Contents[i] = Convert.ToByte(ver[0]);
                    Contents[i + 1] = Convert.ToByte(ver[1]);
                    Contents[i + 2] = Convert.ToByte(ver[2]);
                    Contents[i + 3] = Convert.ToByte(ver[3]);
                    Contents[i + 4] = Convert.ToByte(ver[4]);
                    Contents[i + 5] = Convert.ToByte(ver[5]);
                    Contents[i + 6] = Convert.ToByte(ver[6]);
                    Contents[i + 7] = Convert.ToByte(ver[7]);
                    Contents[i + 8] = Convert.ToByte(ver[8]);
                    _contents7BitEncoded = null;
                    return;
                }
            }
        }
    }
}
