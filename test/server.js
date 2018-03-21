let http=require('http');

let server = http.createServer(function(request, response) {
  response.writeHead(200, {"Content-Type": "application/json"});
  response.write(JSON.stringify(request.headers));
  response.end();
});

server.listen(8080);
