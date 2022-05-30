const express = require('express');

app = express();

app.use('/api/files', require('./routes/api/files'));

const port = 5000;
app.listen(port, () => console.log(`Server started on port ${port}`));
