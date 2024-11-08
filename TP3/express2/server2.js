const express = require('express');
const app = express();
const port = 3002;

app.get('/', (req, res) => {
	res.send('Hello from server ' + port);
});

app.listen(port, () => {
	console.log('Server running on port ' + port);
});
