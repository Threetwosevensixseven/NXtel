using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;

namespace NXtelData
{
    public class ConsoleLogger : IDisposable
    {

        FileStream fileStream;
        StreamWriter fileWriter;
        TextWriter doubleWriter;
        TextWriter oldOut;
        static DateTime lastDate = DateTime.Today;

        class DoubleWriter : TextWriter
        {

            TextWriter one;
            TextWriter two;

            public DoubleWriter(TextWriter one, TextWriter two)
            {
                this.one = one;
                this.two = two;
                this.one.WriteLine();
            }

            public override Encoding Encoding
            {
                get { return one.Encoding; }
            }

            public override void Flush()
            {
                one.Flush();
                two.Flush();
            }

            public override void Write(char value)
            {
                var today = DateTime.Today;
                if (today > lastDate)
                {
                    one.Write("\r\n" + today.ToShortDateString() + ":\r\n");
                    lastDate = today;
                }
                one.Write(value);
                two.Write(value);
            }

        }

        public ConsoleLogger(string path)
        {
            oldOut = Console.Out;

            try
            {
                //fileStream = File.Create(path);
                fileStream = File.Open(path, FileMode.Append, FileAccess.Write, FileShare.ReadWrite);

                fileWriter = new StreamWriter(fileStream);
                fileWriter.AutoFlush = true;

                doubleWriter = new DoubleWriter(fileWriter, oldOut);
            }
            catch (Exception e)
            {
                Console.WriteLine("Cannot open log file for writing");
                Console.WriteLine(e.Message);
                return;
            }
            Console.SetOut(doubleWriter);
        }

        public void Dispose()
        {
            Console.SetOut(oldOut);
            if (fileWriter != null)
            {
                fileWriter.Flush();
                fileWriter.Close();
                fileWriter = null;
            }
            if (fileStream != null)
            {
                fileStream.Close();
                fileStream = null;
            }
        }
    }
}
