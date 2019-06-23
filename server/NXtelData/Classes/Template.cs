using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.ComponentModel.DataAnnotations;
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
        [Required]
        [StringLength(30)]
        public string Description { get; set; }
        [Required(ErrorMessage = "X must be between 0 and 39.")]
        [Range(0, 39, ErrorMessage = "X must be between 0 and 39.")]
        public byte X { get; set; }
        [Required(ErrorMessage = "Y must be between 0 and 23.")]
        [Range(0, 23, ErrorMessage = "Y must be between 0 and 23.")]
        public byte Y { get; set; }
        [Required(ErrorMessage = "Width must be between 0 and 40.")]
        [Range(0, 40, ErrorMessage = "Width must be between 0 and 40.")]
        public byte Width { get; set; }
        [Required(ErrorMessage = "Height must be between 0 and 24.")]
        [Range(0, 24, ErrorMessage = "Height must be between 0 and 24.")]
        public byte Height { get; set; }
        public string Expression { get; set; }
        public int Sequence { get; set; }
        public Feed Feed { get; set; }
        public Templates ChildTemplates { get; set; }
        public Template ParentTemplate { get; set; }
        public string SelectedTemplates { get; set; }
        public bool IsContainer { get; set; }
        public bool IsRepeatingItem { get; set; }
        public bool CanExpand { get; set; }
        public bool StickToTop { get; set; }
        public bool StickToBottom { get; set; }
        public bool ContinuedOver { get; set; }
        public bool ContinuedFrom { get; set; }
        public bool NotContinuedOver { get; set; }
        public bool NotContinuedFrom { get; set; }
        public bool KeepTogether { get; set; }
        [Required(ErrorMessage = "Orphan/Widow must be between 0 and 24.")]
        [Range(0, 24, ErrorMessage = "Orphan/Widow must be between 0 and 24.")]
        [DisplayName("Orphan/Widow")]
        public byte MinOrphanWidowRows { get; set; }
        public int? CurrentFeedItem { get; set; }
        public int RepeatingItemLinesAdded { get; set; }
        public bool Active { get; set; }
        public int OwnerID { get; set; }
        public string Environment { get; set; }
        public int CopyingFromID { get; set; }
        public int Sort { get; set; }

        public Template()
        {
            TemplateID = Sort  = - 1;
            Description = Expression = SelectedTemplates = "";
            Active = true;
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
                    item.LoadChildTemplates(ref ids, item, con);
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
                using (var ConX = new MySqlConnection(DBOps.GetConnectionString(Template.Environment)))
                {
                    ConX.Open();
                    if (string.IsNullOrWhiteSpace(Template.Environment))
                    {
                        if (Template.TemplateID <= 0)
                            return Template.Create(out Err, ConX);
                        else
                            return Template.Update(out Err, ConX);
                    }
                    else
                    {
                        return Template.CopySave(out Err, ConX);
                    }
                }
            }
            catch (Exception ex)
            {
                Err = ex.Message;
                return false;
            }
        }

        public bool Create(out string Err, MySqlConnection ConX = null)
        {
            Err = "";
            bool openConX = ConX == null;
            if (openConX)
            {
                ConX = new MySqlConnection(DBOps.ConnectionString);
                ConX.Open();
            }
            try
            {
                string sql = @"INSERT INTO template
                    (Description,X,Y,Width,Height,Expression,URL,Contents,IsContainer,IsRepeatingItem,CanExpand,
                    StickToTop,StickToBottom,ContinuedOver,ContinuedFrom,NotContinuedOver,NotContinuedFrom,KeepTogether,
                    MinOrphanWidowRows,OwnerID)
                    VALUES(@Description,@X,@Y,@Width,@Height,@Expression,@URL,@Contents,@IsContainer,@IsRepeatingItem,@CanExpand,
                    @StickToTop,@StickToBottom,@ContinuedOver,@ContinuedFrom,@NotContinuedOver,@NotContinuedFrom,@KeepTogether,
                    @MinOrphanWidowRows,@OwnerID);
                    SELECT LAST_INSERT_ID();";
                var cmd = new MySqlCommand(sql, ConX);
                cmd.Parameters.AddWithValue("Description", (Description ?? "").Trim());
                cmd.Parameters.AddWithValue("X", X);
                cmd.Parameters.AddWithValue("Y", Y);
                cmd.Parameters.AddWithValue("Width", Width);
                cmd.Parameters.AddWithValue("Height", Height);
                cmd.Parameters.AddWithValue("Expression", (Expression ?? "").Trim());
                cmd.Parameters.AddWithValue("URL", (URL ?? "").Trim());
                cmd.Parameters.AddWithValue("Contents", Contents);
                cmd.Parameters.AddWithValue("IsContainer", IsContainer);
                cmd.Parameters.AddWithValue("IsRepeatingItem", IsRepeatingItem);
                cmd.Parameters.AddWithValue("CanExpand", CanExpand);
                cmd.Parameters.AddWithValue("StickToTop", StickToTop);
                cmd.Parameters.AddWithValue("StickToBottom", StickToBottom);
                cmd.Parameters.AddWithValue("ContinuedOver", ContinuedOver);
                cmd.Parameters.AddWithValue("ContinuedFrom", ContinuedFrom);
                cmd.Parameters.AddWithValue("NotContinuedOver", NotContinuedOver);
                cmd.Parameters.AddWithValue("NotContinuedFrom", NotContinuedFrom);
                cmd.Parameters.AddWithValue("KeepTogether", KeepTogether);
                cmd.Parameters.AddWithValue("MinOrphanWidowRows", MinOrphanWidowRows);
                int? ownerID = OwnerID <= 0 ? null : (int?)OwnerID;
                cmd.Parameters.AddWithValue("OwnerID", ownerID);
                int rv = cmd.ExecuteScalarInt32();
                if (rv > 0)
                    TemplateID = rv;
                if (TemplateID <= 0)
                    Err = "The template could not be saved.";

                if (TemplateID > 0)
                {
                    ChildTemplates.SaveChildenForTemplate(TemplateID, out Err, ConX);
                    if (!string.IsNullOrWhiteSpace(Err))
                        return false;
                }

                return TemplateID > 0;
            }
            catch (Exception ex)
            {
                Err = ex.Message;
                return false;
            }
            finally
            {
                if (openConX)
                    ConX.Close();
            }
        }

        public bool Update(out string Err, MySqlConnection ConX = null, bool SaveChildren = true)
        {
            Err = "";
            bool openConX = ConX == null;
            if (openConX)
            {
                ConX = new MySqlConnection(DBOps.ConnectionString);
                ConX.Open();
            }
            try
            {
                string sql = @"UPDATE template
                    SET Description=@Description,X=@X,Y=@Y,Width=@Width,Height=@Height,Expression=@Expression,URL=@URL,
                    Contents=@Contents,IsContainer=@IsContainer,IsRepeatingItem=@IsRepeatingItem,CanExpand=@CanExpand,
                    StickToTop=@StickToTop,StickToBottom=@StickToBottom,ContinuedOver=@ContinuedOver,
                    ContinuedFrom=@ContinuedFrom,NotContinuedOver=@NotContinuedOver,NotContinuedFrom=@NotContinuedFrom,
                    KeepTogether=@KeepTogether,MinOrphanWidowRows=@MinOrphanWidowRows,OwnerID=@OwnerID
                    WHERE TemplateID=@TemplateID;
                    SELECT ROW_COUNT();";
                var cmd = new MySqlCommand(sql, ConX);
                cmd.Parameters.AddWithValue("TemplateID", TemplateID);
                cmd.Parameters.AddWithValue("Description", (Description ?? "").Trim());
                cmd.Parameters.AddWithValue("X", X);
                cmd.Parameters.AddWithValue("Y", Y);
                cmd.Parameters.AddWithValue("Width", Width);
                cmd.Parameters.AddWithValue("Height", Height);
                cmd.Parameters.AddWithValue("Expression", (Expression ?? "").Trim());
                cmd.Parameters.AddWithValue("URL", (URL ?? "").Trim());
                cmd.Parameters.AddWithValue("Contents", Contents);
                cmd.Parameters.AddWithValue("IsContainer", IsContainer);
                cmd.Parameters.AddWithValue("IsRepeatingItem", IsRepeatingItem);
                cmd.Parameters.AddWithValue("CanExpand", CanExpand);
                cmd.Parameters.AddWithValue("StickToTop", StickToTop);
                cmd.Parameters.AddWithValue("StickToBottom", StickToBottom);
                cmd.Parameters.AddWithValue("ContinuedOver", ContinuedOver);
                cmd.Parameters.AddWithValue("ContinuedFrom", ContinuedFrom);
                cmd.Parameters.AddWithValue("NotContinuedOver", NotContinuedOver);
                cmd.Parameters.AddWithValue("NotContinuedFrom", NotContinuedFrom);
                cmd.Parameters.AddWithValue("KeepTogether", KeepTogether);
                cmd.Parameters.AddWithValue("MinOrphanWidowRows", MinOrphanWidowRows);
                int? ownerID = OwnerID <= 0 ? null : (int?)OwnerID;
                cmd.Parameters.AddWithValue("OwnerID", ownerID);
                int rv = cmd.ExecuteScalarInt32();
                if (rv <= 0)
                    Err = "The template could not be saved.";

                if (TemplateID > 0 && SaveChildren)
                {
                    ChildTemplates.SaveChildenForTemplate(TemplateID, out Err, ConX);
                    if (!string.IsNullOrWhiteSpace(Err))
                        return false;
                }

                return TemplateID > 0;
            }
            catch (Exception ex)
            {
                Err = ex.Message;
                return false;
            }
            finally
            {
                if (openConX)
                    ConX.Close();
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

        public bool LoadChildTemplates(ref HashSet<int> IDs, Template ParentTemplate, MySqlConnection ConX = null, bool StubsOnly = false)
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
                if (StubsOnly) fields = "t.TemplateID,t.Description,t.OwnerID";
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
                        item.ParentTemplate = ParentTemplate;
                        item.Read(rdr, StubsOnly);
                        if (!IDs.Contains(item.TemplateID))
                        {
                            ChildTemplates.Add(item);
                            IDs.Add(item.TemplateID);
                        }
                    }
                }
                foreach (var child in ChildTemplates)
                    child.LoadChildTemplates(ref IDs, child, ConX);
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
            this.OwnerID = rdr.GetInt32Safe("OwnerID");
            if (StubOnly) return;
            this.X = rdr.GetByte("X");
            this.Y = rdr.GetByte("Y");
            this.Width = rdr.GetByte("Width");
            this.Height = rdr.GetByte("Height");
            this.Expression = rdr.GetStringNullable("Expression").Trim();
            this.URL = rdr.GetStringNullable("URL").Trim();
            this.Contents = rdr.GetBytesNullable("Contents");
            this.IsContainer = rdr.GetBoolean("IsContainer");
            this.IsRepeatingItem = rdr.GetBoolean("IsRepeatingItem");
            this.CanExpand = rdr.GetBoolean("CanExpand");
            this.StickToTop = rdr.GetBoolean("StickToTop");
            this.StickToBottom = rdr.GetBoolean("StickToBottom");
            this.ContinuedOver = rdr.GetBoolean("ContinuedOver");
            this.ContinuedFrom = rdr.GetBoolean("ContinuedFrom");
            this.MinOrphanWidowRows = rdr.GetByte("MinOrphanWidowRows");
            this.NotContinuedOver = rdr.GetBoolean("NotContinuedOver");
            this.NotContinuedFrom = rdr.GetBoolean("NotContinuedFrom");
            this.KeepTogether = rdr.GetBoolean("KeepTogether");
            this.ConvertContentsFromURL();
        }

        public Feed GetFeedRecursive()
        {
            if (Feed != null)
                return Feed;
            if (ParentTemplate != null)
                return ParentTemplate.GetFeedRecursive();
            return null;
        }

        public Template GetRootTemplate()
        {
            if (ParentTemplate == null)
                return this;
            return ParentTemplate.GetRootTemplate();
        }

        public Template GetContainer()
        {
            if (IsContainer)
                return this;
            if (ParentTemplate == null)
                return null;
            return ParentTemplate.GetContainer();
        }

        public Template GetRepeatingItem()
        {
            if (IsRepeatingItem)
                return this;
            if (ParentTemplate == null)
                return null;
            return ParentTemplate.GetRepeatingItem();
        }

        public int? GetCurrentFeedItem()
        {
            if (CurrentFeedItem != null)
                return CurrentFeedItem;
            if (ParentTemplate != null)
                return ParentTemplate.GetCurrentFeedItem();
            return null;
        }

        public void Compose(Page Page, DateTime? LastSeen = null)
        {
            if (!Active)
            {
                //Console.WriteLine("Page " + Page.PageAndFrame + ": " + this.Description + " (SKIPPED)");
                return;
            }
            int added;
            if (Page == null)
                return;
            //Console.WriteLine("Page " + Page.PageAndFrame + ": " + this.Description);
            if (Contents == null)
                Contents = Encoding.ASCII.GetBytes(new string(' ', 960));
            if (Contents.Length != 960)
                Contents = Pad(Contents, 960, 32);
            if (IsContainer)
            {
                //Page.ContentHeight = Height;
                Page.ContentCurrentLine = Y - 1;
            }
            if (IsRepeatingItem)
            {
                var feed = GetFeedRecursive();
                var container = this.GetRootTemplate().FlattenTemplates().FirstOrDefault(t => t.IsContainer);
                for (int i = 0; i < feed.Items.Count; i++)
                {
                    CurrentFeedItem = i;
                    //var page = new Page();
                    foreach (var ct in FlattenTemplates() ?? new Templates())
                    {
                        if (ct == this)
                            continue;
                        ct.Compose(Page);
                    }
                }
                CurrentFeedItem = null;
                return;
            }
            string val = "";
            var now = DateTime.Now;
            string expr = (Expression ?? "").ToLower();
            if (expr == "@pageframe")
                val = Page.PageNo.ToString() + Page.Frame;
            else if (expr == "@page")
                val = Page.PageNo.ToString();
            else if (expr == "@pageframe")
                val = Page.Frame;
            else if (Options.ShowStaticTimeAndDate && expr == "@date")
                val = now.ToString("ddd dd MMM");
            else if (Options.ShowStaticTimeAndDate && expr == "@time")
                val = now.ToString("HH:mm:ss");
            else if (Options.ShowStaticTimeAndDate && expr == "@year")
                val = now.ToString("yyyy");
            else if (expr == "@lastseen" && LastSeen != null)
                if (LastSeen == DateTime.MinValue)
                val = "                   Never";
            else
                val = ((DateTime)LastSeen).ToString("ddd dd MMM yyyy HH:mm:ss");
            else if (expr == "@version")
                val = "v" + Assembly.GetEntryAssembly().GetName().Version.ToString();
            else if (expr == "@ts.percent")
            {
                double total = Page.PageRangeCount == 0 ? 1 : Page.PageRangeCount - 2;
                double seq = Page.PageRangeCount == 0 ? 1 : Page.PageRangeSequence;
                int pct = Convert.ToInt32(Math.Round(seq * 100d / total, 0));
                val = pct.ToString().PadLeft(3);
            }
            else if (expr.Contains("@ts.progress"))
            {
                byte half, full;
                string ge = GetExpression("@ts.progress.half", Expression);
                byte.TryParse(ge, out half);
                if (half < 32 || half > 127) half = 36;
                ge = GetExpression("@ts.progress.full", Expression);
                byte.TryParse(ge, out full);
                if (full < 32 || full > 127) full = 44;
                double total = Page.PageRangeCount == 0 ? 1 : Page.PageRangeCount - 2;
                double seq = Page.PageRangeCount == 0 ? 1 : Page.PageRangeSequence;
                double progressWidth = Math.Round(2 * seq * Width / total, 0) / 2;
                int fullWidth = Convert.ToInt32(progressWidth);
                val = new string(Convert.ToChar(full), fullWidth);
                if (progressWidth > fullWidth)
                    val += new string(Convert.ToChar(half), 1);
                val += new string(' ', Width - val.Length);
            }
            else if (expr.StartsWith("@feed.item.number"))
            {
                int? cfi = GetCurrentFeedItem();
                if (cfi != null)
                    val = ((int)cfi + 1).ToString();
            }
            else if (expr.StartsWith("@feed.item.data"))
            {
                var firi = GetRepeatingItem();
                if (firi != null)
                    firi.RepeatingItemLinesAdded = 0;
                string dataItem = GetExpression("@feed.item.data", Expression);
                int dataItemIndex;
                int.TryParse(dataItem, out dataItemIndex);
                int? cfi = GetCurrentFeedItem();
                var feed = GetFeedRecursive();
                if (cfi != null && cfi >= 0 && cfi < feed.Items.Count)
                {
                    var feedItem = feed.Items[(int)cfi];
                    if (feedItem.Values.ContainsKey(dataItemIndex))
                    {
                        var container = GetContainer();
                        val = (feedItem.Values[dataItemIndex] ?? "").Trim();
                        var words = feedItem.SplitByWords(dataItemIndex, Width);
                        added = 0;
                        int line = 0;
                        foreach (var w in words)
                        {
                            if (Page.ContentHeight >= container.Height)
                                return;
                            var word = (w.Trim() + new String(' ', Width));
                            if (line >= Height)
                            {
                                added++;
                                if (firi != null)
                                    firi.RepeatingItemLinesAdded++;
                            }
                            Page.ContentHeight++;
                            Page.ContentCurrentLine++;
                            int y = Page.ContentCurrentLine;

                            int i = 0;
                            for (int x = X; x < X + Width; x++)
                            {
                                byte b = 32;
                                if (word[i] > 255)
                                {
                                    b = Character.Substitute(word[i]);
                                    if (b != 0)
                                        Page.SetByte(x, y, b);
                                }
                                else
                                {
                                    b = Convert.ToByte(word[i++]);
                                    Page.SetByte(x, y, b);
                                }
                            }
                            line++;
                            y++;
                        }
                    }
                }
                return;
            }
            else if (expr.Contains("@feed="))
            {
                var container = this.FlattenTemplates().FirstOrDefault(t => t.IsContainer);
                var repeatingItem = this.FlattenTemplates().FirstOrDefault(t => t.IsRepeatingItem);
                if (container != null && repeatingItem != null)
                {
                    string url = GetExpression("@feed", Expression);
                    Feed = Feed.Load(url, Expression);
                }
            }
            if (val != "")
                val = val.PadLeft(Width);
            added = 0;
            int yline = Y;
            var ri = GetRepeatingItem();
            if (ri != null)
                yline = Page.ContentCurrentLine + 1 + ri.RepeatingItemLinesAdded;
            if (this.TemplateID == 25)
                Debug.Print(yline.ToString());
            for (int y = yline; y < yline + Height; y++)
            {
                for (int x = X; x < X + Width; x++)
                {
                    byte b = 32;
                    if (added < val.Length)
                    {
                        if (val[added] > 255)
                        {
                            b = Character.Substitute(val[added]);
                            if (b != 0)

                                Page.SetByte(x, y, b);
                        }
                        else
                        {
                            b = Convert.ToByte(val[added++]);
                            Page.SetByte(x, y, b);
                        }
                    }
                    else
                    {
                        b = GetByte(x, y);
                        Page.SetByte(x, y, b);
                    }
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
                return expr[1].Trim();
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

        public void InactivateMatchedExpression(string Expression)
        {
            if ((this.Expression ?? "").Contains(Expression))
                this.InactivateRecursive();
            foreach (var t in ChildTemplates)
                t.InactivateMatchedExpression(Expression);
        }

        public void ActivateAll()
        {
            this.Active = true;
            foreach (var t in ChildTemplates)
                t.ActivateAll();
        }

        public void InactivateRecursive()
        {
            this.Active = false;
            foreach (var t in ChildTemplates)
                t.InactivateRecursive();
        }

        public int GetIDFromDescription(MySqlConnection ConX = null, bool ResetIfNotFound = true)
        {
            int rv = -1;
            bool found = false;
            bool openConX = ConX == null;
            if (openConX)
            {
                ConX = new MySqlConnection(DBOps.ConnectionString);
                ConX.Open();
            }
            string sql = @"SELECT TemplateID FROM template
                WHERE template.Description=@Description
                ORDER BY TemplateID LIMIT 1;";
            using (var cmd = new MySqlCommand(sql, ConX))
            {
                cmd.Parameters.AddWithValue("Description", (Description ?? "").Trim());
                using (var rdr = cmd.ExecuteReader())
                {
                    while (rdr.Read())
                    {
                        rv = rdr.GetInt32("TemplateID");
                        TemplateID = rv;
                        found = true;
                        break;
                    }
                }
            }
            OwnerID = -1;

            if (ResetIfNotFound && !found)
                TemplateID = -1;

            if (openConX)
                ConX.Close();

            return rv;
        }

        public bool CopySave(out string Err, MySqlConnection ConX)
        {
            Err = "";
            try
            {
                var ids = new HashSet<int>();
                ids.Add(this.CopyingFromID);
                foreach (var ct in this.ChildTemplates ?? new Templates())
                    ids.Add(ct.TemplateID);
                this.LoadChildTemplates(ref ids, this);
                var srcIDs = new List<int>();
                var destIDs = new Dictionary<int, int>();
                foreach (var srcID in ids.AsEnumerable().Reverse().ToList())
                {
                    srcIDs.Add(srcID);
                    destIDs.Add(srcID, -1);
                }
                foreach (int srcID in srcIDs)
                {
                    Template t;
                    if (srcID == this.CopyingFromID)
                        t = this;
                    else
                        t = Template.Load(srcID);
                    t.GetIDFromDescription(ConX);
                    foreach (var ct in t.ChildTemplates ?? new Templates())
                        ct.TemplateID = destIDs[ct.TemplateID];
                    bool success;
                    if (t.TemplateID <= 0)
                        success = t.Create(out Err, ConX);
                    else
                        success = t.Update(out Err, ConX);
                    destIDs[srcID] = t.TemplateID;
                    if (!success)
                        return false;
                }
                return true;
            }
            catch (Exception ex)
            {
                Err = ex.Message;
                return false;
            }
        }
    }
}
