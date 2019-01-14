/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package megabytesconverter;

/**
 *
 * @author mss92473
 */
public class MegaBytesConverter {

    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) {
        printMegaBytesAndKilobytes(2050);
    }
    
    public static void printMegaBytesAndKilobytes(int kiloBytes) {
        if(kiloBytes < 0) {
            System.out.println("Invalid Value");
        } else {
            int xx = kiloBytes;
            int yy = kiloBytes / 1024;
            int zz = kiloBytes % 1024;
            System.out.println(xx + " KB = " + yy + " MB and " + zz + " KB");
        }
    }
    
}
