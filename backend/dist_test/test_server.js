"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
var express_1 = require("express");
var app = (0, express_1.default)();
var PORT = 8080;
app.get("/health", function (_req, res) {
    res.status(200).json({ status: "ok" });
});
app.listen(PORT, function () {
    console.log("Test server running on port ".concat(PORT));
});
