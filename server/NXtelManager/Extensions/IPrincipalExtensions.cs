using System;
using System.Collections.Generic;
using System.Linq;
using Microsoft.AspNet.Identity;

namespace System.Security.Principal
{
    public static class IPrincipalExtensions
    {
        public static string GetUserID(this IPrincipal User)
        {
            if (User == null || User.Identity == null || (!(User.Identity is Claims.ClaimsIdentity)))
                return null;
            return (User.Identity as Claims.ClaimsIdentity).GetUserID();
        }
    }
}