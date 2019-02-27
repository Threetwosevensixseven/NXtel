using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace NXtelServer.Classes
{
    public class IACCommands
    {
        public const byte IAC  = 255; // Marks the start of a negotiation sequence
        public const byte WILL = 251; // Confirm willingness to negotiate
        public const byte WONT = 252; // Confirm unwillingness to negotiate
        public const byte DO   = 253; // Indicate willingness to negotiate
        public const byte DONT = 254; // Indicate unwillingness to negotiate
        public const byte NOP  = 241; // No operation
        public const byte SB   = 250; // The start of sub-negotiation options
        public const byte SE   = 240; // The end of sub-negotiation options
        public const byte IS   =   0; // Sub-negotiation IS command
        public const byte SEND =   1; // Sub-negotiation SEND command
    }
}
