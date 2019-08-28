
import java.util.Scanner;

public class LowerLimitAndUpperLimit {

    public static void main(String[] args) {
        Scanner reader = new Scanner(System.in);

        // write your code here
        System.out.print("First: ");
        int first = reader.nextInt();
        System.out.print("Last: ");
        int last = reader.nextInt();
        
        if(first < last) {
            for(int i = first; i <= last; i++) {
                System.out.println(i);
            }
        } else if(first == last) {
            System.out.println(first);
        }

    }
}
