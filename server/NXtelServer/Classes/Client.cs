using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Net;
using System.Net.Sockets;
using System.Security.Cryptography;
using System.Text;
using System.Threading;
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
        public IACStates IACState;
        private Random _random;
        private byte[] _latencyBytes;
        private int _latencyPacketCount;
        private DateTime _latencyStart;
        private Timer _queuedPageTimer;
        private List<Tuple<int, int>> _carouselPages;
        private Tuple<int, int> _carouselPage;
        private Carousel _carousel;
        public Socket Socket;
        public object CarouselLock = new object();
        public string ClientHash = "";
        public DateTime LastSeen;

        public Client(IPEndPoint _remoteEndPoint, DateTime _connectedAt, ClientStates _clientState)
        {
            this.remoteEndPoint = _remoteEndPoint;
            this.connectedAt = _connectedAt;
            this.clientState = _clientState;
            this.PageHistory = new Stack<Page>();
            this.KeyBuffer = new Queue<Byte>();
            this.CurrentCommand = "";
            this.CommandState = CommandStates.RegularRouting;
            this.IACState = IACStates.OutsideIAC;
            this._random = new Random();
            this._latencyBytes = new byte[100];
            this._random.NextBytes(this._latencyBytes);
            this._latencyPacketCount = 0;
            this._queuedPage = null;
            this._queuedPageTimer = null;
            this._carouselPages = new List<Tuple<int, int>>();
            this._carouselPages.Add(new Tuple<int, int>(91, 0));
            this._carouselPages.Add(new Tuple<int, int>(91, 1));
            this._carouselPages.Add(new Tuple<int, int>(150, 0));
            this._carouselPages.Add(new Tuple<int, int>(666, 0));
            this._carouselPages.Add(new Tuple<int, int>(999, 3));
            this._carousel = new Carousel(this);
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

        private Page _queuedPage = null;
        private object _queuedPageLock = new object();
        public void SetQueuedPage(Page value, Socket Socket)
        {
            lock (_queuedPageLock)
            {
                if (value != null)
                {
                    _queuedPageTimer = new Timer(QueuedPageCallback, Socket, Options.IACTimeoutMillisecs, Timeout.Infinite);
                }
                else
                {
                    _queuedPageTimer = null;
                }
                _queuedPage = value;
            }
        }

        public byte[] GetQueuedPageContents()
        {
            lock (_queuedPageLock)
            {
                if (_queuedPage == null)
                    return new byte[0];
                var rv = _queuedPage.Contents7BitEncoded ?? new byte[0];
                _queuedPage = null;
                return rv;
            }
        }

        private void QueuedPageCallback(object state)
        {
            lock (_queuedPageLock)
            {
                if (_queuedPage != null)
                {
                    var socket = state as Socket;
                    if (socket != null)
                    {
                        Console.WriteLine("Sending queued page (To: " + LogAddress + ")");
                        socket.BeginSend(_queuedPage.Contents7BitEncoded, 0, _queuedPage.Contents7BitEncoded.Length,
                            SocketFlags.None, new AsyncCallback(Program.SendData), socket);
                    }
                    _queuedPage = null;
                    _queuedPageTimer = null;
                }
            }
        }

        public void EnableCarousel(int WaitSeconds)
        {
            lock (CarouselLock)
            {
                _queuedPageTimer = new Timer(CarouselCallback, Socket, WaitSeconds * 1000, Timeout.Infinite);
            }
        }

        public void DisableCarousel()
        {
            lock (CarouselLock)
            {
                _queuedPageTimer = null;
            }
        }

        private void CarouselCallback(object state)
        {
            lock (CarouselLock)
            {
                if (_carousel == null || _carousel.Count == 0)
                    _queuedPageTimer = null;
                if (_carousel.Count == 0)
                    return;
                if (_carousel.NextIndex < 0 || _carousel.NextIndex > _carousel.Count - 1)
                    _carousel.NextIndex = 0;
                var page = _carousel[_carousel.NextIndex];
                _carousel.NextIndex++;
                if (_carousel.NextIndex < 0 || _carousel.NextIndex > _carousel.Count - 1)
                    _carousel.NextIndex = 0;
                var nextPage = _carousel[_carousel.NextIndex];
                Console.WriteLine("Sending carousel page " + page.PageAndFrame + " (To: " + string.Format("{0}", LogAddress) + ")");
                Socket.BeginSend(page.Contents7BitEncoded, 0, page.Contents7BitEncoded.Length,
                    SocketFlags.None, new AsyncCallback(Program.SendData), Socket);
                _queuedPageTimer = new Timer(CarouselCallback, state, nextPage.CarouselWait * 1000, Timeout.Infinite);
            }
        }

        public bool ProcessInput(byte[] Chars, int Received, out Page NextPage, out byte[] SendIAC)
        {
            var sendIAC = new List<byte>();

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

                if (b == IACCommands.IAC && IACState == IACStates.OutsideIAC)
                {
                    if (Options.IACEnabled)
                        IACState = IACStates.InsideIAC;
                    KeyBuffer.Dequeue();
                    continue;
                }

                if (b == IACCommands.IAC && IACState == IACStates.InsideIAC)
                {
                    Debugger.Break(); // This is an escaped 255
                    KeyBuffer.Dequeue();
                    continue;
                }

                if (b == IACCommands.DO && IACState == IACStates.InsideIAC)
                {
                    IACState = IACStates.Doing;
                    KeyBuffer.Dequeue();
                    continue;
                }

                if (IACState == IACStates.Doing)
                {
                    if (b == IACOptions.CUSTOM_LATENCY)
                    {
                        sendIAC.AddRange(_latencyBytes);
                        KeyBuffer.Dequeue();
                        IACState = IACStates.OutsideIAC;
                        if (_latencyPacketCount == 0)
                        {
                            _latencyStart = DateTime.Now;
                            _latencyPacketCount++;
                            Console.WriteLine("Starting LAT test. One LAT is 10 bytes->server + 100 bytes->client (To: " 
                                + string.Format("{0}", LogAddress) + ")");
                        }
                        else
                        {
                            double tot = (DateTime.Now - _latencyStart).TotalMilliseconds;
                            double avg = Math.Round(tot / _latencyPacketCount, 0);
                            Console.WriteLine(_latencyPacketCount + " LATs in " + tot.ToString()
                                + "ms = avg " + avg.ToString() + "ms (To: " + string.Format("{0}", LogAddress) + ")");
                            _latencyPacketCount++;
                        }
                        continue;
                    }
                    if (b == IACOptions.SUPPRESS_GOAHEAD)
                    {
                        sendIAC.Add(IACCommands.IAC);
                        sendIAC.Add(IACCommands.WILL);
                        sendIAC.Add(IACOptions.SUPPRESS_GOAHEAD);
                        KeyBuffer.Dequeue();
                        IACState = IACStates.OutsideIAC;
                    }
                    else if (b == IACOptions.NEW_ENVIRON)
                    {
                        sendIAC.Add(IACCommands.IAC);
                        sendIAC.Add(IACCommands.WILL);
                        sendIAC.Add(IACOptions.NEW_ENVIRON);
                        KeyBuffer.Dequeue();
                        IACState = IACStates.OutsideIAC;
                    }
                    else
                    {
                        // If it's not an option we support, we send IAC WONT <OPTION> 
                        sendIAC.Add(IACCommands.IAC);
                        sendIAC.Add(IACCommands.WONT);
                        sendIAC.Add(IACOptions.NEW_ENVIRON);
                        KeyBuffer.Dequeue();
                        IACState = IACStates.OutsideIAC;
                    }
                    continue;
                }

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
                        //Console.WriteLine(string.Format("Inside Star Page Command, Adding {0}; CurrentCommand: '{1}' (", 
                        //    b.ToString("X2"), CurrentCommand) + string.Format("{0}", LogAddress) + ")");
                        continue;
                    }
                    if (b == ENTER)
                    {
                        //Console.WriteLine(string.Format("Exiting Star Page Command; CurrentCommand: '{0}' (", CurrentCommand) 
                        //    + string.Format("{0}", LogAddress) + ")");
                        KeyBuffer.Dequeue();
                        if (CurrentCommand == "00") // Previous page
                        {
                            CommandState = CommandStates.RegularRouting;
                            CurrentCommand = "";
                            if (PageHistory.Count > 1)
                                PageHistory.Pop();
                            NextPage = PageHistory.Peek();
                            Debug.Assert(PageHistory.Count > 0);
                            SendIAC = sendIAC.ToArray();
                            return true;
                        }
                        else
                        {
                            int pageNo;
                            int.TryParse(CurrentCommand, out pageNo);
                            NextPage = Page.Load(pageNo, 0, _carousel, LastSeen);
                            if (NextPage.PageNo != pageNo)
                                NextPage = Page.Load(1, 0, _carousel, LastSeen);
                            PageHistory.Push(NextPage);
                            CommandState = CommandStates.RegularRouting;
                            CurrentCommand = "";
                            SendIAC = sendIAC.ToArray();
                            return true;
                        }
                    }
                    KeyBuffer.Dequeue();
                    CommandState = CommandStates.RegularRouting;
                    CurrentCommand = "";
                    //Console.WriteLine(string.Format("Exiting Star Page Command, Invalid {0}; CurrentCommand: '{1}' (", 
                    //    b.ToString("X2"), CurrentCommand) + string.Format("{0}", LogAddress) + ")");
                    continue;
                }

                if (CommandState == CommandStates.RegularRouting)
                {
                    if (b == '*')
                    {
                        //Console.WriteLine(string.Format("Entering Star Page Command; CurrentCommand: '{0}' (", CurrentCommand) 
                        //    + string.Format("{0}", LogAddress) + ")");
                        CommandState = CommandStates.InsideStarPageCommand;
                        KeyBuffer.Dequeue();
                        continue;
                    }
                    //Console.WriteLine(string.Format("Outside Commands, Processing {0} (", b.ToString("X2")) 
                    //    + string.Format("{0}", LogAddress) + ")");
                    var route = CurrentPage.Routing.FirstOrDefault(r => r.KeyCode == b);
                    if (route != null)
                    {
                        if (CurrentPage.PageType == PageTypes.TeleSoftware && route.NextPageNo != null && route.NextFrameNo != null)
                        {
                            NextPage = Page.Load((int)route.NextPageNo, (int)route.NextFrameNo, _carousel, LastSeen);
                            PageHistory.Push(NextPage);
                            KeyBuffer.Dequeue();
                            SendIAC = sendIAC.ToArray();
                            return true;
                        }
                        else if (route.GoesToPageNo >= 0 && route.GoesToFrameNo >= 0 && route.GoesToFrameNo <= 25)
                        {
                            NextPage = Page.Load(route.GoesToPageNo, route.GoesToFrameNo, _carousel, LastSeen);
                            PageHistory.Push(NextPage);
                            KeyBuffer.Dequeue();
                            SendIAC = sendIAC.ToArray();
                            return true;
                        }
                        KeyBuffer.Dequeue();
                        SendIAC = sendIAC.ToArray();
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
                                    NextPage = Page.Load(route.GoesToPageNo, route.GoesToFrameNo, _carousel, LastSeen);
                                    PageHistory.Push(NextPage);
                                    CommandState = CommandStates.RegularRouting;
                                    CurrentCommand = "";
                                    SendIAC = sendIAC.ToArray();
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
                    //Console.WriteLine(string.Format("Exiting Star Page Command, Invalid {0}; CurrentCommand: '{1}' (", 
                    //    b.ToString("X2"), CurrentCommand) + string.Format("{0}", LogAddress) + ")");
                    continue;
                }
            }

            SendIAC = sendIAC.ToArray();
            return false;
        }

        public string GetHistory()
        {
            return string.Join("<", PageHistory.Select(p => p.PageAndFrame));
        }

        internal void DebugLog(byte[] Buffer, int Received)
        {
            for (int i = 0; i < Received; i++)
                Console.WriteLine("Received: " + Buffer[i].ToString("X2") + " [" + Buffer[i].ToString().PadLeft(3)
                    + (Buffer[i] > 32 ? " " + Convert.ToChar(Buffer[i]).ToString() : "  ")
                    + "] (From: " + string.Format("{0}", LogAddress) + ")");
        }

        internal byte[] Combine(params byte[][] BytesList)
        {
            var list = new List<byte>();
            foreach (var bytes in BytesList)
                if (bytes != null && bytes.Length > 0)
                    list.AddRange(bytes);
            return list.ToArray();
        }

        public string LogAddress
        {
            get
            {
                return (ClientHash ?? "").Trim() + ":" + remoteEndPoint.Port.ToString();
            }
        }
    }
}
