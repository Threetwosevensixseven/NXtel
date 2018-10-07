using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Sockets;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using ESPATTest.Classes;

namespace ESPATTest
{
    class Program
    {
        private static Socket serverSocket;
        private static byte[] data = new byte[dataSize];
        private static bool newClients = true;
        private const int dataSize = 1024;
        private static Dictionary<Socket, Client> clientList = new Dictionary<Socket, Client>();

        static void Main(string[] args)
        {
            Console.WriteLine("Starting ESPATTest");
            new Thread(new ThreadStart(backgroundThread)) { IsBackground = false }.Start();
            serverSocket = new Socket(AddressFamily.InterNetwork, SocketType.Stream, ProtocolType.Tcp);
            IPEndPoint endPoint = new IPEndPoint(IPAddress.Any, 10000);
            serverSocket.Bind(endPoint);
            serverSocket.Listen(0);
            serverSocket.BeginAccept(new AsyncCallback(AcceptConnection), serverSocket);
            Console.WriteLine("Listening for connections on port " + endPoint.Port + "...");
        }

        private static void backgroundThread()
        {
            while (true)
            {
                //int count = 0;
                foreach (char c in GetText())
                {
                    //if (count >= 200)
                    //{
                    //    Thread.Sleep(100);
                    //    count = 0;
                    //}
                    Thread.Sleep(5);
                    if (clientList.Count == 0)
                        continue;
                    var send = new byte[] { Convert.ToByte(c) };
                    var client = clientList.FirstOrDefault();
                        client.Key.BeginSend(send, 0, send.Length,
                        SocketFlags.None, new AsyncCallback(SendData), client.Key);
                    //count++;
                }
                //if (Console.KeyAvailable)
                //{
                //    var key = Console.ReadKey(true);
                //    //Console.Write(key.KeyChar);
                //    var send = new byte[] { Convert.ToByte(key.KeyChar) };
                //    foreach (KeyValuePair<Socket, Client> client in clientList)
                //    {
                //        client.Key.BeginSend(send, 0, send.Length,
                //            SocketFlags.None, new AsyncCallback(SendData), client.Key);
                //    }
                //}
            }
        }

        private static void AcceptConnection(IAsyncResult result)
        {
            if (!newClients) return;
            Socket oldSocket = (Socket)result.AsyncState;
            Socket newSocket = oldSocket.EndAccept(result);
            Client client = new Client((IPEndPoint)newSocket.RemoteEndPoint, DateTime.Now);
            clientList.Add(newSocket, client);
            Console.WriteLine("Client connected. (From: " + string.Format("{0}:{1}", client.remoteEndPoint.Address.ToString(), client.remoteEndPoint.Port) + ")");
            //string output = "-- NXTEL TEST SERVER (" + serverSocket.SocketType + ") --\n\r\n\r";
            //output += "Please input your password:\n\r";
            //Console.WriteLine("Sending page 0a (To: " + string.Format("{0}:{1}", client.remoteEndPoint.Address.ToString(), client.remoteEndPoint.Port) + ")");
            //Console.WriteLine(string.Format("History: {0}", client.GetHistory()));
            newSocket.BeginReceive(data, 0, dataSize, SocketFlags.None, new AsyncCallback(ReceiveData), newSocket);
            serverSocket.BeginAccept(new AsyncCallback(AcceptConnection), serverSocket);
        }

        private static void SendData(IAsyncResult result)
        {
            try
            {
                Socket clientSocket = (Socket)result.AsyncState;
                clientSocket.EndSend(result);
                //clientSocket.BeginReceive(data, 0, dataSize, SocketFlags.None, new AsyncCallback(ReceiveData), clientSocket);
            }
            catch { }
        }

        private static void ReceiveData(IAsyncResult result)
        {
            Client client;
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
                    Console.WriteLine("Client disconnected. (From: " + string.Format("{0}:{1}", client.remoteEndPoint.Address.ToString(), client.remoteEndPoint.Port) + ")");
                    return;
                }

                //Console.WriteLine("Received '{0}' (From: {1}:{2})", BitConverter.ToString(data, 0, received), client.remoteEndPoint.Address.ToString(), client.remoteEndPoint.Port);

                var x = data;
                var y = received;

                for (int i = 0; i < received; i++)
                {
                    Console.Write(Convert.ToChar(x[i]));
                }

                clientSocket.BeginReceive(data, 0, dataSize, SocketFlags.None, new AsyncCallback(ReceiveData), clientSocket);
            }
            catch (SocketException) { }
            catch (Exception ex)
            {
                var x = ex.GetType();
            }
        }

        private static string GetText()
        {
            var sb = new StringBuilder();
            sb.Append("\r\r");
            sb.Append("It is an important and popular\rfact that things are not always\r");
            sb.Append("what they seem. For instance, on\rthe planet Earth, man had always\r");
            sb.Append("assumed that he was more\rintelligent than dolphins\rbecause he had");
            sb.Append("achieved so much -\rthe wheel, New York, wars and so\ron - whilst ");
            sb.Append("all the dolphins had\rever done was muck about in the\rwater having ");
            sb.Append("a good time. But\rconversely, the dolphins had\ralways believed ");
            sb.Append("that they were\rfar more intelligent than man -\rfor precisely the ");
            sb.Append("same reasons.");
            sb.Append("\r\r");
            sb.Append("Curiously enough, the dolphins\rhad long known of the impending\r");
            sb.Append("destruction of the planet Earth\rand had made many attempts to\r");
            sb.Append("alert mankind of the danger;\rbut most of their communications\r");
            sb.Append("were misinterpreted as amusing\rattempts to punch footballs or\r");
            sb.Append("whistle for tidbits, so they\reventually gave up and left the\r");
            sb.Append("Earth by their own means shortly\rbefore the Vogons arrived.");
            sb.Append("\r\r");
            sb.Append("The last ever dolphin message\rwas misinterpreted as a\r");
            sb.Append("surprisingly sophisticated\rattempt to do a double-\rbackwards-");
            sb.Append("somersault through a\rhoop whilst whistling the \"Star\rSpangled ");
            sb.Append("Banner\", but in fact\rthe message was this: So long\rand thanks for ");
            sb.Append("all the fish.");
            sb.Append("\r\r");
            sb.Append("In fact there was only one\rspecies on the planet more\rintelligent ");
            sb.Append("than dolphins, and\rthey spent a lot of their time\rin behavioural ");
            sb.Append("research\rlaboratories running round\rinside wheels and conducting\r" );
            sb.Append("frighteningly elegant and subtle\rexperiments on man.");
            sb.Append("\r\r");
            sb.Append("The fact that once again man\rcompletely misinterpreted this\r");
            sb.Append("relationship was entirely\raccording to these creatures'\rplans.");
            return sb.ToString();
        }

        private static string SplitLines(StringBuilder SB, int maxStringLength)
        {
            string text = SB.ToString();
            char[] splitOnCharacters = new char[] { ' ', '-', '\r' };
            var sb = new StringBuilder();
            var index = 0;
            while (text.Length > index)
            {
                if (index != 0)
                    sb.Append('\r');
                var splitAt = index + maxStringLength <= text.Length
                    ? text.Substring(index, maxStringLength).LastIndexOfAny(splitOnCharacters)
                    : text.Length - index;
                if (splitAt != -1 && splitAt < (text.Length - 1) && text[splitAt] == '-')
                    splitAt++;
                splitAt = (splitAt == -1) ? maxStringLength : splitAt;
                sb.Append(text.Substring(index, splitAt).Trim());
                index += splitAt;
            }
            return sb.ToString();
        }

    }
}
