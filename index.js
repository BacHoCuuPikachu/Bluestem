const express = require('express');

app = express();

app.use('/api/files', require('./routes/api/files'));

const port = process.env.PORT || 8080;
app.listen(port, () => console.log(`Server started on port ${port}`));
