public class Problem14 {

    public static void main(String[] args) {

        //Longest Collatz sequence
        int num = 13;
        int[] numArray = new int[999986];
        numArray[0] = 13;
        int[] numIndex = new int[999986];
        numIndex[0] = 10;
        for(int i = 1; i <= numArray.length; i++) {
            numArray[i] += 1;
            int chainCount = 1;
            while (num > 1) {
                if (num % 2 == 0 && num / 2 > 0) {
                    num /= 2;
                    chainCount++;
                    System.out.println(num);
                    if (num == 1) {
                        numIndex[i] = chainCount;
                        break;
                    }
                } else {
                    num = num * 3 + 1;
                    chainCount++;
                    System.out.println(num);
                    if (num == 1) {
                        numIndex[i] = chainCount;
                        break;
                    }
                }
            }
        }
        for(int i = 0; i < numArray.length; i++) {
            System.out.println("The number index is: " + numIndex[i]);
            System.out.println("The number value is: " + numArray[i]);
        }
    }
}
