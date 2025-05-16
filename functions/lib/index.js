"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || function (mod) {
    if (mod && mod.__esModule) return mod;
    var result = {};
    if (mod != null) for (var k in mod) if (k !== "default" && Object.prototype.hasOwnProperty.call(mod, k)) __createBinding(result, mod, k);
    __setModuleDefault(result, mod);
    return result;
};
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.onUserUpdated = exports.onUserCreated = exports.api = void 0;
const functions = __importStar(require("firebase-functions/v1"));
const admin = __importStar(require("firebase-admin"));
const express_1 = __importDefault(require("express"));
const cors_1 = __importDefault(require("cors"));
// 라우트 불러오기 (상대 경로 수정)
const userRoutes_1 = __importDefault(require("./routes/userRoutes"));
// Firebase 초기화
admin.initializeApp();
// Express 앱 초기화
const app = (0, express_1.default)();
// 미들웨어 설정
app.use((0, cors_1.default)({ origin: true }));
app.use(express_1.default.json());
// 라우트 등록
app.use('/api/users', userRoutes_1.default);
// 기본 라우트
app.get('/', (req, res) => {
    res.status(200).send('Camino de Santiago API Server');
});
// API 서버 함수 내보내기
exports.api = functions.https.onRequest(app);
// Firestore 트리거 함수 - v1 스타일 API 사용
exports.onUserCreated = functions.firestore
    .document('users/{userId}')
    .onCreate(async (snapshot, context) => {
    const userId = context.params.userId;
    const userData = snapshot.data();
    try {
        // 사용자 기본 설정 생성
        await admin.firestore().collection('users').doc(userId).collection('settings').doc('preferences').set({
            language: 'ko',
            notifications: true,
            darkMode: false,
            distanceUnit: 'km',
            createdAt: admin.firestore.FieldValue.serverTimestamp()
        });
        functions.logger.info(`User settings created for user: ${userId}`);
        return null;
    }
    catch (error) {
        functions.logger.error(`Error creating settings for user: ${userId}`, error);
        return null;
    }
});
// 사용자 업데이트 트리거
exports.onUserUpdated = functions.firestore
    .document('users/{userId}')
    .onUpdate(async (change, context) => {
    const userId = context.params.userId;
    const beforeData = change.before.data();
    const afterData = change.after.data();
    // 사용자 데이터 변경 로깅
    functions.logger.info(`User ${userId} updated`, {
        before: beforeData,
        after: afterData
    });
    return null;
});
//# sourceMappingURL=index.js.map