using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace NXtelServer.Classes
{
    public class IACOptions
    {
        public const byte SUPPRESS_GOAHEAD =   3; // Suppress GoAhead
        public const byte NEW_ENVIRON      =  39; // Environment variables
        public const byte CUSTOM_LATENCY   = 142; // Send latency testing packet

    }
}