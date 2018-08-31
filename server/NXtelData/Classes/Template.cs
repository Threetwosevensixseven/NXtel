using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Reflection;
using System.Text;
using MySql.Data.MySqlClient;

namespace NXtelData
{
    public class Template : PageBase
    {
        public int TemplateID { get; set; }
        public string Description { get; set; }
        public byte X { get; set; }
        public byte Y { get; set; }
        public byte Width { get; set; }
        public byte Height { get; set; }
        public string Expression { get; set; }
        public int Sequence { get; set; }
        public Feed Feed { get; set; }
        public Templates ChildTemplates { get; set; }
        public string SelectedTemplates { get; set; }

        public Template()
        {
            TemplateID = -1;
            Description = Expression = SelectedTemplates = "";
            ChildTemplates = new Templates();
        }

        public static Template Load(int TemplateID)
        {
            var item = new Template();
            using (var con = new MySqlConnection(DBOps.ConnectionString))
            {
                con.Open();
                string sql = "SELECT * FROM template WHERE TemplateID=" + TemplateID;
                using (var cmd = new MySqlCommand(sql, con))
                using (var rdr = cmd.ExecuteReader())
                {
                    while (rdr.Read())
                    {
                        item.Read(rdr);
                        break;
                    }
                }
                var ids = new HashSet<int>();
                if (item.TemplateID >= 0)
                {
                    item.LoadChildTemplates(ref ids, con);
                    item.SetSelectedTemplates();
                }
            }
            return item;
        }

