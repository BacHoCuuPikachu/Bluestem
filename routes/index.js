const express = require('express');
const { BlobServiceClient } = require('@azure/storage-blob');
const uuid = require('uuid');
require('dotenv').config();

const router = express.Router();

router.get(async (req, res) => {
    const AZURE_STORAGE_CONNECTION_STRING = process.env.AZURE_STORAGE_CONNECTION_STRING;

    if (!AZURE_STORAGE_CONNECTION_STRING) {
        response.writeHead(404, {"Content-Type": "text/plain"});
        response.end("Storage Connection string not found");
        return;
    }

    // Create the BlobServiceClient object which will be used to create a container client
    const blobServiceClient = BlobServiceClient.fromConnectionString(
        AZURE_STORAGE_CONNECTION_STRING
    );
    
    // Create a unique name for the container
    const containerClient = blobServiceClient.getContainerClient('main');

    var responseString = "Listing blobs...";

    // List the blob(s) in the container.
    for await (const blob of containerClient.listBlobsFlat()) {
        responseString += "\n\t" + blob.name;
    }

    response.writeHead(200, {"Content-Type": "text/plain"});
    response.end(responseString);
});

module.exports = router;
