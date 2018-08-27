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

        public Route()
        {
        }

        public Route(byte KeyCode, string Description) 
            : base()
        {
            this.KeyCode = KeyCode;
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

        public void Read(MySqlDataReader rdr)
        {
            this.KeyCode = rdr.GetByte("KeyCode");
            this.NextPageNo = rdr.GetInt32Nullable("NextPageNo");
            this.NextFrameNo = rdr.GetInt32Nullable("NextFrameNo");
            this.GoNextPage = rdr.GetBoolean("GoNextPage");
            this.GoNextFrame = rdr.GetBoolean("GoNextFrame");
            var master = Routes.MasterList.FirstOrDefault(r => r.KeyCode == KeyCode);
            this.Description = (master == null) ? Convert.ToChar(KeyCode).ToString() : master.Description;
        }

        public string Sort
        {
            get
            {
                return (KeyCode == 95 ? "0" : "1")
                    + KeyCode.ToString("X2");
            }
        }
    }
}
