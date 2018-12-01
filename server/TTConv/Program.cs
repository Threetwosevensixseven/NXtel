using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using TTConv.Classes;

namespace TTConv
{
    public class Program
    {
        public static int Main(string[] args)
        {
            if (args == null || args.Length == 0)
                return PrintHelp();
            var u = args.Where(a => a.StartsWith("/u", StringComparison.CurrentCultureIgnoreCase)).ToList();
            var b = args.Where(a => a.Equals("/b", StringComparison.CurrentCultureIgnoreCase)).ToList();
            var files = args.Where(a => !a.StartsWith("/u", StringComparison.CurrentCultureIgnoreCase)
                && !a.Equals("/b", StringComparison.CurrentCultureIgnoreCase)).ToList();
            if (args.Length != u.Count + b.Count + files.Count)
                return PrintHelp();
            if (u.Count > 1)
                return PrintHelp();
            if (b.Count > 1)
                return PrintHelp();
            if (files.Count < 1 || files.Count > 2)
                return PrintHelp();
            var site = Sites.NXtelPage;
            bool browse = b.Count == 1 || (files.Count == 1);
            if (u.Count == 1)
            {
                if (u[0].Equals("/u", StringComparison.CurrentCultureIgnoreCase))
                    site = Sites.NXtelPage;
                else if (u[0].Equals("/u:n", StringComparison.CurrentCultureIgnoreCase))
                    site = Sites.NXtelPage;
                else if (u[0].Equals("/u:t", StringComparison.CurrentCultureIgnoreCase))
                    site = Sites.NXtelTemplate;
                else if (u[0].Equals("/u:e", StringComparison.CurrentCultureIgnoreCase))
                    site = Sites.EditTF;
                else if (u[0].Equals("/u:z", StringComparison.CurrentCultureIgnoreCase))
                    site = Sites.ZXNet;
                else
                    return PrintError("Unknown site " + u[0] + ".");
            }
            string extSrc = Path.GetExtension(files[0]).ToUpper();
            string extDst = ".TTU";
            if (files.Count > 1)
                extDst = Path.GetExtension(files[1]).ToUpper();
            else
                files.Add("");
            Formats formatSrc, formatDest;
            if (extSrc == ".TT7")
                formatSrc = Formats.TT7;
            else if (extSrc == ".TT8")
                formatSrc = Formats.TT8;
            else if (extSrc == ".TTU")
                formatSrc = Formats.TTU;
            else
                return PrintError("Unknown inputfile extension  " + extSrc + ".");
            if (extDst == ".TT7")
                formatDest = Formats.TT7;
            else if (extDst == ".TT8")
                formatDest = Formats.TT8;
            else if (extDst == ".TTU")
                formatDest = Formats.TTU;
            else
                return PrintError("Unknown outputfile extension  " + extDst + ".");
            if (!File.Exists(files[0]))
                return PrintError("Inputfile " + files[0] + " not found.");
            return Process(files[0], formatSrc, files[1], formatDest, site, browse);
        }

