var http = require('http');

var server = http.createServer(function (req, res) {
  res.writeHead(200, {"Content-Type": "text/plain"});
  console.log(req.url);
  res.end("Hello World\n");
});

server.listen(8000);

console.log("Server running at http://127.0.0.1:8000/");
