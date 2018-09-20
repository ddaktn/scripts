/**
 *  Doug Nelson
 *  9/20/2018
 */

import java.util.Scanner;

public class PlayCode {
    public static void main(String[] args) {
        Scanner input = new Scanner(System.in);
        String message = "\nHow are you feeling today?\n0 -- I feel GREAT!!!\n1 -- I don't feel so hot!";
        String endPrompt = "Are we done here? Y/N: ";
        System.out.println(message);
        while (true) {
            System.out.print("Please enter choice: ");
            String choice = input.next();
            if(choice.equals("0")) {
                System.out.println("\n\"From the moment we are born, we begin to die.\" -- Janne Teller\n");
                System.out.print(endPrompt);
                String end = input.next();
                if(end.equals("Y") || end.equals("y")) {
                    break;
                } else {
                    System.out.println(message);
                }
            }
            else if(choice.equals("1")) {
                System.out.println("\n\"Every moment is a fresh beginning.\" -- T.S. Eliot\n");
                System.out.print(endPrompt);
                String end = input.next();
                if(end.equals("Y") || end.equals("y")) {
                    break;
                } else {
                    System.out.println(message);
                }
            }
            else {
                System.out.println("\nPlease pick a \"0\" or \"1\"...");
                System.out.println(message);
            }
        }
    }
}
