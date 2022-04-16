const http = require('http');
const { BlobServiceClient } = require('@azure/storage-blob');
const { v1: uuidv1} = require('uuid');
require('dotenv').config();

// Create the BlobServiceClient object which will be used to create a container client
const blobServiceClient = BlobServiceClient.fromConnectionString(
    process.env.AZURE_STORAGE_CONNECTION_STRING
);

// Create a unique name for the container
const containerName = "main" + uuidv1();

console.log("Creating container: " + containerName);

// Get a reference to a container
const containerClient = blobServiceClient.getContainerClient(containerName);
// Create the container
const createContainerResponse = await containerClient.create();
console.log("\nContainer was created successfully. requestId: ", createContainerResponse.requestId);

const server = http.createServer(async (request, response) => {
    // Create a unique name for the blob
    const blobName = uuidv1() + ".txt";

    // Get a block blob client
    const blockBlobClient = containerClient.getBlockBlobClient(blobName);

    var responseString = "\nUploading to Azure storage as blob:\n\t" + blobName;

    // Upload data to the blob
    const data = "Hello, World!";
    const uploadBlobResponse = await blockBlobClient.upload(data, data.length);
    responseString += "Blob was uploaded successfully. requestId: " + uploadBlobResponse.requestId;

    responseString += "\nListing blobs...";

    // List the blob(s) in the container.
    for await (const blob of containerClient.listBlobsFlat()) {
        responseString += "\n\t" + blob.name;
    }

    response.writeHead(200, {"Content-Type": "text/plain"});
    response.end(responseString);
});

const port = process.env.PORT || 1337;
server.listen(port);

console.log("Server running at http://localhost:%d", port);
