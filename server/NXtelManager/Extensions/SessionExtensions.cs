using System;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Caching.Memory;

namespace NXtelManager
{
    // ASP.NET kept session values in server memory as objects. These keep them the same way, per session,
    // with the same 20 minute sliding timeout.
    public static class SessionExtensions
    {
        private static readonly MemoryCache objects = new MemoryCache(new MemoryCacheOptions());

        public static object GetObject(this ISession Session, string Key)
        {
            return objects.Get(Session.Id + ":" + Key);
        }

        public static void SetObject(this ISession Session, string Key, object Value)
        {
            // Storing a value starts the session and sends its cookie.
            Session.SetString(Key, "");
            if (Value == null)
                objects.Remove(Session.Id + ":" + Key);
            else
                objects.Set(Session.Id + ":" + Key, Value, new MemoryCacheEntryOptions { SlidingExpiration = TimeSpan.FromMinutes(20) });
        }
    }
}
