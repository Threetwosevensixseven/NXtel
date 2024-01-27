using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Sockets;
using System.Reflection;
using System.Text;
using System.Threading;
using NXtelData;
using NXtelServer.Classes;

namespace NXtelServer
{
    class Program
    {
        private static Socket serverSocket;
        private static byte[] data = new byte[dataSize];
        private static bool newClients = true;
        private const int dataSize = 1024;
        private static Dictionary<Socket, Client> clientList = new Dictionary<Socket, Client>();
        private static string Version;
        //private static bool IACEnabled = false;

        static void Main(string[] args)
        {
            using (var logger = new ConsoleLogger(Options.LogFile))
            {
                try
                {
                    var settings = new Settings(AppDomain.CurrentDomain.BaseDirectory).Load();
                    DBOps.ConnectionString = settings.ConnectionString;
                    Version = Assembly.GetEntryAssembly().GetName().Version.ToString();
                    Console.WriteLine("Starting NXtel Server v" + Version);
                    var x = DBOps.ConnectionString;
                    var now = DateTime.Now;
                    Console.WriteLine(now.ToShortDateString() + " " + now.ToLongTimeString());
                    Console.WriteLine("Database: " + settings.DatabaseName);
                    Console.WriteLine("Using " + Options.CharSetName + " character set");
                    Console.WriteLine((Options.TrimSpaces ? "T" : "Not t") + "rimming spaces");
                    Console.WriteLine("IAC " + (Options.IACEnabled ? "en" : "dis") + "abled");
                    new Thread(new ThreadStart(backgroundThread)) { IsBackground = false }.Start();
                    serverSocket = new Socket(AddressFamily.InterNetwork, SocketType.Stream, ProtocolType.Tcp);
                    IPEndPoint endPoint = new IPEndPoint(IPAddress.Any, Options.TCPListeningPort); //2380
                    serverSocket.Bind(endPoint);
                    serverSocket.Listen(0);
                    serverSocket.BeginAccept(new AsyncCallback(AcceptConnection), serverSocket);
                    Console.WriteLine("Listening for connections on port " + endPoint.Port + "...");
                }
                catch (Exception ex)
                {
                    Console.WriteLine(ex.Message);
                    Console.WriteLine(ex.StackTrace);
                }
                while (true)
                {
                    Thread.Sleep(10);
                }
            }
        }

        private static void AcceptConnection(IAsyncResult result)
        {
            if (!newClients) return;        
            Socket oldSocket = (Socket)result.AsyncState;
            Socket newSocket = oldSocket.EndAccept(result);
            Client client = new Client((IPEndPoint)newSocket.RemoteEndPoint, DateTime.Now, ClientStates.NotLogged);
            client.ClientHash = Stats.Connect((IPEndPoint)newSocket.RemoteEndPoint, out client.LastSeen);
            client.Socket = newSocket;
            clientList.Add(newSocket, client);
            Console.WriteLine("Client connected. (From: " + client.LogAddress + ")");
            var page = Page.Load(Options.StartPageNo, Options.StartFrameNo, null, client.LastSeen);
            client.PageHistory.Push(page);
            client.clientState = ClientStates.Logging;
            client.ShowingNotices = true;
            try
            {
                if (Options.IACEnabled)
                {
                    Console.WriteLine(string.Format("Queuing page {0} for sending (To: {1}", Options.StartPage,
                        client.LogAddress) + ")");
                    Stats.Update(client.remoteEndPoint, page);
                    client.SetQueuedPage(page, newSocket);
                    //newSocket.Listen(100);
                    newSocket.BeginReceive(data, 0, dataSize, SocketFlags.None, new AsyncCallback(ReceiveData), newSocket);
                    serverSocket.BeginAccept(new AsyncCallback(AcceptConnection), serverSocket);
                }
                else
                {
                        Console.WriteLine(string.Format("Sending page {0} (To: {1}", Options.StartPage, 
                            client.LogAddress) + ")");
                    Stats.Update(client.remoteEndPoint, page);
                    //string log = RawLog(page.Contents7BitEncoded, 0, page.Contents7BitEncoded.Length);
                    newSocket.BeginSend(page.Contents7BitEncoded, 0, page.Contents7BitEncoded.Length,
                        SocketFlags.None, new AsyncCallback(SendData), newSocket);
                    serverSocket.BeginAccept(new AsyncCallback(AcceptConnection), serverSocket);
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.Message);
                Console.WriteLine(ex.StackTrace);
            }
        }

        public static void SendData(IAsyncResult result)
        {
            try
            {
                Socket clientSocket = (Socket)result.AsyncState;
                clientSocket.EndSend(result);
                clientSocket.BeginReceive(data, 0, dataSize, SocketFlags.None, new AsyncCallback(ReceiveData), clientSocket);
            }
            catch { }
        }

