import java.math.BigInteger;
import java.util.Arrays;

public class Problem25 {

    public static void main(String[] args){
        fibonacciSequence();
    }

    public static void fibonacciSequence() {

        //1000-digit Fibonacci number
        var bigIntArr = new BigInteger[12];
        bigIntArr[0] = BigInteger.ONE;
        bigIntArr[1] = BigInteger.ONE;

        for(var i = 2; i < bigIntArr.length; i++){
            bigIntArr = Arrays.copyOf(bigIntArr, bigIntArr.length + 1);
            bigIntArr[i] = bigIntArr[i - 1].add(bigIntArr[i - 2]);
            System.out.println(bigIntArr[i]);
            System.out.println(i);
            var length = String.valueOf(bigIntArr[i]).length();
            if(length >= 1000) {
                var answer = i + 1; //index starts from zero
                System.out.printf("The answer is: %d", answer); 
                break;
            }
        }
    }
}
