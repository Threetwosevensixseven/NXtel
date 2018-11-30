using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using MySql.Data.MySqlClient;

namespace NXtelData
{
    public class Route
    {
        public byte KeyCode { get; set; }
        public int? NextPageNo { get; set; }
        public int? NextFrameNo { get; set; }
        public bool GoNextPage { get; set; }
        public bool GoNextFrame { get; set; }
        public string Description { get; set; }
        public int GoesToPageID { get; set; }
        public string GoesToPageFrameDesc { get; set; }
        public int GoesToPageNo { get; set; }
        public int GoesToFrameNo { get; set; }

        public Route()
        {
            GoesToPageID = GoesToPageNo = GoesToFrameNo - 1;
            Description = GoesToPageFrameDesc = "";
        }

        public Route(byte KeyCode, string Description) 
            : base()
        {
            this.KeyCode = KeyCode;
            this.Description = Description;
        }

        public Route(RouteKeys KeyCode, string Description)
             : base()
        {
            this.KeyCode = (byte)KeyCode;
            this.Description = Description;
        }

        public Route(char KeyChar)
            : base()
        {
            this.KeyCode = Convert.ToByte(KeyChar);
            this.Description = KeyChar.ToString();
        }

        public string NextFrame
        {
            get
            {
                if (NextFrameNo == null)
                    return "";
                return ((char)Convert.ToByte(((byte)"a"[0]) + NextFrameNo)).ToString();
            }
            set
            {
                if (value == null || value.Trim().Length == 0)
                {
                    NextFrameNo = null;
                    return;
                }
                char chr = (value.Trim().ToLower())[0];
                if (chr < 'a')
                    NextFrameNo = null;
                else if (chr > 'z')
                    NextFrameNo = null;
                else
                    NextFrameNo = chr - 'a';
            }
        }

        public bool SaveForPage(int PageID, MySqlConnection ConX = null)
        {
            bool openConX = ConX == null;
            if (openConX)
            {
                ConX = new MySqlConnection(DBOps.ConnectionString);
                ConX.Open();
            }

            if (GoNextPage || GoNextFrame)
            {
                // Remove page numbers if they were greyed out in the UI
                NextPageNo = null;
                NextFrameNo = null;
            }
            else if (NextPageNo != null && NextFrameNo == null)
            {
                // Default frame number to 'a' if it was missing in the UI
                NextFrameNo = 0;
            }

            string sql = @"INSERT INTO route (PageID,KeyCode,NextPageNo,NextFrameNo,GoNextPage,GoNextFrame)
                    VALUES(@PageID,@KeyCode,@NextPageNo,@NextFrameNo,@GoNextPage,@GoNextFrame);";
            var cmd = new MySqlCommand(sql, ConX);
            cmd.Parameters.AddWithValue("PageID", PageID);
            cmd.Parameters.AddWithValue("KeyCode", KeyCode);
            cmd.Parameters.AddWithValue("NextPageNo", NextPageNo);
            cmd.Parameters.AddWithValue("NextFrameNo", NextFrameNo);
            cmd.Parameters.AddWithValue("GoNextPage", GoNextPage);
            cmd.Parameters.AddWithValue("GoNextFrame", GoNextFrame);
            cmd.ExecuteNonQuery();

            if (openConX)
                ConX.Close();

            return true;
        }