        public static bool Save(Template Template, out string Err)
        {
            Err = "";
            try
            {
                if (Template.TemplateID <= 0)
                    return Template.Create(out Err);
                else
                    return Template.Update(out Err);
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
                    string sql = @"INSERT INTO template
                    (Description,X,Y,Width,Height,Expression,URL,Contents)
                    VALUES(@Description,@X,@Y,@Width,@Height,@Expression,@URL,@Contents);
                    SELECT LAST_INSERT_ID();";
                    var cmd = new MySqlCommand(sql, con);
                    cmd.Parameters.AddWithValue("Description", (Description ?? "").Trim());
                    cmd.Parameters.AddWithValue("X", X);
                    cmd.Parameters.AddWithValue("Y", Y);
                    cmd.Parameters.AddWithValue("Width", Width);
                    cmd.Parameters.AddWithValue("Height", Height);
                    cmd.Parameters.AddWithValue("Expression", (Expression ?? "").Trim());
                    cmd.Parameters.AddWithValue("URL", (URL ?? "").Trim());
                    cmd.Parameters.AddWithValue("Contents", Contents);
                    int rv = cmd.ExecuteScalarInt32();
                    if (rv > 0)
                        TemplateID = rv;
                    if (TemplateID <= 0)
                        Err = "The template could not be saved.";

                    if (TemplateID > 0)
                    {
                        ChildTemplates.SaveChildenForTemplate(TemplateID, out Err, con);
                        if (!string.IsNullOrWhiteSpace(Err))
                            return false;
                    }

                    return TemplateID > 0;
                }
            }
            catch (Exception ex)
            {
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
                    string sql = @"UPDATE template
                    SET Description=@Description,X=@X,Y=@Y,Width=@Width,Height=@Height,
                    Expression=@Expression,URL=@URL,Contents=@Contents
                    WHERE TemplateID=@TemplateID;
                    SELECT ROW_COUNT();";
                    var cmd = new MySqlCommand(sql, con);
                    cmd.Parameters.AddWithValue("TemplateID", TemplateID);
                    cmd.Parameters.AddWithValue("Description", (Description ?? "").Trim());
                    cmd.Parameters.AddWithValue("X", X);
                    cmd.Parameters.AddWithValue("Y", Y);
                    cmd.Parameters.AddWithValue("Width", Width);
                    cmd.Parameters.AddWithValue("Height", Height);
                    cmd.Parameters.AddWithValue("Expression", (Expression ?? "").Trim());
                    cmd.Parameters.AddWithValue("URL", (URL ?? "").Trim());
                    cmd.Parameters.AddWithValue("Contents", Contents);
                    int rv = cmd.ExecuteScalarInt32();
                    if (rv <= 0)
                        Err = "The template could not be saved.";

                    if (TemplateID > 0)
                    {
                        ChildTemplates.SaveChildenForTemplate(TemplateID, out Err, con);
                        if (!string.IsNullOrWhiteSpace(Err))
                            return false;
                    }

                    return TemplateID > 0;
                }
            }
            catch (Exception ex)
            {
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
                    string sql = @"DELETE FROM template
                    WHERE TemplateID=@TemplateID;";
                    var cmd = new MySqlCommand(sql, con);
                    cmd.Parameters.AddWithValue("TemplateID", TemplateID);
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

        public bool SaveForPage(int PageID, MySqlConnection ConX = null)
        {
            bool openConX = ConX == null;
            if (openConX)
            {
                ConX = new MySqlConnection(DBOps.ConnectionString);
                ConX.Open();
            }

            string sql = @"INSERT INTO pagetemplate (PageID,TemplateID,Seq)
                    VALUES(@PageID,@TemplateID,@Seq);";
            using (var cmd = new MySqlCommand(sql, ConX))
            {
                cmd.Parameters.AddWithValue("PageID", PageID);
                cmd.Parameters.AddWithValue("TemplateID", TemplateID);
                cmd.Parameters.AddWithValue("Seq", Sequence);
                cmd.ExecuteNonQuery();
            }

            if (openConX)
                ConX.Close();

            return true;
        }

        public bool SaveChildForTemplate(int ParentTemplateID, MySqlConnection ConX = null)
        {
            bool openConX = ConX == null;
            if (openConX)
            {
                ConX = new MySqlConnection(DBOps.ConnectionString);
                ConX.Open();
            }

            string sql = @"INSERT INTO templatetree (ParentTemplateID,ChildTemplateID,Seq)
                    VALUES(@ParentTemplateID,@ChildTemplateID,@Seq);";
            using (var cmd = new MySqlCommand(sql, ConX))
            {
                cmd.Parameters.AddWithValue("ParentTemplateID", ParentTemplateID);
                cmd.Parameters.AddWithValue("ChildTemplateID", TemplateID);
                cmd.Parameters.AddWithValue("Seq", Sequence);
                cmd.ExecuteNonQuery();
            }

            if (openConX)
                ConX.Close();

            return true;
        }


        public bool LoadChildTemplates(ref HashSet<int> IDs, MySqlConnection ConX = null, bool StubsOnly = false)
        {
            bool rv = true;
            bool openConX = ConX == null;
            if (openConX)
            {
                ConX = new MySqlConnection(DBOps.ConnectionString);
                ConX.Open();
            }
            try
            {
                string fields;
                if (StubsOnly) fields = "t.TemplateID,t.Description";
                else fields = "t.*";
                string sql = @"SELECT " + fields + @"
                    FROM template t
                    JOIN templatetree tt ON t.TemplateID=tt.ChildTemplateID
                    WHERE tt.ParentTemplateID=" + TemplateID + @"
                    ORDER BY tt.Seq,tt.ChildTemplateID;";
                using (var cmd = new MySqlCommand(sql, ConX))
                using (var rdr = cmd.ExecuteReader())
                {
                    while (rdr.Read())
                    {
                        var item = new Template();
                        item.Read(rdr, StubsOnly);
                        if (!IDs.Contains(item.TemplateID))
                        {
                            ChildTemplates.Add(item);
                            IDs.Add(item.TemplateID);
                        }
                    }
                }
                foreach (var child in ChildTemplates)
                    child.LoadChildTemplates(ref IDs, ConX);
            }
            finally
            {
                if (openConX)
                    ConX.Close();
            }
            return rv;
        }

        public void Read(MySqlDataReader rdr, bool StubOnly = false)
        {
            this.TemplateID = rdr.GetInt32("TemplateID");
            this.Description = rdr.GetString("Description").Trim();
            if (StubOnly) return;
            this.X = rdr.GetByte("X");
            this.Y = rdr.GetByte("Y");
            this.Width = rdr.GetByte("Width");
            this.Height = rdr.GetByte("Height");
            this.Expression = rdr.GetStringNullable("Expression").Trim();
            this.Contents = rdr.GetBytesNullable("Contents");
            this.URL = rdr.GetStringNullable("URL").Trim();
            this.ConvertContentsFromURL();
        }

        public void Compose(Page Page)
        {
            if (Page == null)
                return;
            if (Contents == null)
                Contents = Encoding.ASCII.GetBytes(new string(' ', 960));
            if (Contents.Length != 960)
                Contents = Pad(Contents, 960, 32);
            string val = "";
            var now = DateTime.Now;
            if ((Expression ?? "").ToLower() == "@pageframe")
                val = Page.PageNo.ToString() + Page.Frame;
            else if ((Expression ?? "").ToLower() == "@page")
                val = Page.PageNo.ToString();
            else if ((Expression ?? "").ToLower() == "@pageframe")
                val = Page.Frame;
            else if ((Expression ?? "").ToLower() == "@date")
                val = now.ToString("ddd dd MMM");
            else if ((Expression ?? "").ToLower() == "@time")
                val = now.ToString("HH:mm:ss");
            else if ((Expression ?? "").ToLower() == "@year")
                val = now.ToString("yyyy");
            else if ((Expression ?? "").ToLower() == "@version")
                val = "v" + Assembly.GetEntryAssembly().GetName().Version.ToString();
            else if ((Expression ?? "").ToLower().Contains("@feed="))
            {
                string url = GetExpression("@feed", Expression);
                var feed = Feed.Load(url, Expression);
            }
            if (val != "")
                val = val.PadLeft(Width);
            int added = 0;
            for (int y = Y; y < Y + Height; y++)
            {
                for (int x = X; x < X + Width; x++)
                {
                    byte b = 32;
                    if (added < val.Length) b = Convert.ToByte(val[added++]);
                    else b = GetByte(x, y);
                    Page.SetByte(x, y, b);
                }
            }
        }

        public static string GetExpression(string Key, string Expression)
        {
            string key = (Key ?? "").Trim().ToLower();
            var exprs = (Expression ?? "").Split(';');
            foreach (string e in exprs)
            {
                var expr = e.Split(new char[] { '=' }, 2);
                if (expr[0].Trim().ToLower() != key)
                    continue;
                if (expr.Length < 2)
                    continue;
                return expr[1].Trim().ToLower();
            }
            return "";
        }

        public Templates FlattenTemplates()
        {
            var rv = new Templates();
            AddChildTemplates(ref rv);
            return rv;
        }

        public void AddChildTemplates(ref Templates List)
        {
            List.Add(this);
            foreach (var t in ChildTemplates)
                t.AddChildTemplates(ref List);
        }

        public int CountChildren()
        {
            var val = 0;
            foreach (var t in ChildTemplates)
                val += t.CountChildrenInternal();
            return val;
        }

        private int CountChildrenInternal()
        {
            var val = 1;
            foreach (var t in ChildTemplates)
                val += t.CountChildrenInternal();
            return val;
        }

        public void SetSelectedTemplates()
        {
            var sel = (ChildTemplates ?? new Templates()).Select(t => t.TemplateID).Distinct().OrderBy(i => i);
            SelectedTemplates = string.Join(",", sel);
        }

        public override void Fixup()
        {
            // Templates
            ChildTemplates = new Templates();
            Templates templates = null;
            foreach (string cid in (SelectedTemplates ?? "").Split(','))
            {
                int id;
                int.TryParse(cid, out id);
                if (id <= 0)
                    continue;
                if (ChildTemplates.Any(t => t.TemplateID == id))
                    continue;
                if (templates == null)
                    templates = Templates.Load();
                var matched = templates.FirstOrDefault(t => t.TemplateID == id);
                if (matched != null)
                    ChildTemplates.Add(matched);
            }
        }
    }
}
