const http = require('http');
const formidable = require('formidable');
const fs = require('fs');
const path = require('path');
const express = require('express');

const PORT = process.env.PORT || 5000;

const app = new express();

app.use(express.static(path.join(__dirname, 'public')));

app.listen(PORT, err => {
    if (err) {
        return console.log("ERROR", err);
    }
    console.log(`Listening on port ${PORT}`);
});
