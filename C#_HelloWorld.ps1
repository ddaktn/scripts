Add-Type -TypeDefinition @"
using System;
namespace Hello
{
    public class Program
    {
        public static void Main(string[] args)
        {
            Console.WriteLine("Hello " + args[0]);
        }
    }
}
"@

[Hello.Program]::Main("John")