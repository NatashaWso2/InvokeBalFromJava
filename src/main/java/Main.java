import org.ballerinalang.bre.Context;
import org.ballerinalang.launcher.util.BCompileUtil;
import org.ballerinalang.launcher.util.BRunUtil;
import org.ballerinalang.launcher.util.CompileResult;
import org.ballerinalang.model.values.BString;
import org.ballerinalang.model.values.BValue;
import org.ballerinalang.util.codegen.PackageInfo;
import org.ballerinalang.util.codegen.ProgramFile;
import org.ballerinalang.util.debugger.Debugger;
import org.ballerinalang.util.program.BLangFunctions;

public class Main {
    final static String userDir = System.getProperty("user.dir");
    static CompileResult compileResult;

    /**
     * Main method to test download and upload functionalities
     *
     * @param args
     */
    public static void main(String[] args) {

        System.setProperty("java.util.logging.config.file",
                ClassLoader.getSystemResource("logging.properties").getPath());
        System.setProperty("java.util.logging.manager", "org.ballerinalang.logging.BLogManager");

        compileResult = compileBalFile();

        // Download files
        String host = "http://192.168.8.102:8000/";
        String resourceName = "c2.jpg";
        String destinationDirectoryPath = "/home/natasha/Desktop/UntitledFolder/image.jpg";
        downloadFiles(host, resourceName, destinationDirectoryPath);

        // Upload files
        // To test this use the inbound.bal service inside resources
        // First start the service inside inbound.bal and then call this function
        String uploadHost = "http://localhost:9090";
        String uploadResourceName = "/foo/receivableParts";
        String uploadFilePath = "/home/natasha/Desktop/c3.jpg";
        String contentType = "image/jpeg";
        uploadFiles(uploadHost, uploadResourceName, uploadFilePath, contentType);

    }

    /**
     * Download the files
     *
     * @param hostname     host name of web service/ftp where the file to be downloaded is stored
     * @param fileName     file name
     * @param outputFolder destination folder
     */
    public static void downloadFiles(String hostname, String fileName, String outputFolder) {
        BString host = new BString(hostname);
        BString resourcePath = new BString(fileName);
        BString dstPath = new BString(outputFolder);
        BValue[] paramArray = new BValue[]{host, resourcePath, dstPath};

        BRunUtil.invokeStateful(compileResult, "downloadFiles", paramArray);
    }

    /**
     * Upload file to the specified location
     *
     * @param uploadHost         host name
     * @param uploadResourceName resource name to be called
     * @param uploadFilePath     path of the file to be uploaded
     * @param contentType        content type of the file to be uploaded
     */
    public static void uploadFiles(String uploadHost, String uploadResourceName, String uploadFilePath, String contentType) {
        BString host = new BString(uploadHost);
        BString resourceName = new BString(uploadResourceName);
        BString filePath = new BString(uploadFilePath);
        BString contentTypeOfUpload = new BString(contentType);

        BValue[] paramArray = new BValue[]{host, resourceName, filePath, contentTypeOfUpload};

        BRunUtil.invokeStateful(compileResult, "uploadFiles", paramArray);

    }

    /**
     * Compile the bal file
     *
     * @return compile result after compiling the bal file
     */
    public static CompileResult compileBalFile() {
        CompileResult compileResult = BCompileUtil.compileAndSetup(
                userDir + "/src/main/resources/native.bal");

        ProgramFile programFile = compileResult.getProgFile();
        PackageInfo packageInfo = programFile.getPackageInfo(compileResult.getProgFile().getEntryPkgName());
        Context context = new Context(programFile);
        Debugger debugger = new Debugger(programFile);
        programFile.setDebugger(debugger);
        compileResult.setContext(context);
        BLangFunctions.invokePackageInitFunction(programFile, packageInfo.getInitFunctionInfo(), context);
        return compileResult;
    }
}
