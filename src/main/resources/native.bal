import ballerina.file;
import ballerina.io;
import ballerina.mime;
import ballerina.net.http;

function downloadFiles (string host, string resourceName, string dstFilePath) {
    endpoint<http:HttpClient> httpEndpoint {
        create http:HttpClient(host, {});
    }
    http:OutRequest req = {};
    http:InResponse resp = {};
    resp, _ = httpEndpoint.get("/" + resourceName, req);
    writeToFile(resp.getBinaryPayload(), dstFilePath);
}

function writeToFile (blob readContent, string dstFilePath) {
    io:ByteChannel destinationChannel = getByteChannel(dstFilePath, "w");
    int numberOfBytesWritten = destinationChannel.writeBytes(readContent, 0);
    println("Content saved to file");
}

function getByteChannel (string filePath, string permission) (io:ByteChannel) {
    file:File src = {path:filePath};
    io:ByteChannel channel = src.openChannel(permission);
    return channel;
}

function uploadFiles (string host, string resourceTobeUploaded, string uploadFilePath, string contentType) {
    endpoint<http:HttpClient> httpEndpoint {
        create http:HttpClient(host, {});
    }
    mime:Entity topLevelEntity = {};
    mime:MediaType mediaType = mime:getMediaType(mime:MULTIPART_FORM_DATA);
    topLevelEntity.contentType = mediaType;

    mime:Entity filePart = {};
    mime:MediaType contentTypeOfFilePart = mime:getMediaType(contentType);
    filePart.contentType = contentTypeOfFilePart;
    file:File content = {path:uploadFilePath};
    filePart.overflowData = content;
    // You can define multiple resources
    mime:Entity[] bodyParts = [filePart];

    topLevelEntity.multipartData = bodyParts;
    http:OutRequest request = {};
    request.setEntity(topLevelEntity);
    http:InResponse resp1 = {};
    resp1, _ = httpEndpoint.post(resourceTobeUploaded, request);
}