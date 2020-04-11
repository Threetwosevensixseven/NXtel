using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using MySql.Data.MySqlClient;

namespace NXtelData
{
    public class Pages : List<Page>
    {
        public int ZoneFilter { get; set; }
        public bool PrimaryFilter { get; set; }
        public bool MineFilter { get; set; }

        public Pages()
        {
            ZoneFilter = -1;
            PrimaryFilter = false;
            MineFilter = false;
        }

        public static Pages Load()
        {
            var list = new Pages();
            using (var con = new MySqlConnection(DBOps.ConnectionString))
            {
                con.Open();
                string sql = "SELECT * FROM page ORDER BY PageNo,FrameNo;";
                var cmd = new MySqlCommand(sql, con);
                using (var rdr = cmd.ExecuteReader())
                {
                    while (rdr.Read())
                    {
                        var item = new Page();
                        item.Read(rdr);
                        list.Add(item);
                    }
                }
            }
            return list;
        }

        public static Pages LoadStubs(int ZoneID = -1, string ZoneIDs = null, int MostRecent = -1)
        {
            var list = new Pages();
            var pids = new List<int>();
            using (var con = new MySqlConnection(DBOps.ConnectionString))
            {
                con.Open();
                string sql;
                if (ZoneIDs == null)
                {
                    string filter = "";
                    string limit = "";
                    string order = " ORDER BY PageNo,FrameNo";
                    if (ZoneID > 0)
                        filter = "WHERE PageID IN (SELECT PageID FROM pagezone pz WHERE pz.ZoneID=" + ZoneID + ") ";
                    else if (ZoneID == -2)
                        filter = "WHERE PageID NOT IN (SELECT PageID FROM pagezone pz) ";
                    else if (MostRecent > 0)
                    {
                        filter = "WHERE Updated IS NOT NULL ";
                        limit = " LIMIT " + MostRecent;
                        order = " ORDER BY Updated DESC";
                    }
                    sql = @"SELECT PageID,PageNo,FrameNo,Title,ToPageFrameNo,OwnerID,Updated,UpdatedBy 
                    FROM page " + filter + order + limit;
                }
                else
                {
                    string filter = ZoneIDs == "" ? "-1" : ZoneIDs;
                    sql = @"SELECT p.PageID,PageNo,FrameNo,Title,ToPageFrameNo,OwnerID
                        FROM `page` p
                        JOIN pagezone pz ON p.PageID=pz.PageID
                        JOIN zone z ON pz.ZoneID=z.ZoneID
                        WHERE z.ZoneID IN(" + filter + @")
                        ORDER BY PageNo,FrameNo;";
                }
                var cmd = new MySqlCommand(sql, con);
                using (var rdr = cmd.ExecuteReader())
                {
                    while (rdr.Read())
                    {
                        var item = new Page();
                        item.Read(rdr, true);
                        list.Add(item);
                        pids.Add(item.PageID);
                    }
                }
                if (pids.Count > 0)
                {
                    sql = @"SELECT PageID,ZoneID
                    FROM pagezone
                    WHERE PageID IN(" +  string.Join(",", pids) + @")
                    ORDER BY PageID,ZoneID;";
                    cmd.CommandText = sql;
                    using (var rdr = cmd.ExecuteReader())
                    {
                        while (rdr.Read())
                        {
                            int pid = rdr.GetInt32("PageID");
                            int zid = rdr.GetInt32("ZoneID");
                            var page = list.FirstOrDefault(p => p.PageID == pid);
                            if (page != null)
                                page.ZoneIDs += (string.IsNullOrWhiteSpace(page.ZoneIDs) ? "" : ",") + zid;
                        }
                    }
                }
            }
            return list;
        }

        private static Regex frameRegex = new Regex(@"^\s*?(?<PageNo>\d{1,10})(?<Frame>[a-zA-Z])\s*$");
        public static Pages Search(string Value, bool AllowNone, MySqlConnection ConX = null)
        {
            var list = new Pages();
            if (AllowNone)
                list.Add(new Page() { PageID = -1, Title = "[None]" });
            bool openConX = ConX == null;
            if (openConX)
            {
                ConX = new MySqlConnection(DBOps.ConnectionString);
                ConX.Open();
            }

            int pageNo = -1;
            int frameNo = -1;
            Value = Value ?? "";
            string filter = "1=0";
            if (Value.Length > 0)
            {
                string filter2 = "";
                var m = frameRegex.Match(Value);
                if (m.Success)
                {
                    int.TryParse(m.Groups["PageNo"].Value, out pageNo);
                    string frame = (m.Groups["Frame"].Value ?? "").Trim().ToLower();
                    if (frame.Length == 1)
                        frameNo = Convert.ToByte(frame[0]) - 'a';
                    if (pageNo > 0 && frameNo >= 0 && frameNo <= 25)
                        filter2 = " OR (PageNo=@PageNo AND FrameNo=@FrameNo)";
                }
                filter = "((Title LIKE @Title)" + filter2 + ")";
                Value = "%" + Value + "%";
            }

            string sql = @"SELECT PageID,Title,PageNo,FrameNo
                FROM `page`
                WHERE " + filter + @"
                ORDER BY Title,PageID;";
            using (var cmd = new MySqlCommand(sql, ConX))
            {
                cmd.Parameters.AddWithValue("Title", Value);
                cmd.Parameters.AddWithValue("PageNo", pageNo);
                cmd.Parameters.AddWithValue("FrameNo", frameNo);
                using (var rdr = cmd.ExecuteReader())
                {
                    while (rdr.Read())
                    {
                        var item = new Page();
                        item.PageID = rdr.GetInt32("PageID");
                        item.Title = rdr.GetStringNullable("Title");
                        item.PageNo = rdr.GetInt32("PageNo");
                        item.FrameNo = rdr.GetInt32("FrameNo");
                        list.Add(item);
                    }
                }
            }

            if (openConX)
                ConX.Close();

            return list;
        }
    }
}
