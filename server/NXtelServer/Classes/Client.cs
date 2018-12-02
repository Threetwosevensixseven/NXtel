using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Net;
using System.Text;
using System.Threading.Tasks;
using NXtelData;

namespace NXtelServer.Classes
{
    public class Client
    {
        public const byte ENTER = 0x5F;
        public IPEndPoint remoteEndPoint;
        public DateTime connectedAt;
        public ClientStates clientState;
        public string commandIssued = string.Empty;
        public Stack<Page> PageHistory;
        public Queue<Byte> KeyBuffer;
        public string CurrentCommand;
        public CommandStates CommandState;

        public Client(IPEndPoint _remoteEndPoint, DateTime _connectedAt, ClientStates _clientState)
        {
            this.remoteEndPoint = _remoteEndPoint;
            this.connectedAt = _connectedAt;
            this.clientState = _clientState;
            this.PageHistory = new Stack<Page>();
            this.KeyBuffer = new Queue<Byte>();
            this.CurrentCommand = "";
            this.CommandState = CommandStates.RegularRouting;
        }

        public Page CurrentPage
        {
            get
            {
                if (PageHistory.Count == 0)
                    return new Page();
                return PageHistory.Peek();
            }
        }

        public bool ProcessInput(byte[] Chars, int Received, out Page NextPage)
        {
            //Page first = null;
            //foreach (var item in PageHistory)
            //    first = item;
            //Debug.Assert(first.Routing.Count == 1);

            for (int i = 0; i < Received; i++)
                KeyBuffer.Enqueue(Chars[i]);

            NextPage = null;
            int count = KeyBuffer.Count;
            for (int i = 0; i < count; i++)
            {
                var b = KeyBuffer.Peek();

                if (CommandState == CommandStates.InsideStarPageCommand)
                {
                    if (b == '*')
                    {
                        CommandState = CommandStates.InsideFastTextCommand;
                        KeyBuffer.Dequeue();
                        continue;
                    }

                    if (b >= '0' && b <= '9')
                    {
                        KeyBuffer.Dequeue();
                        CurrentCommand += Convert.ToChar(b).ToString();
                        //Console.WriteLine(string.Format("Inside Star Page Command, Adding {0}; CurrentCommand: '{1}' (", b.ToString("X2"), CurrentCommand) + string.Format("{0}:{1}", remoteEndPoint.Address.ToString(), remoteEndPoint.Port) + ")");
                        continue;
                    }
                    if (b == ENTER)
                    {
                        //Console.WriteLine(string.Format("Exiting Star Page Command; CurrentCommand: '{0}' (", CurrentCommand) + string.Format("{0}:{1}", remoteEndPoint.Address.ToString(), remoteEndPoint.Port) + ")");
                        KeyBuffer.Dequeue();
                        if (CurrentCommand == "00") // Previous page
                        {
                            CommandState = CommandStates.RegularRouting;
                            CurrentCommand = "";
                            if (PageHistory.Count > 1)
                                PageHistory.Pop();
                            NextPage = PageHistory.Peek();
                            Debug.Assert(PageHistory.Count > 0);
                            return true;
                        }
                        else
                        {
                            int pageNo;
                            int.TryParse(CurrentCommand, out pageNo);
                            NextPage = Page.Load(pageNo, 0);
                            if (NextPage.PageNo != pageNo)
                                NextPage = Page.Load(1, 0);
                            PageHistory.Push(NextPage);
                            CommandState = CommandStates.RegularRouting;
                            CurrentCommand = "";
                            return true;
                        }
                    }
                    KeyBuffer.Dequeue();
                    CommandState = CommandStates.RegularRouting;
                    CurrentCommand = "";
                    //Console.WriteLine(string.Format("Exiting Star Page Command, Invalid {0}; CurrentCommand: '{1}' (", b.ToString("X2"), CurrentCommand) + string.Format("{0}:{1}", remoteEndPoint.Address.ToString(), remoteEndPoint.Port) + ")");
                    continue;
                }

                if (CommandState == CommandStates.RegularRouting)
                {
                    if (b == '*')
                    {
                        //Console.WriteLine(string.Format("Entering Star Page Command; CurrentCommand: '{0}' (", CurrentCommand) + string.Format("{0}:{1}", remoteEndPoint.Address.ToString(), remoteEndPoint.Port) + ")");
                        CommandState = CommandStates.InsideStarPageCommand;
                        KeyBuffer.Dequeue();
                        continue;
                    }
                    //Console.WriteLine(string.Format("Outside Commands, Processing {0} (", b.ToString("X2")) + string.Format("{0}:{1}", remoteEndPoint.Address.ToString(), remoteEndPoint.Port) + ")");
                    var route = CurrentPage.Routing.FirstOrDefault(r => r.KeyCode == b);
                    if (route != null)
                    {
                        if (CurrentPage.PageType == PageTypes.TeleSoftware && route.NextPageNo != null && route.NextFrameNo != null)
                        {
                            NextPage = Page.Load((int)route.NextPageNo, (int)route.NextFrameNo);
                            PageHistory.Push(NextPage);
                            KeyBuffer.Dequeue();
                            return true;
                        }
                        else if (route.GoesToPageNo >= 0 && route.GoesToFrameNo >= 0 && route.GoesToFrameNo <= 25)
                        {
                            NextPage = Page.Load(route.GoesToPageNo, route.GoesToFrameNo);
                            PageHistory.Push(NextPage);
                            KeyBuffer.Dequeue();
                            return true;
                        }
                        KeyBuffer.Dequeue();
                        return false;
                    }
                    KeyBuffer.Dequeue();
                }
                if (CommandState == CommandStates.InsideFastTextCommand)
                {
                    b = KeyBuffer.Peek();

                    if (b >= '0' && b <= '9')
                    {
                        KeyBuffer.Dequeue();
                        CurrentCommand += Convert.ToChar(b).ToString();
                        continue;
                    }

                    if (b == ENTER)
                    {
                        KeyBuffer.Dequeue();
                        int col;
                        if (!int.TryParse(CurrentCommand, out col))
                            col = -1;
                        if (col < 0 || col > 7 || PageHistory.Count == 0 || PageHistory.Peek().Routing == null)
                        {
                            CommandState = CommandStates.RegularRouting;
                            CurrentCommand = "";
                            continue;
                        }
                        byte colour = Convert.ToByte(col | 0x80);
                        foreach (var route in PageHistory.Peek().Routing)
                        {
                            if (route.KeyCode == colour)
                            {
                                if (route.GoesToPageNo >= 0 && route.GoesToFrameNo >= 0 && route.GoesToFrameNo <= 25)
                                {
                                    NextPage = Page.Load(route.GoesToPageNo, route.GoesToFrameNo);
                                    PageHistory.Push(NextPage);
                                    CommandState = CommandStates.RegularRouting;
                                    CurrentCommand = "";
                                    return true;
                                }
                            }
                        }
                        CommandState = CommandStates.RegularRouting;
                        CurrentCommand = "";
                        continue;
                    }

                    KeyBuffer.Dequeue();
                    CommandState = CommandStates.RegularRouting;
                    CurrentCommand = "";
                    //Console.WriteLine(string.Format("Exiting Star Page Command, Invalid {0}; CurrentCommand: '{1}' (", b.ToString("X2"), CurrentCommand) + string.Format("{0}:{1}", remoteEndPoint.Address.ToString(), remoteEndPoint.Port) + ")");
                    continue;
                }
            }

            return false;
        }

        public string GetHistory()
        {
            return string.Join("<", PageHistory.Select(p => p.PageAndFrame));
        }

        internal void DebugLog(byte[] Buffer, int Received)
        {
            for (int i = 0; i < Received; i++)
                Console.WriteLine("Received: " + Buffer[i] + " (From: " + string.Format("{0}:{1}", remoteEndPoint.Address.ToString(), remoteEndPoint.Port) + ")");
        }
    }
}
