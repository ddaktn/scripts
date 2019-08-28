using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.ServiceProcess;

namespace RestartDockerServices
{
    class Program
    {
        static void Main(string[] args)
        {
            Console.WriteLine("\n\nRestarting the Docker and Hyper-V services\n\n");
            string[] services = { "winmgmt", "vmcompute", "com.docker.service", "vmms" };
            foreach(string service in services)
            {
                try
                {
                    RestartService(service);
                    Console.WriteLine("The {0} service was successfully restarted.\n\n", service);
                }
                catch(Exception e)
                {
                    Console.WriteLine("Something went wrong with the program... Make sure you are running as ADMINISTRATOR...");
                    Console.WriteLine("\n---StackTrace---\n{0}\n\n", e.StackTrace);
                }
            }
            Console.WriteLine("Press any key to exit...");
            Console.ReadKey();
            
        }
        static void RestartService(string serviceName)
        {
            try
            {
                ServiceController service = new ServiceController(serviceName);
                TimeSpan timeout = TimeSpan.FromMinutes(1);
                try
                {
                    Console.WriteLine("Stopping the {0} service...", serviceName);
                    //service.Stop();
                    System.Threading.Thread.Sleep(2500);
                    if (service.Status != ServiceControllerStatus.Stopped)
                    {
                        // Stop Service
                        service.Stop();
                        service.WaitForStatus(ServiceControllerStatus.Stopped, timeout);
                    }
                    //Restart service
                    Console.WriteLine("Starting the {0} service...", serviceName);
                    service.Start();
                    service.WaitForStatus(ServiceControllerStatus.Running, timeout);
                }
                catch(Exception ea)
                {
                    Console.WriteLine("Something went wrong! The {0} service could not be restarted!",serviceName);
                    Console.WriteLine("\n---StackTrace---\n{0}\n\n", ea.StackTrace);
                }
            }
            catch(Exception eb)
            {
                Console.WriteLine("Could not establish a connection to the {0} service. Validate your Docker client and it's dependencies are installed correctly...", serviceName);
                Console.WriteLine("\n---StackTrace---\n{0}\n\n", eb.StackTrace);
            }
        }
    }
}
