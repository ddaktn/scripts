
import java.util.Scanner;

public class LeapYear {

    public static void main(String[] args) {
        Scanner reader = new Scanner(System.in);
        System.out.print("Type a year: ");
        int year = Integer.parseInt(reader.nextLine());
        
        String leapMessage = "The year is a leap year.";
        String notLeapMessage = "The year is not a leap year.";
        
        
        if (year % 4 == 0 && year % 100 != 0) {
            System.out.println(leapMessage);
        } else if (year % 400 == 0) {
            System.out.println(leapMessage);
        } else {
            System.out.println(notLeapMessage);
        }
    }
}