        private static void ReceiveData(IAsyncResult result)
        {
            Client client;
            Page nextPage;
            try
            {
                Socket clientSocket = (Socket)result.AsyncState;
                clientList.TryGetValue(clientSocket, out client);
                int received = clientSocket.EndReceive(result);
                if (received == 0)
                {
                    clientSocket.Close();
                    clientList.Remove(clientSocket);
                    serverSocket.BeginAccept(new AsyncCallback(AcceptConnection), serverSocket);
                    Console.WriteLine("Client disconnected. (From: " + string.Format("{0}", client.LogAddress) + ")");
                    return;
                }
                byte[] sendIAC = null;
                byte[] pageData = null;
                bool log = Options.EnableInputParserLogging;
                if (log) client.DebugLog(data, received);
                bool processed = client.ProcessInput(data, received, out nextPage, out sendIAC);
                if (sendIAC.Length > 0)
                {
                    if (log) Console.WriteLine("Sending IAC " + BitConverter.ToString(sendIAC) + " (To: " 
                        + string.Format("{0}", client.LogAddress) + ")");
                    //clientSocket.BeginSend(sendIAC, 0, sendIAC.Length, SocketFlags.None, new AsyncCallback(SendData), 
                    //    clientSocket);
                }
                var queued = client.GetQueuedPageContents();
                queued = new byte[0];
                if (queued.Length > 0)
                {
                    Console.WriteLine("Sending queued page (To: " + string.Format("{0}", client.LogAddress) + ")");
                }
                if (processed)
                {
                    Console.WriteLine("Sending page " + nextPage.PageAndFrame + " (To: " 
                        + string.Format("{0}", client.LogAddress) + ")");
                    Stats.Update(client.remoteEndPoint, nextPage);
                    pageData = nextPage.Contents7BitEncoded;
                }
                var sendData = client.Combine(sendIAC, queued, pageData);
                if (sendData.Length > 0)
                {
                    //string log2 = RawLog(sendData, 0, sendData.Length);
                    clientSocket.BeginSend(sendData, 0, sendData.Length, SocketFlags.None, 
                        new AsyncCallback(SendData), clientSocket);
                }
                clientSocket.BeginReceive(data, 0, dataSize, SocketFlags.None, new AsyncCallback(ReceiveData), clientSocket);
            }
            catch (Exception ex) when (ex is SocketException || ex is ObjectDisposedException)
            {
                try
                {
                    Socket clientSocket = (Socket)result.AsyncState;
                    clientSocket.BeginReceive(data, 0, dataSize, SocketFlags.None, new AsyncCallback(ReceiveData), clientSocket);
                }
                catch { }
            }
            catch (Exception ex)
            {
                Console.WriteLine();
                Console.WriteLine(ex.Message);
                Console.WriteLine(ex.StackTrace);
                Console.WriteLine();
                Console.WriteLine("Retrying...");
                try
                {
                    Socket clientSocket = (Socket)result.AsyncState;
                    clientSocket.BeginReceive(data, 0, dataSize, SocketFlags.None, new AsyncCallback(ReceiveData), clientSocket);
                }
                catch
                {
                    if (ex is ObjectDisposedException)
                        Console.WriteLine("Nope, retry didn't work!");
                }
            }
        }

        private static void backgroundThread()
        {
            while (true)
            {
                string Input = Console.ReadLine();

                if (Input == "clients")
                {
                    if (clientList.Count == 0) continue;
                    int clientNumber = 0;
                    foreach (KeyValuePair<Socket, Client> client in clientList)
                    {
                        Client currentClient = client.Value;
                        clientNumber++;
                        Console.WriteLine(string.Format("Client #{0} (From: {1}, ECurrentState: {2}, Connection time: {3})", 
                            clientNumber, currentClient.LogAddress, currentClient.clientState, currentClient.connectedAt));
                    }
                }

                if (Input.StartsWith("kill"))
                {
                    string[] _Input = Input.Split(' ');
                    int clientID = 0;
                    try
                    {
                        if (Int32.TryParse(_Input[1], out clientID) && clientID >= clientList.Keys.Count)
                        {
                            int currentClient = 0;
                            foreach (Socket currentSocket in clientList.Keys.ToArray())
                            {
                                currentClient++;
                                if (currentClient == clientID)
                                {
                                    currentSocket.Shutdown(SocketShutdown.Both);
                                    currentSocket.Close();
                                    clientList.Remove(currentSocket);
                                    Console.WriteLine("Client has been disconnected and cleared up.");
                                }
                            }
                        }
                        else { Console.WriteLine("Could not kick client: invalid client number specified."); }
                    }
                    catch { Console.WriteLine("Could not kick client: invalid client number specified."); }
                }

                if (Input == "killall")
                {
                    int deletedClients = 0;
                    foreach (Socket currentSocket in clientList.Keys.ToArray())
                    {
                        currentSocket.Shutdown(SocketShutdown.Both);
                        currentSocket.Close();
                        clientList.Remove(currentSocket);
                        deletedClients++;
                    }

                    Console.WriteLine("{0} clients have been disconnected and cleared up.", deletedClients);
                }

                if (Input == "lock") { newClients = false; Console.WriteLine("Refusing new connections."); }
                if (Input == "unlock") { newClients = true; Console.WriteLine("Accepting new connections."); }
            }
        }

        private static string RawLog(byte[] buffer, int offset, int size)
        {
            if (buffer == null || size == 0 || (offset + size) > buffer.Length)
                return "";
            int count = 0;
            string join = "";
            var sb = new StringBuilder();
            for (int i = offset; i < offset + size; i++)
            {
                sb.Append(join);
                sb.Append(buffer[i].ToString("X2"));
                join = " ";
                count++;
                if (count >= 16)
                {
                    join = "";
                    count = 0;
                    sb.Append("\r\n");
                }
            }
            return sb.ToString();
        }
    }
}