        public static Route GetRoute(string CurrentPageNo, string CurrentFrame, string PageNo, string Frame, bool NextPage, bool NextFrame)
        {
            var rv = new Route();
            using (var con = new MySqlConnection(DBOps.ConnectionString))
            {
                con.Open();
                int NextPageNo;
                if (!int.TryParse(PageNo, out NextPageNo) || NextPageNo < 0)
                    NextPageNo = -1;
                int NextFrameNo = Page.FrameToFrameNo(Frame);
                if (NextFrameNo < 0)
                    NextFrameNo = -1;
                int currentPageNo;
                if (!int.TryParse(CurrentPageNo, out currentPageNo) || currentPageNo < 0)
                    currentPageNo = -1;
                int CurrentFrameNo = Page.FrameToFrameNo(CurrentFrame);
                if (CurrentFrameNo < 0)
                    CurrentFrameNo = -1;

                byte KeyCode = 0;
                string sql = @"SELECT @CurrentPageNo AS CurrentPageNo,@CurrentFrameNo AS CurrentFrameNo,
                    @NextPageNo AS NextPageNo,@NextFrameNo AS NextFrameNo,
                    @GoNextPage AS GoNextPage,@GoNextFrame AS GoNextFrame,dp.PageID AS DirectPageID,dp.PageNo AS DirectPageNo,dp.FrameNo AS DirectFrameNo,
                    np.PageID AS NextPageID,np.PageNo AS NextPagePageNo,np.FrameNo AS NextPageFrameNo,
                    nf.PageID AS NextFrameID,nf.PageNo AS NextFramePageNo,nf.FrameNo AS NextFrameFrameNo
                    FROM dummy
                    LEFT JOIN `page` dp ON dp.PageID=(SELECT PageID FROM `page` pp WHERE pp.PageNo=@NextPageNo AND pp.FrameNo=@NextFrameNo LIMIT 1)
                    LEFT JOIN `page` np ON np.PageID=(SELECT PageID FROM `page` pp WHERE pp.PageNo=@CurrentPageNo+1 AND pp.FrameNo=0 LIMIT 1)
                    LEFT JOIN `page` nf ON nf.PageID=(SELECT PageID FROM `page` pp WHERE pp.PageNo=@CurrentPageNo AND pp.FrameNo=@CurrentFrameNo+1 LIMIT 1);";
                var cmd = new MySqlCommand(sql, con);
                cmd.Parameters.AddWithValue("CurrentPageNo", currentPageNo);
                cmd.Parameters.AddWithValue("CurrentFrameNo", CurrentFrameNo);
                cmd.Parameters.AddWithValue("NextPageNo", NextPageNo);
                cmd.Parameters.AddWithValue("NextFrameNo", NextFrameNo);
                cmd.Parameters.AddWithValue("GoNextPage", NextPage);
                cmd.Parameters.AddWithValue("GoNextFrame", NextFrame);
                using (var rdr = cmd.ExecuteReader())
                {
                    while (rdr.Read())
                    {
                        rv.Read(rdr, false);
                        break;
                    }
                }
            }
            return rv;
        }

