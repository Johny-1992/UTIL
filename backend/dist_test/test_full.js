"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
var __generator = (this && this.__generator) || function (thisArg, body) {
    var _ = { label: 0, sent: function() { if (t[0] & 1) throw t[1]; return t[1]; }, trys: [], ops: [] }, f, y, t, g = Object.create((typeof Iterator === "function" ? Iterator : Object).prototype);
    return g.next = verb(0), g["throw"] = verb(1), g["return"] = verb(2), typeof Symbol === "function" && (g[Symbol.iterator] = function() { return this; }), g;
    function verb(n) { return function (v) { return step([n, v]); }; }
    function step(op) {
        if (f) throw new TypeError("Generator is already executing.");
        while (g && (g = 0, op[0] && (_ = 0)), _) try {
            if (f = 1, y && (t = op[0] & 2 ? y["return"] : op[0] ? y["throw"] || ((t = y["return"]) && t.call(y), 0) : y.next) && !(t = t.call(y, op[1])).done) return t;
            if (y = 0, t) op = [op[0] & 2, t.value];
            switch (op[0]) {
                case 0: case 1: t = op; break;
                case 4: _.label++; return { value: op[1], done: false };
                case 5: _.label++; y = op[1]; op = [0]; continue;
                case 7: op = _.ops.pop(); _.trys.pop(); continue;
                default:
                    if (!(t = _.trys, t = t.length > 0 && t[t.length - 1]) && (op[0] === 6 || op[0] === 2)) { _ = 0; continue; }
                    if (op[0] === 3 && (!t || (op[1] > t[0] && op[1] < t[3]))) { _.label = op[1]; break; }
                    if (op[0] === 6 && _.label < t[1]) { _.label = t[1]; t = op; break; }
                    if (t && _.label < t[2]) { _.label = t[2]; _.ops.push(op); break; }
                    if (t[2]) _.ops.pop();
                    _.trys.pop(); continue;
            }
            op = body.call(thisArg, _);
        } catch (e) { op = [6, e]; y = 0; } finally { f = t = 0; }
        if (op[0] & 5) throw op[1]; return { value: op[0] ? op[1] : void 0, done: true };
    }
};
Object.defineProperty(exports, "__esModule", { value: true });
// test_full.ts
var axios_1 = require("axios");
var ethers_1 = require("ethers");
var omniutil_abi_json_1 = require("./src/utils/omniutil_abi.json");
// ----------------------
// CONFIGURATION
// ----------------------
var OMNIUTIL_CONTRACT_ADDRESS = "0xcFFDa93651Fc8a514e3B06A7a7bA4BEe663B8bA1";
// Provider JSON-RPC
var provider = new ethers_1.JsonRpcProvider("http://127.0.0.1:8545");
// Création du contrat OmniUtil
var omniUtilContract = new ethers_1.Contract(OMNIUTIL_CONTRACT_ADDRESS, omniutil_abi_json_1.default.abi, provider);
// Endpoints Express
var endpoints = {
    health: "http://127.0.0.1:8080/health",
    aiStatus: "http://127.0.0.1:8080/api/ai/status",
};
// ----------------------
// FONCTIONS UTILITAIRES
// ----------------------
function testEndpoint(name, url) {
    return __awaiter(this, void 0, void 0, function () {
        var response, err_1;
        return __generator(this, function (_a) {
            switch (_a.label) {
                case 0:
                    _a.trys.push([0, 2, , 3]);
                    return [4 /*yield*/, axios_1.default.get(url)];
                case 1:
                    response = _a.sent();
                    console.log("\u2705 ".concat(name, " response:"), response.data);
                    return [3 /*break*/, 3];
                case 2:
                    err_1 = _a.sent();
                    console.error("\u274C ".concat(name, " error:"), err_1.message || err_1);
                    return [3 /*break*/, 3];
                case 3: return [2 /*return*/];
            }
        });
    });
}
function testContract() {
    return __awaiter(this, void 0, void 0, function () {
        var totalSupply, owner, err_2;
        return __generator(this, function (_a) {
            switch (_a.label) {
                case 0:
                    console.log("\n🚀 Test du contrat OmniUtil...");
                    _a.label = 1;
                case 1:
                    _a.trys.push([1, 6, , 7]);
                    if (!("totalSupply" in omniUtilContract)) return [3 /*break*/, 3];
                    return [4 /*yield*/, omniUtilContract.totalSupply()];
                case 2:
                    totalSupply = _a.sent();
                    console.log("Contract totalSupply:", totalSupply.toString());
                    _a.label = 3;
                case 3:
                    if (!("owner" in omniUtilContract)) return [3 /*break*/, 5];
                    return [4 /*yield*/, omniUtilContract.owner()];
                case 4:
                    owner = _a.sent();
                    console.log("Contract owner:", owner);
                    _a.label = 5;
                case 5:
                    console.log("✅ Contrat testé avec succès !");
                    return [3 /*break*/, 7];
                case 6:
                    err_2 = _a.sent();
                    console.error("❌ Erreur contrat:", err_2.message || err_2);
                    return [3 /*break*/, 7];
                case 7: return [2 /*return*/];
            }
        });
    });
}
// ----------------------
// MAIN
// ----------------------
function main() {
    return __awaiter(this, void 0, void 0, function () {
        return __generator(this, function (_a) {
            switch (_a.label) {
                case 0:
                    console.log("🔹 Démarrage des tests full moon...");
                    return [4 /*yield*/, testEndpoint("Health endpoint", endpoints.health)];
                case 1:
                    _a.sent();
                    return [4 /*yield*/, testEndpoint("AI Status endpoint", endpoints.aiStatus)];
                case 2:
                    _a.sent();
                    return [4 /*yield*/, testContract()];
                case 3:
                    _a.sent();
                    console.log("\n🌕 Full Moon script terminé !");
                    return [2 /*return*/];
            }
        });
    });
}
main();
