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
    public class Page
    {
        private byte[] _contents;
        private byte[] _contents7BitEncoded;
        public int PageID { get; set; }
        public int PageNo { get; set; }
        public int Seq { get; set; }
        public string Title { get; set; }
        public byte? DateX { get; set; }
        public byte? DateY { get; set; }
        public byte? TimeX { get; set; }
        public byte? TimeY { get; set; }

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
                        item.PageID = rdr.GetInt32(rdr.GetOrdinal("PageID"));
                        item.PageNo = rdr.GetInt32(rdr.GetOrdinal("PageNo"));
                        item.Seq = rdr.GetInt32(rdr.GetOrdinal("Seq"));
                        item.Title = rdr.GetString(rdr.GetOrdinal("Title"));
                        item.Contents = (byte[])rdr["Contents"];
                        item.DateX = rdr.GetValueOrDefault<Byte>(rdr.GetOrdinal("DateX"));
                        item.DateY = rdr.GetValueOrDefault<Byte>(rdr.GetOrdinal("DateY"));
                        item.TimeX = rdr.GetValueOrDefault<Byte>(rdr.GetOrdinal("TimeX"));
                        item.TimeY = rdr.GetValueOrDefault<Byte>(rdr.GetOrdinal("TimeY"));
                        break;
                    }
                }
            }
            return item;
        }

        private static byte[] GetPage(string Name)
        {
            var fn = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "..", "..", "Pages", Name);
            return File.ReadAllBytes(fn);
        }

        public byte[] Contents
        {
            get
            {
                return _contents;
            }
            set
            {
                _contents = value;
                _contents7BitEncoded = null;
            }
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

        public byte[] Contents7BitEncoded
        {
            get
            {
                if (_contents7BitEncoded == null)
                {
                    var enc = new List<byte>();
                    foreach (var b in Contents)
                    {
                        if ((b & 0x80) == 0x80)
                        {
                            enc.Add(27);
                            enc.Add(Convert.ToByte(b & 0x7F));
                        }
                        else
                            enc.Add(b);
                    }
                    _contents7BitEncoded = enc.ToArray();
                }
                return _contents7BitEncoded;
            }
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
