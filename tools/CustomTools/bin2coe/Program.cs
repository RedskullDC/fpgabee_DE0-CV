using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;

namespace bin2coe
{
	class Program
	{
		static int Main(string[] args)
		{
			Console.WriteLine("bin2coe v1.0");
			Console.WriteLine("Copyright (c) 2012 Topten Software.");
			Console.WriteLine("All Rights Reserved");
			Console.WriteLine();

			if (args.Length != 3)
			{
				Console.WriteLine("Usage: bin2coe <file.bin> <file.coe> <memory depth>");
				Console.WriteLine();
				Console.WriteLine("  - memory depth must be 8");
				return 7;
			}

			try
			{

				if (args[2] != "8")
					throw new InvalidOperationException("Memory depth must be 8");

				var src = new FileStream(args[0], FileMode.Open);
				var dest = new StreamWriter(args[1]);
				dest.WriteLine("memory_initialization_radix=16;");
				dest.WriteLine("memory_initialization_vector=");
				var buf = new byte[1024];
				int pos = 0;
				while (true)
				{
					int length = src.Read(buf, 0, buf.Length);
					if (length == 0)
						break;

					for (int i = 0; i < length; i++, pos++)
					{
						dest.Write("{0,2:X2}{1}", buf[i], i%16==15 ? "\n" : ", ");
					}
				}

				src.Close();
				dest.Close();


				Console.WriteLine("Converted {0} bytes", pos);
				return 0;

			}
			catch (Exception e)
			{
				Console.WriteLine("Error: {0}", e.Message);
				return 7;
			}

		}
	}
}
