const http = require('http');
const formidable = require('formidable');
const fs = require('fs');
const path = require('path');

const PORT = process.env.PORT || 5000;

const Displayer = require('./error');

http.createServer((req, res) => {
    if (req.url == '/fileupload') {
        let form = new formidable.IncomingForm();
        form.parse(req, (err, fields, file) => {
            if (err) {
                Displayer.Display(res, err.code);
                throw err;
            }

            let filepath = file.filetoupload.filepath;
            let newpath = 'C:/Users/PC/Downloads/';
            newpath += file.filetoupload.originalFilename;

            fs.rename(filepath, newpath, (err) => {
                if (err) {
                    Displayer.Display(res, err.code);
                    throw err;
                }
                res.writeHead(200, { 'Content-Type': 'text/html' });
                res.write('<h1>File uploaded!</h1>');
            });
        });
        res.write('<h1>File uploaded!</h1>');
        return res.end();
    }

    res.writeHead(200, { 'Content-Type': 'text/html' });
    res.write('<form action="fileupload" method="post" enctype="multipart/form-data">');
    res.write('<input type="file" name="filetoupload"><br>');
    res.write('<input type="submit">');
    res.write('</form>');
    res.end();
}).listen(PORT);

console.log(`Server is running at ${PORT}`); 