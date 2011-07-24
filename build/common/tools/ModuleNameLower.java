import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.PrintWriter;

public class ModuleNameLower {

	public static void main(String[] args) throws Exception {
		String fileName = args[1];
		File file = new File(fileName);

		if (!file.exists()) {
			try {
				file.createNewFile();
			} catch (IOException ex) {
			}
		}
		FileOutputStream os = new FileOutputStream(fileName);
		PrintWriter out = new PrintWriter(os);
		String s = args[0];
		out.write(Character.toLowerCase(s.charAt(0)) + s.substring(1));
		out.close();
		os.close();
	}

}
