const express = require('express');
const uuid = require('uuid');

const app = express();

const index = require('./routes/index.js');
const upload = require('./routes/upload.js');

app.use('/', index);
app.use('/upload', upload);

app.use((req, res, next) => {
    const err = new Error('Not Found');
    err.status = 404;
    next(err);
});

app.use((err, req, res, next) => {
    // set locals, only providing error in development
    res.locals.message = err.message;
    res.locals.error = req.app.get('env') === 'development' ? err : {};

    // render the error page
    res.status(err.status || 500);
    res.render('error');
});
