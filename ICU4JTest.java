import java.io.*;
import java.math.BigInteger;

import com.ibm.icu.text.*;
import com.ibm.icu.util.ULocale;

/**
 * A simple program that accepts a collation name and an input file,
 * and prints generated strings.
 */
class ICU4JTest
{
  public static void main(String argv[])
      throws FileNotFoundException, IOException
  {
    assert argv.length == 2;

    String collationName = argv[0];
    String fname = argv[1];

    // Print the used language/collation
    System.out.println(collationName);

    // Build Collator
    ULocale loc = new ULocale(collationName);
    Collator clt = Collator.getInstance(loc);

    // Read line by line
    BufferedReader br = new BufferedReader(new FileReader(fname));
    String line;
    while ((line = br.readLine()) != null) {
      line = line.trim();

      // Ignore # lines
      if (line.length() > 0 && line.charAt(0) == '#')
        continue;
      
      byte[] inBytes = line.getBytes("utf-8");
      int inLen = inBytes.length;

      CollationKey ckey = clt.getCollationKey(line);
      byte[] outBuf = ckey.toByteArray();
      int outLen = outBuf.length;
      String hex = String.format("%X", new BigInteger(1, outBuf));

      System.out.printf("%3d %3d %-30s %-30s\n", inLen, outLen, line, hex);
    }
  }
}
