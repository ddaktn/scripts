public class UdemyPlay {
    public static void main(String[] args) {
        System.out.println(322 % 10);
    }
    static boolean hasSharedDigit(int first, int second) {
        if(first < 10 || second < 10 || first > 99 || second > 99)
            return false;
        String firstString = String.valueOf(first);
        String secondString = String.valueOf(second);
        for(int i = 0; i < firstString.length(); i++) {
            char k = firstString.charAt(i);
            for(int j = 0; j < secondString.length(); j++) {
                char l = secondString.charAt(j);
                if(k == l) {
                    return true;
                }
            }
        }
        return false;
    }
}
