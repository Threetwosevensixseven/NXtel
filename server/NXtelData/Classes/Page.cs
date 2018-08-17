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
            URL = "";
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

        public static int Save(Page Page)
        {
            if (Page == null)
                return -1;
            using (var con = new MySqlConnection(DBOps.ConnectionString))
            {
                con.Open();
                var key = Page.PageID <= 0 ? "" : "PageID,";
                var val = Page.PageID <= 0 ? "" : "@PageID,";
                string sql = @"INSERT INTO page
                    (" + key + @"PageNo,Seq,Title,Contents,BoxMode,URL)
                    VALUES(" + val + @"@PageNo,@Seq,@Title,@Contents,@BoxMode,@URL)
                    ON DUPLICATE KEY UPDATE
                    PageNo=@PageNo,Seq=@Seq,Title=@Title,BoxMode=@BoxMode,URL=@URL;
                    SELECT LAST_INSERT_ID();";
                var cmd = new MySqlCommand(sql, con);
                cmd.Parameters.AddWithValue("PageID", Page.PageID);
                cmd.Parameters.AddWithValue("PageNo", Page.PageNo);
                cmd.Parameters.AddWithValue("Seq", Page.FrameNo);
                cmd.Parameters.AddWithValue("Title", (Page.Title ?? "").Trim());
                cmd.Parameters.AddWithValue("BoxMode", Page.BoxMode);
                cmd.Parameters.AddWithValue("URL", (Page.URL ?? "").Trim());
                var rv = cmd.ExecuteScalar();
                if (rv.GetType() == typeof(int))
                    return (int)rv;
                else
                    return -1;
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
