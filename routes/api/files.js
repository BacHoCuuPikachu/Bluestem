const express = require('express');
const router = express.Router();
const { v1: uuidv1} = require('uuid');
const { BlobServiceClient } = require('@azure/storage-blob');
require('dotenv').config();

router.get('/', async (req, res) => {
    // Create the BlobServiceClient object which will be used to create a container client
    const blobServiceClient = BlobServiceClient.fromConnectionString(
        process.env.AZURE_STORAGE_CONNECTION_STRING
    );
        
    // Get a reference to a container
    const containerClient = blobServiceClient.getContainerClient('main');

    // Create the container if not existed
    await containerClient.createIfNotExists();

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

    res.writeHead(200, {"Content-Type": "text/plain"});
    res.end(responseString);
});

module.exports = router;