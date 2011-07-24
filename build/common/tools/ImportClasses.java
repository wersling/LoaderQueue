import java.io.BufferedReader;
import java.io.File;
import java.io.FileOutputStream;
import java.io.FileReader;
import java.io.IOException;
import java.io.PrintWriter;

/**
 * @author sean
 * 
 */
public class ImportClasses {

    public static void main(String[] args) throws Exception {
        // get output path
        String outputFilePath = args[0];
        String outputPackage = getFilePath(outputFilePath);
        if(outputPackage.indexOf(".") != -1)
        {
            outputPackage = outputPackage.substring(0,
                    outputPackage.lastIndexOf("."));
        }
        else
        {
            outputPackage = "";
        }

        // class start
        String fileName = new File(outputFilePath).getName();
        fileName = fileName.substring(0, fileName.lastIndexOf("."));
        String code = "package " + outputPackage + "\n" + "{\n"
                + "public class " + fileName + "\n" + "{\n";

        // import code
        for (int i = 1; i < args.length; i++) {
            code += seatchFiles(args[i]);
        }

        // class end
        code += "}\n}\n";
        FileOutputStream os = new FileOutputStream(outputFilePath);
        PrintWriter out = new PrintWriter(os);
        out.write(code);
        out.close();
        os.close();
    }

    /**
     * get all import code by file path
     * @param filePath
     * @return
     * @throws IOException 
     */
    private static String seatchFiles(String filePath) throws IOException {
        String result = "";
        File file = new File(filePath);
        File[] list = file.listFiles();
        for (int i = 0; i < list.length; i++) {
            File f = list[i];
            if (f.isDirectory() && !f.isHidden()) {
                result += seatchFiles(f.getPath());
            } else if (f.isFile() && isPublicClass(f)) {
                String fileName = getFilePath(f.getPath());
                result += "import " + fileName + ";" + fileName + ";\n";
            }
        }
        return result;
    }

    /**
     * get file path
     * 
     * @param path
     * @return
     */
    private static String getFilePath(String path) {
        String result = path;
        result = result.substring(result.indexOf("src") + 4,
                result.length() - 3);
        result = result.replace("\\", ".");
        result = result.replace("/", ".");
        return result;
    }

    private static Boolean isPublicClass(File f) throws IOException {
        //not as file
        if(f.getName().indexOf(".as") == -1)
        {
            return false;
        }
        FileReader fr = new FileReader(f);
        BufferedReader br = new BufferedReader(fr);
        String row = null;
        while((row = br.readLine()) != null)
        {
            //has "public class" or "public interface"
            if(row.indexOf("public") != -1 &&
                    //命名空间
                    (row.indexOf("namespace") != -1 || 
                    //类或接口
                     row.indexOf("class") != -1 || row.indexOf("interface") != -1))
            {
                return true;
            }
        }
        return false;
    }

}
