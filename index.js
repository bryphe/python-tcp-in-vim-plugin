var net = require("net");

var server = net.createServer(function (socket) {
    console.log("Client connected?");

    socket.on("data", function(data) {
        var stringData = data.toString("utf8");
        console.log(stringData);
        socket.write("test return: " + stringData + "\n");
    });

    socket.on("close", function () {
        console.log("Client closed connection");
    });

    socket.on("error", function (err) {
        console.log("Client disconnected");
    });
});

server.on("data", function (data) {
    console.log("Received: " + data);
    socket.write("Hello");
});

server.on("error", function (data) {
    console.log("error");
});

server.listen(5005, "127.0.0.1");
