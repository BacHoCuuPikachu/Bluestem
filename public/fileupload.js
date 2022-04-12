const formidable = require('formidable');
const fs = require('fs');

let form = new formidable.IncomingForm();
form.parse(req, (err, fields, file) => {
    if (err) {
        throw err;
    }

    let filepath = file.filetoupload.filepath;
    let newpath = './Storage/';
    newpath += file.filetoupload.originalFilename;

    fs.rename(filepath, newpath, (err) => {
        if (err) {
            throw err;
        }

        console.log("Done!");
    });
});