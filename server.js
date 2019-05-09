const http = require("http");

const server = http.createServer((req, res) => {
  res.setHeader("Access-Control-Allow-Origin", "*");
  res.writeHead(200, { "Content-Type": "application/json" });
  const data = [Math.random(), Math.random(), Math.random()];
  res.end("[" + data.join() + "]");
});

const callback = () => {
  const address = server.address().address;
  const port = server.address().port;
  console.log(`
  Server avviato all'indirizzo http://${address}:${port}
  `);
};

server.listen(3000, "127.0.0.1", callback);
