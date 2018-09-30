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
                foreach (char c in GetText())
                {
                    Thread.Sleep(5);
                    if (clientList.Count == 0)
                        continue;
                    var send = new byte[] { Convert.ToByte(c) };
                    var client = clientList.FirstOrDefault();
                        client.Key.BeginSend(send, 0, send.Length,
                        SocketFlags.None, new AsyncCallback(SendData), client.Key);
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
            var send = new byte[] { Convert.ToByte('A') };
            newSocket.BeginSend(send, 0, send.Length, SocketFlags.None, new AsyncCallback(SendData), newSocket);
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
            sb.Append("It is an important and popular fact that things are not always ");
            sb.Append("what they seem. For instance, on the planet Earth, man had always ");
            sb.Append("assumed that he was more intelligent than dolphins because he had ");
            sb.Append("achieved so much - the wheel, New York, wars and so on - whilst ");
            sb.Append("all the dolphins had ever done was muck about in the water having ");
            sb.Append("a good time. But conversely, the dolphins had always believed ");
            sb.Append("that they were far more intelligent than man - for precisely the ");
            sb.Append("same reasons.");
            sb.Append("\r\r");
            sb.Append("Curiously enough, the dolphins had long known of the impending ");
            sb.Append("destruction of  the planet Earth and had made many attempts to ");
            sb.Append("alert mankind of the danger; but most of their communications ");
            sb.Append("were misinterpreted as amusing attempts to punch footballs or ");
            sb.Append("whistle for tidbits, so they eventually gave up and left the ");
            sb.Append("Earth by their own means shortly before the Vogons arrived.");
            sb.Append("\r\r");
            sb.Append("The last ever dolphin  message was misinterpreted as a ");
            sb.Append("surprisingly sophisticated attempt to do a double-backwards-");
            sb.Append("somersault through a hoop whilst whistling the \"Star Sprangled ");
            sb.Append("Banner\", but in fact the message was this: So long and thanks for ");
            sb.Append("all the fish.");
            sb.Append("\r\r");
            sb.Append("In fact there was only one species on the planet more intelligent ");
            sb.Append("than  dolphins, and they spent a lot of their time in behavioural ");
            sb.Append("research laboratories running round inside wheels and conducting" );
            sb.Append("frighteningly elegant and subtle experiments on man.");
            sb.Append("\r\r");
            sb.Append("The fact that once again man completely misinterpreted this ");
            sb.Append("relationship was entirely according to these creatures' plans.");
            return sb.ToString();
        }
    }
}
