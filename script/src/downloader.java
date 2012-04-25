import java.net.URL;
import java.io.*;

// simple downloader

class downloader {
  public static void main(String[] args) throws Exception {
    if ( args.length == 0 ) {
      return;
    }

    URL url = new URL(args[0]);
    String filename;
    String path = url.getPath();
    if ( path.equals("") ) {
      filename="tmp.out";
    }
    else {
      int idx = path.lastIndexOf('/');
      if ( idx >= 0 ) {
        filename = path.substring(idx+1);
      }
      else {
        filename = path;
      }
    }

    OutputStream out = null;
    InputStream in = null;
    byte[] buf = new byte[2048];
    try {
      in = url.openStream();
      out = new FileOutputStream(new File(filename)); 

      int readSize=0;
      while ( (readSize = in.read(buf)) >= 0 ) {
        out.write(buf, 0, readSize);
      }
      out.flush();
    }
    finally {
      if ( out != null ) {
        try {
          out.close();
        }
        catch (IOException ex) {
          ex.printStackTrace();
        }
      }
      if ( in != null ) {
        try {
          in.close();
        }
        catch (IOException ex) {
          ex.printStackTrace();
        }
      }
    }
  }
}
