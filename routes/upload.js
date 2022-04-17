const express = require('express');
const { BlobServiceClient } = require('@azure/storage-blob');
const uuid = require('uuid');
require('dotenv').config();

const router = express.Router();

router.get(async (req, res) => {
    // Create the BlobServiceClient object which will be used to create a container client
    const blobServiceClient = BlobServiceClient.fromConnectionString(
        process.env.AZURE_STORAGE_CONNECTION_STRING
    );
        
    // Get a reference to a container
    const containerClient = blobServiceClient.getContainerClient('main');

    responseString += "\nListing blobs...";

    // List the blob(s) in the container.
    for await (const blob of containerClient.listBlobsFlat()) {
        responseString += "\n\t" + blob.name;
    }

    res.writeHead(200, {"Content-Type": "text/plain"});
    res.end(responseString);
});

const port = process.env.PORT || 1337;
server.listen(port);

console.log("Server running at http://localhost:%d", port);
