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
import java.io.*;

public class TextFile {
    
    public static String read(String filepath) {
        StringBuilder contentBuilder = new StringBuilder();
        try {            
            File f = new File(filepath);
            BufferedReader br = new BufferedReader(new FileReader(f));
            String currentLine;
            while ((currentLine = br.readLine()) != null) {
                contentBuilder.append(currentLine).append(System.lineSeparator());
            }
            br.close();
        }
        catch(IOException e) {
            System.err.println(e);
        }
        finally {
            return contentBuilder.toString();
        }
    }
    
    public static void write(String text, String filepath) {
        BufferedWriter bw = null;
	try{
//            String oldContent = read(filepath);
            File f = new File(filepath);
            f.createNewFile();
            bw = new BufferedWriter(new FileWriter(f));
            bw.write(text);
            bw.write(System.lineSeparator());
        }
	catch(IOException e){
            System.err.println(e);
	}
	finally{
            try{
                if(bw != null) bw.close();
            }
            catch(IOException e){
                System.err.println(e);
            } 
            finally {
                System.out.println(read(filepath));
            }
        }
    }
    
    public static void append(String text, String filepath) {
       BufferedWriter bw = null;
	try{
            String oldContent = read(filepath);
            File f = new File(filepath);
            f.createNewFile();
            bw = new BufferedWriter(new FileWriter(f));
            bw.write(oldContent);
            bw.append(System.lineSeparator());
            bw.append(text);
        }
	catch(IOException e){
            System.err.println(e);
	}
	finally{
            try{
                if(bw != null) bw.close();
            }
            catch(IOException e){
                System.err.println(e);
            }
            finally {
                System.out.println(read(filepath));
            }
        } 
    }
}
