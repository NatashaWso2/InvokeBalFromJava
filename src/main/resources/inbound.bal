import ballerina.file;
import ballerina.io;
import ballerina.mime;
import ballerina.net.http;@http:configuration {basePath:"/foo"}
service<http> echo {
    @http:resourceConfig {
        methods:["POST"],
        path:"/receivableParts"
    }
    resource echo (http:Connection conn, http:InRequest req) {
        mime:Entity[] bodyParts = req.getMultiparts();
        int i = 0;
        while (i < lengthof bodyParts) {
            mime:Entity part = bodyParts[i];
            println("-----------------------------");
            print("Content Type : ");
            println(part.contentType.toString());
            println("-----------------------------");
            handleContent(part, i);
            i = i + 1;
        }
        http:OutResponse res = {};
        res.setStringPayload("Multiparts Received!");
        _ = conn.respond(res);
    }
}
function handleContent (mime:Entity bodyPart, int i) {
    string contentType = bodyPart.contentType.toString();
    if (mime:APPLICATION_XML == contentType || mime:TEXT_XML == contentType) {
        println(mime:getXml(bodyPart));
    } else if (mime:APPLICATION_JSON == contentType) {
        println(mime:getJson(bodyPart));
    } else if (mime:TEXT_PLAIN == contentType) {
        println(mime:getText(bodyPart));
    } else if ("image/jpeg" == contentType) {
        writeToFile(mime:getBlob(bodyPart), i);
        println("Content saved to file");
    }
}
function writeToFile (blob readContent, int i) {
    string dstFilePath = "/home/natasha/Desktop/Images/image-" + i + ".jpg";
    io:ByteChannel destinationChannel = getByteChannel(dstFilePath, "w");
    int numberOfBytesWritten = destinationChannel.writeBytes(readContent, 0);
    println(numberOfBytesWritten);
}
function getByteChannel (string filePath, string permission) (io:ByteChannel) {
    file:File src = {path:filePath};
    io:ByteChannel channel = src.openChannel(permission);
    return channel;
}