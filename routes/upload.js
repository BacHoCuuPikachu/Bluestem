const express = require('express');
const { BlobServiceClient } = require('@azure/storage-blob');
const uuid = require('uuid');
const multer = require('multer');
const inMemoryStorage = multer.memoryStorage();
const uploadStrategy = multer({ storage: inMemoryStorage }).single('image');
const containerName = 'main';
require('dotenv').config();

const router = express.Router();
const handleError = (err, res) => {
    res.status(500);
    res.render('error', { error: err });
};

const getBlobName = originalName => {
    const identifier = uuid.v1(); // remove "0." from start of string
    return `${identifier}-${originalName}`;
};

router.post('/', uploadStrategy, (req, res) => {

    const
        blobName = getBlobName(req.file.originalname)
        , blobService = new BlockBlobClient(process.env.AZURE_STORAGE_CONNECTION_STRING, containerName, blobName)
        , stream = getStream(req.file.buffer)
        , streamLength = req.file.buffer.length
        ;

    blobService.uploadStream(stream, streamLength).then(() => {
        res.render('success', {
            message: 'File uploaded to Azure Blob storage.'
        });
    }).catch((err) => {
        if (err) {
            handleError(err, res);
            return;
        }
    })
});


module.exports = router;