        public void Read(MySqlDataReader rdr, bool IncludeKeyCode = true)
        {
            if (IncludeKeyCode)
                this.KeyCode = rdr.GetByte("KeyCode");
            int CurrentPageNo = rdr.GetInt32Safe("CurrentPageNo");
            int CurrentFrameNo = rdr.GetInt32Safe("CurrentFrameNo");
            this.NextPageNo = rdr.GetInt32Nullable("NextPageNo");
            this.NextFrameNo = rdr.GetInt32Nullable("NextFrameNo");
            this.GoNextPage = rdr.GetBoolean("GoNextPage");
            this.GoNextFrame = rdr.GetBoolean("GoNextFrame");
            var master = Routes.MasterList.FirstOrDefault(r => r.KeyCode == KeyCode);
            this.Description = (master == null) ? Convert.ToChar(KeyCode).ToString() : master.Description;

            // 1) Next Page checked
            if (GoNextPage && !GoNextFrame)
            {
                this.GoesToPageID = rdr.GetInt32Safe("NextPageID");
                if (this.GoesToPageID > 0)
                {
                    this.GoesToPageNo = rdr.GetInt32Safe("NextPagePageNo");
                    this.GoesToFrameNo = rdr.GetInt32Safe("NextPageFrameNo");
                    this.GoesToPageFrameDesc = this.GoesToPageNo.ToString()
                        + ((char)Convert.ToByte(((byte)"a"[0]) + this.GoesToFrameNo)).ToString();
                }
                else
                {
                    this.GoesToPageID = Options.MainIndexPageID;
                    this.GoesToPageNo = Options.MainIndexPageNo;
                    this.GoesToFrameNo = Options.MainIndexFrameNo;
                    this.GoesToPageFrameDesc = Options.MainIndexPage;
                }
            }

            // 2) Next Frame checked        
            else if (GoNextFrame && !GoNextPage)
            {
                this.GoesToPageID = rdr.GetInt32Safe("NextFrameID");
                if (this.GoesToPageID > 0)
                {
                    this.GoesToPageNo = rdr.GetInt32Safe("NextFramePageNo");
                    this.GoesToFrameNo = rdr.GetInt32Safe("NextFrameFrameNo");
                    this.GoesToPageFrameDesc = this.GoesToPageNo.ToString()
                        + ((char)Convert.ToByte(((byte)"a"[0]) + this.GoesToFrameNo)).ToString();
                }
                else
                {
                    this.GoesToPageID = rdr.GetInt32Safe("NextPageID");
                    if (this.GoesToPageID > 0 && CurrentFrameNo == 25)
                    {
                        this.GoesToPageNo = rdr.GetInt32Safe("NextPagePageNo");
                        this.GoesToFrameNo = rdr.GetInt32Safe("NextPageFrameNo");
                        this.GoesToPageFrameDesc = this.GoesToPageNo.ToString()
                            + ((char)Convert.ToByte(((byte)"a"[0]) + this.GoesToFrameNo)).ToString();
                    }
                    else
                    {
                        this.GoesToPageID = Options.MainIndexPageID;
                        this.GoesToPageNo = Options.MainIndexPageNo;
                        this.GoesToFrameNo = Options.MainIndexFrameNo;
                        this.GoesToPageFrameDesc = Options.MainIndexPage;
                    }
                }
            }

            // 3) Both checked
            else if (GoNextFrame && GoNextPage) 
            {
                this.GoesToPageID = rdr.GetInt32Safe("NextFrameID");
                if (this.GoesToPageID > 0)
                {
                    this.GoesToPageNo = rdr.GetInt32Safe("NextFramePageNo");
                    this.GoesToFrameNo = rdr.GetInt32Safe("NextFrameFrameNo");
                    this.GoesToPageFrameDesc = this.GoesToPageNo.ToString()
                        + ((char)Convert.ToByte(((byte)"a"[0]) + this.GoesToFrameNo)).ToString();
                }
                if (this.GoesToPageID <= 0)
                {
                    this.GoesToPageID = rdr.GetInt32Safe("NextPageID");
                    if (this.GoesToPageID > 0)
                    {
                        this.GoesToPageNo = rdr.GetInt32Safe("NextPagePageNo");
                        this.GoesToFrameNo = rdr.GetInt32Safe("NextPageFrameNo");
                        this.GoesToPageFrameDesc = this.GoesToPageNo.ToString()
                            + ((char)Convert.ToByte(((byte)"a"[0]) + this.GoesToFrameNo)).ToString();
                    }
                }
                if (this.GoesToPageID <= 0)
                {
                    this.GoesToPageID = Options.MainIndexPageID;
                    this.GoesToPageNo = Options.MainIndexPageNo;
                    this.GoesToFrameNo = Options.MainIndexFrameNo;
                    this.GoesToPageFrameDesc = Options.MainIndexPage;
                }
            }

            // 4) Neither checked
            else
            {
                this.GoesToPageID = rdr.GetInt32Safe("DirectPageID");
                if (this.GoesToPageID > 0)
                {
                    this.GoesToPageNo = rdr.GetInt32Safe("DirectPageNo");
                    this.GoesToFrameNo = rdr.GetInt32Safe("DirectFrameNo");
                    this.GoesToPageFrameDesc = this.GoesToPageNo.ToString()
                        + ((char)Convert.ToByte(((byte)"a"[0]) + this.GoesToFrameNo)).ToString();
                }
                else
                {
                    this.GoesToPageID = -1;
                    this.GoesToPageNo = -1;
                    this.GoesToFrameNo = 0;
                    this.GoesToPageFrameDesc = "No Page";
                }
            }
        }

        public string Sort
        {
            get
            {
                return (KeyCode == 0x80 ? "2" : (KeyCode == 95 ? "0" : "1"))
                    + KeyCode.ToString("X2");
            }
        }
    }
}
