using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using MySql.Data.MySqlClient;

namespace NXtelData
{
    public class Notices : List<Notice>
    {
        public static Notices Load(MySqlConnection ConX = null)
        {
            var list = new Notices();
            bool openConX = ConX == null;
            if (openConX)
            {
                ConX = new MySqlConnection(DBOps.ConnectionString);
                ConX.Open();
            }

            string sql = @"SELECT n.*,p.PageNo,p.FrameNo,p.FromPageFrameNo,p.Title,p.Updated
                FROM notice n
                JOIN `page` p ON n.PageID=p.PageID
                ORDER BY p.FromPageFrameNo;";
            var cmd = new MySqlCommand(sql, ConX);
            using (var rdr = cmd.ExecuteReader())
            {
                while (rdr.Read())
                {
                    var item = new Notice();
                    item.ID = rdr.GetInt32("NoticeID");
                    item.PageID = rdr.GetInt32("PageID");
                    item.StartDate = rdr.GetDateTimeNullable("StartDate");
                    item.EndDate = rdr.GetDateTimeNullable("EndDate");
                    item.IsActive = rdr.GetBooleanSafe("IsActive");
                    item.Updated = rdr.GetDateTimeNullable("UpdatedDate");
                    DateTime? pageUpdated = rdr.GetDateTimeNullable("Updated");
                    if (pageUpdated.HasValue && item.Updated.HasValue && pageUpdated > item.Updated)
                        item.Updated = pageUpdated;
                    item.PageTitle = rdr.GetStringNullable("Title");
                    item.PageFrameNo = rdr.GetDouble("FromPageFrameNo");
                    int pageNo = rdr.GetInt32("PageNo");
                    int frame = rdr.GetInt32("FrameNo");
                    item.PageFrameNoStr = pageNo.ToString() + ((char)Convert.ToByte(((byte)"a"[0]) + frame)).ToString();
                    list.Add(item);
                }
            }

            if (openConX)
                ConX.Close();

            return list;
        }
    }
}
