using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace NXtelData.Extensions
{
    public static class ArrayExtensions
    {
        public static IEnumerable<ArraySegment<T>> AsChunks<T>(this T[] source, int chunkMaxSize)
        {
            var chunks = source.Length / chunkMaxSize;
            var leftOver = source.Length % chunkMaxSize;
            var result = new List<ArraySegment<T>>(chunks + 1);
            var offset = 0;
            for (var i = 0; i < chunks; i++)
            {
                result.Add(new ArraySegment<T>(source, offset, chunkMaxSize));
                offset += chunkMaxSize;
            }
            if (leftOver > 0)
                result.Add(new ArraySegment<T>(source, offset, leftOver));
            return result;
        }
    }
}
