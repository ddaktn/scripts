/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package nelsonlab1a;

/**
 *
 * @author mss92473
 */

import java.util.*;

public class NelsonLab1A {

    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) {
        
        Scanner sc = new Scanner(System.in);
        System.out.println("\nDo you wish to: \n1 -- Read file\n2 -- Write file\n3 -- Append file");
        System.out.print("Please enter your selection: ");
        int choice = sc.nextInt();
        System.out.println("\nPlease enter the path for your IO operation: (remember to escape backslashes for windows paths)");
        String path = sc.next();        
        if(choice == 1) {        
//            System.out.println(TextFile.read("C:\\Temp\\test.txt"));
            System.out.println(TextFile.read(path));
        }
        else if(choice == 2) {        
//            TextFile.write("This is a test 2...","C:\\Temp\\test2.txt");
            System.out.println("Please enter the text you wish to write to the file: ");
            Scanner input = new Scanner(System.in);
            String text = input.nextLine();
            TextFile.write(text,path);
        }
        else if(choice == 3) {
//            TextFile.append("This is a test...","C:\\Temp\\test.txt");
            System.out.println("Please enter the text you wish to write to the file: ");
            Scanner input = new Scanner(System.in);
            String text = input.nextLine();
            TextFile.append(text,path);
        }
        else {
            System.out.println("\nNot a valid choice; exiting now...");
        }        
    }    
}
