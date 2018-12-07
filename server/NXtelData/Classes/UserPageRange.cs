using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using MySql.Data.MySqlClient;

namespace NXtelData
{
    public class UserPageRange
    {
        public int ID { get; set; }
        public int FromPageNo { get; set; }
        public int ToPageNo { get; set; }

        public UserPageRange()
        {
            ID = -1;
        }

        public UserPageRange(int ID, int FromPageNo, int ToPageNo)
        {
            this.ID = ID;
            this.FromPageNo = FromPageNo;
            this.ToPageNo = ToPageNo;
        }

        public string Sort
        {
            get
            {
                return FromPageNo.ToString("X8") + ToPageNo.ToString("X8");
            }
        }

        public bool Save(string UserID, MySqlConnection ConX = null)
        {
            bool openConX = ConX == null;
            if (openConX)
            {
                ConX = new MySqlConnection(DBOps.ConnectionString);
                ConX.Open();
            }

            string sql;
            if (this.ID <= 0)
                sql = @"INSERT INTO userpagerange (UserID,FromPageNo,ToPageNo) 
                    VALUES(@UserID,@FromPageNo,@ToPageNo);";
            else
                sql = @"UPDATE userpagerange
                    SET UserID=@UserID,
                    FromPageNo=@FromPageNo,
                    ToPageNo=@ToPageNo
                    WHERE UserPageRangeID=@UserPageRangeID;";
            var cmd = new MySqlCommand(sql, ConX);
            cmd.Parameters.AddWithValue("UserID", (UserID ?? "").Trim());
            cmd.Parameters.AddWithValue("FromPageNo", FromPageNo);
            cmd.Parameters.AddWithValue("ToPageNo", ToPageNo);
            cmd.Parameters.AddWithValue("UserPageRangeID", ID);
            cmd.ExecuteNonQuery();

            if (openConX)
                ConX.Close();

            return true;
        }
    }
}
