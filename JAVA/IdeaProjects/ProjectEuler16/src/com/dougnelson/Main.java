package com.dougnelson;

import java.math.BigInteger;

public class Main {

    public static void main(String[] args) {
        BigInteger sum = BigInteger.valueOf(Long.valueOf(1));
        BigInteger power = BigInteger.valueOf(Long.valueOf(2));
        for (int i = 0; i < 1000; i++){
            sum = sum.multiply(power);
        }
        System.out.println("The sum is: " + sum);

        int finalResult = 0;
        String intStr = sum.toString();
        int[] result = new int[intStr.length()];
        for (int j = 0; j < intStr.length(); j++){
            result[j] = Integer.parseInt(String.valueOf(intStr.charAt(j)));
        }
        for(int k = 0; k < result.length; k++){
            finalResult += result[k];
        }
        System.out.println(finalResult);
    }
}