const formidable = require('formidable');
const fs = require('fs');
const path = require('path');

console.log('Accessed!');

fs.readdir('./Storage', (err, files) => {
    if (err) throw err;
    files.forEach(file => {
        console.log(file);
    });
});