import java.util.Arrays;

public class Problem25 {

    public static void main(String[] args){
        //1000-digit Fibonacci number
        int[] intArr = new int[12];
        intArr[0] = 1;
        intArr[1] = 1;
        System.out.println(intArr[0]);
        System.out.println(intArr[1]);
        for(int i = 2; i < intArr.length; i++){
            intArr = Arrays.copyOf(intArr, intArr.length + 1);
            intArr[i] = intArr[i - 1] + intArr[i -2];
            System.out.println(intArr[i]);
            int length = String.valueOf(intArr[i]).length();
            if(length / 1000 == 1) {
                break;
            }
        }
    }
}
