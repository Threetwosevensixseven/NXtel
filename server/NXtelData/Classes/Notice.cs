using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using MySql.Data.MySqlClient;

namespace NXtelData
{
    public class Notice
    {

        public static Page GetNextNotice(Page CurrentPage, string ClientHash, ref bool ShowingNotices, ref int LastNoticeReadID)
        {
            if (!ShowingNotices || CurrentPage == null || CurrentPage.PageID <= 0)
            {
                ShowingNotices = false;
                return Page.Load(Options.MainIndexPageNo, Options.MainIndexFrameNo);
            }

            int nextPageNo = -1;
            int nextFrameNo = -1;
            int noticeID = -1;
            int noticeReadID = -1;
            ClientHash = (ClientHash ?? "").Trim();
            using (var con = new MySqlConnection(DBOps.ConnectionString))
            {
                con.Open();
                string sql = @"SELECT p.PageID,p.PageNo,p.FrameNo,n.NoticeID,r.NoticeReadID
                    FROM `page` p
                    JOIN notice n ON n.PageID=p.PageID
                    LEFT JOIN noticeread r ON r.NoticeID=n.NoticeID
                    WHERE n.IsActive=1
                    AND (n.StartDate IS NULL OR n.StartDate<=CURRENT_TIMESTAMP())
                    AND (n.EndDate IS NULL OR n.EndDate>=CURRENT_TIMESTAMP())
                    AND (r.ClientHash IS NULL OR r.ClientHash='" + ClientHash + @"')
                    AND (r.ReadDate IS NULL OR r.ReadDate<n.UpdatedDate OR r.NoticeReadID="+ LastNoticeReadID + @")
                    ORDER BY PageNo,FrameNo;";
                bool foundCurrent = CurrentPage.PageAndFrame == Options.StartPage;
                using (var cmd = new MySqlCommand(sql, con))
                using (var rdr = cmd.ExecuteReader())
                {
                    while (rdr.Read())
                    {
                        int id = rdr.GetInt32("PageID");
                        if (id == CurrentPage.PageID)
                        {
                            foundCurrent = true;
                            continue;
                        }
                        if (foundCurrent)
                        {
                            nextPageNo = rdr.GetInt32("PageNo");
                            nextFrameNo = rdr.GetInt32("FrameNo");
                            noticeID = rdr.GetInt32("NoticeID");
                            noticeReadID = rdr.GetInt32Safe("NoticeReadID");
                            break;
                        }
                    }
                }

                if (noticeReadID > 0)
                {
                    sql = @"UPDATE noticeread
                            SET ReadDate=CURRENT_TIMESTAMP()
                            WHERE NoticeReadID=" + noticeReadID;
                    using (var cmd = new MySqlCommand(sql, con))
                    {
                        cmd.ExecuteNonQuery();
                    }
                    LastNoticeReadID = noticeReadID;
                }

                if (noticeID > 0)
                {
                    sql = @"INSERT INTO noticeread
                            (NoticeID,ClientHash,ReadDate)
                            VALUES (" + noticeID + @",'" + ClientHash + @"',CURRENT_TIMESTAMP());
                            SELECT LAST_INSERT_ID();";
                    using (var cmd = new MySqlCommand(sql, con))
                    {
                        LastNoticeReadID = cmd.ExecuteScalarInt32();
                    }
                }
            }

            if (nextPageNo > 0)
                return Page.Load(nextPageNo, nextFrameNo);

            ShowingNotices = false;
            return Page.Load(Options.MainIndexPageNo, Options.MainIndexFrameNo);
        }
    }
}
