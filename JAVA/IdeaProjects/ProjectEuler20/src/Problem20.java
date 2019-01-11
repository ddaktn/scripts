import java.math.BigInteger;
import java.util.Scanner;

public class Problem20 {

    public static void main(String[] args){
        // Factorial digit sum
        System.out.println("Enter number to factor: ");
        Scanner sc = new Scanner(System.in);
        Long count = sc.nextLong();
        BigInteger num = BigInteger.valueOf(count);
        BigInteger one = new BigInteger("1");
        BigInteger two = new BigInteger("2");
        BigInteger result = new BigInteger("1");
        int compare;
        for(Long i = 0L; i < count; i++) {
            compare = num.compareTo(one);
            if(compare > 0){
                result = result.multiply(num.multiply((num.subtract(one))));
                num = num.subtract(two);
            }
        }
        System.out.println("The result is: " + result);

        int finalResult = 0;
        String intStr = result.toString();
        int[] intArr = new int[intStr.length()];
        for(int j = 0; j < intStr.length(); j++){
            intArr[j] = Integer.parseInt(String.valueOf(intStr.charAt(j)));
        }
        for(int k = 0; k < intArr.length; k++){
            finalResult += intArr[k];
        }
        System.out.println("The final result is: " + finalResult);
    }
}