        public static int Process(string NameSrc, Formats FormatSrc, string NameDst, Formats FormatDst, 
            Sites Site, bool Browse)
        {
            var binSrc = new byte[0];
            var txtSrc = "";
            if (FormatSrc == Formats.TT7)
            {
                try
                {
                    binSrc = File.ReadAllBytes(NameSrc);
                    binSrc = Converter.FromTT7(binSrc);
                }
                catch
                {
                    return Program.PrintError("Inputfile " + NameSrc + " could not be opened.");
                }
            }
            else if (FormatSrc == Formats.TT8)
            {
                try
                {
                    binSrc = File.ReadAllBytes(NameSrc);
                }
                catch
                {
                    return Program.PrintError("Inputfile " + NameSrc + " could not be opened.");
                }
            }
            else // FormatSrc == Formats.TTU
            {
                try
                {
                    txtSrc = File.ReadAllText(NameSrc);
                    binSrc = Converter.FromTTU(txtSrc);
                }
                catch
                {
                    return Program.PrintError("Inputfile " + NameSrc + " could not be opened.");
                }
            }
            if (!(binSrc.Length == 960 || binSrc.Length == 1000))
                return Program.PrintError("Inputfile " + NameSrc + " is the wrong length.");
            byte[] binDst = new byte[0];
            string txtDst = "";
            if (FormatDst == Formats.TT7)
            {
                try
                {
                    binDst = Converter.ToTT7(binSrc);
                }
                catch
                {
                    return Program.PrintError("Inputfile " + NameSrc + " could not be converted to TT7 format.");
                }
            }
            else if (FormatDst == Formats.TT8)
            {
                binDst = binSrc;
            }
            else // FormatDst == Formats.TTU
            {
                txtDst = Converter.ToTTU(binSrc, Site.GetURL());
            }
            try
            {
                if (!string.IsNullOrWhiteSpace(NameDst))
                {
                    if (FormatDst == Formats.TTU)
                    {
                        File.WriteAllText(NameDst, txtDst);
                        Program.PrintMessage("Created " + NameDst + " in "
                            + Site.GetDescription() + " URL format.");
                    }
                    else
                    {
                        File.WriteAllBytes(NameDst, binDst);
                        Program.PrintMessage("Created " + NameDst + " in "
                            + FormatDst.GetDescription() + " format.");
                    }
                }
                if (Browse && FormatDst != Formats.TTU)
                    txtDst = Converter.ToTTU(binSrc, Site.GetURL());
                if (Browse)
                {
                    var mp = new MultiPlatform();
                    if (!mp.OpenURL(txtDst))
                        return Program.PrintError("Could not send page data to "
                        + Site.GetURL().Replace("#", "").Replace("<Data>", "").Replace("<NewID>", "").TrimEnd('/') + ".");
                    Program.PrintMessage("Sent page data to "
                        + Site.GetURL().Replace("#", "").Replace("<Data>", "").Replace("<NewID>", "").TrimEnd('/')
                        + " in " + Site.GetDescription() + " format.");
                }
                return 0;
            }
            catch
            {
                return Program.PrintError("Outputfile " + NameDst + " could not be created.");
            }
        }

        public static int PrintHelp()
        {
            Console.WriteLine(@"Converts teletext files between 8-bit, 7-bit and URL formats.

TTCONV [[/u[:{n|t|e|z}]] [/b] inputfile [outputfile]]

  /u          When outputfile has a .TTU extension or /b is specified, this
              option forms the data URL in one of four formats:
                n  NXtel page      https://admin.nxtel.org/Page/Edit/#<Data>
                t  NXtel template  https://admin.nxtel.org/Template/Edit/#<Data>
                e  Edit-tf         https://edit.tf/#<Data>
                z  ZXNet           https://zxnet.co.uk/teletext/editor/#<Data>
              If not specified, Nxtel page format is used.
              
  /b          The inputfile is sent to the default browser in the format 
              specified by /u, defaulting to Nxtel page format if /u is not
              supplied. If outputfile is omitted then the page data is always
              send to the browser, even if /b is omitted.
              
  inputfile   File to be converted (.TT8, .TT7 or .TTU extension).
  
  outputfile  Optional file to be generated (.TT8, .TT7 or .TTU extension).
  
  extension   Inputfile and outputfile can be supplied in one of three formats, 
              denoted by their file extension:
                .TT8  8-bit teletext format
                .TT7  7-bit teletext format
                .TTU  URL teletext format

  .TT8        These files contain exactly 960 or 1000 bytes in 8-bit encoding.
              They correspond to the BBC Micro Computer Display RAM format
              exported by the ZXNet editor.

  .TT7        These files are similar to .TT8 files, but with 7-bit encoding.
              Any bytes larger than 127 (0x7f) have 128 (0x80) subtracted from
              them, and are proceeded by an escape byte with the value of 27
              (0x1b). Files in this format have a variable length, and represent
              the page data transmitted from the NXtel server to a client. TT7 
              files are suitable for serving by a static failover server.

  .TTU        These files contain a URL suitable for importing into NXtel,
              Edit-tf, ZXNet or wxTED. They are the universal import/export 
              format.");
            return 0;
        }

        public static int PrintError(string Error)
        {
            Console.WriteLine(Error);
            return 1;
        }

        public static int PrintMessage(string Error)
        {
            Console.WriteLine(Error);
            return 0;
        }
    }
}
