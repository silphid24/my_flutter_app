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
var __rest = (this && this.__rest) || function (s, e) {
    var t = {};
    for (var p in s) if (Object.prototype.hasOwnProperty.call(s, p) && e.indexOf(p) < 0)
        t[p] = s[p];
    if (s != null && typeof Object.getOwnPropertySymbols === "function")
        for (var i = 0, p = Object.getOwnPropertySymbols(s); i < p.length; i++) {
            if (e.indexOf(p[i]) < 0 && Object.prototype.propertyIsEnumerable.call(s, p[i]))
                t[p[i]] = s[p[i]];
        }
    return t;
};
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const admin = __importStar(require("firebase-admin"));
const functions = __importStar(require("firebase-functions/v1"));
const express_1 = __importDefault(require("express"));
const router = express_1.default.Router();
// 인증 확인 미들웨어
const authenticate = async (req, res, next) => {
    try {
        const authHeader = req.headers.authorization;
        if (!authHeader || !authHeader.startsWith('Bearer ')) {
            return res.status(401).json({ error: 'Unauthorized: No token provided' });
        }
        const idToken = authHeader.split('Bearer ')[1];
        // Firebase 토큰 검증
        const decodedToken = await admin.auth().verifyIdToken(idToken);
        req.user = decodedToken; // 사용자 정보를 요청 객체에 추가
        next();
    }
    catch (error) {
        functions.logger.error('Authentication error:', error);
        return res.status(401).json({ error: 'Unauthorized: Invalid token' });
    }
};
// 현재 인증된 사용자의 프로필 정보 조회
router.get('/me', authenticate, (async (req, res) => {
    try {
        const userId = req.user.uid;
        // Firestore에서 사용자 정보 조회
        const userDoc = await admin.firestore().collection('users').doc(userId).get();
        if (!userDoc.exists) {
            return res.status(404).json({ error: 'User not found' });
        }
        const userData = userDoc.data();
        // 사용자 설정 정보 조회
        const settingsDoc = await admin.firestore().collection('users').doc(userId).collection('settings').doc('preferences').get();
        let settings = {};
        if (settingsDoc.exists) {
            settings = settingsDoc.data();
        }
        return res.status(200).json({
            user: Object.assign(Object.assign({}, userData), { settings })
        });
    }
    catch (error) {
        functions.logger.error('Error fetching user profile:', error);
        return res.status(500).json({ error: 'Failed to fetch user profile' });
    }
}));
// 사용자 프로필 정보 업데이트
router.patch('/me', authenticate, (async (req, res) => {
    try {
        const userId = req.user.uid;
        const { displayName, photoURL, bio, language } = req.body;
        // 업데이트할 필드 준비
        const updateData = {};
        if (displayName !== undefined)
            updateData.displayName = displayName;
        if (photoURL !== undefined)
            updateData.photoURL = photoURL;
        if (bio !== undefined)
            updateData.bio = bio;
        if (language !== undefined)
            updateData.language = language;
        // 타임스탬프 추가
        updateData.updatedAt = admin.firestore.FieldValue.serverTimestamp();
        // Firestore 업데이트
        await admin.firestore().collection('users').doc(userId).update(updateData);
        // 업데이트된 사용자 정보 조회
        const updatedUserDoc = await admin.firestore().collection('users').doc(userId).get();
        return res.status(200).json({
            message: 'User profile updated successfully',
            user: updatedUserDoc.data()
        });
    }
    catch (error) {
        functions.logger.error('Error updating user profile:', error);
        return res.status(500).json({ error: 'Failed to update user profile' });
    }
}));
// 사용자 설정 업데이트
router.patch('/me/settings', authenticate, (async (req, res) => {
    try {
        const userId = req.user.uid;
        const { notifications, theme, distanceUnit, mapType } = req.body;
        // 업데이트할 설정 준비
        const updateData = {};
        if (notifications !== undefined)
            updateData.notifications = notifications;
        if (theme !== undefined)
            updateData.theme = theme;
        if (distanceUnit !== undefined)
            updateData.distanceUnit = distanceUnit;
        if (mapType !== undefined)
            updateData.mapType = mapType;
        // 타임스탬프 추가
        updateData.updatedAt = admin.firestore.FieldValue.serverTimestamp();
        // Firestore 설정 업데이트
        await admin.firestore()
            .collection('users')
            .doc(userId)
            .collection('settings')
            .doc('preferences')
            .set(updateData, { merge: true });
        return res.status(200).json({
            message: 'User settings updated successfully',
            settings: updateData
        });
    }
    catch (error) {
        functions.logger.error('Error updating user settings:', error);
        return res.status(500).json({ error: 'Failed to update user settings' });
    }
}));
// 사용자 계정 비활성화 (실제 삭제 대신 isDeleted 플래그 사용)
router.delete('/me', authenticate, (async (req, res) => {
    try {
        const userId = req.user.uid;
        // isDeleted 플래그를 true로 설정
        await admin.firestore().collection('users').doc(userId).update({
            isDeleted: true,
            updatedAt: admin.firestore.FieldValue.serverTimestamp()
        });
        return res.status(200).json({
            message: 'User account has been deactivated'
        });
    }
    catch (error) {
        functions.logger.error('Error deactivating user account:', error);
        return res.status(500).json({ error: 'Failed to deactivate user account' });
    }
}));
// 사용자의 모든 진행 상황 조회
router.get('/me/progress', authenticate, (async (req, res) => {
    try {
        const userId = req.user.uid;
        // Firestore에서 사용자의 모든 진행 상황 조회
        const progressSnapshot = await admin.firestore()
            .collection('progress')
            .where('userId', '==', userId)
            .get();
        if (progressSnapshot.empty) {
            return res.status(200).json({
                progress: []
            });
        }
        const progress = progressSnapshot.docs.map(doc => (Object.assign({ id: doc.id }, doc.data())));
        return res.status(200).json({
            progress
        });
    }
    catch (error) {
        functions.logger.error('Error fetching user progress:', error);
        return res.status(500).json({ error: 'Failed to fetch user progress' });
    }
}));
// 특정 경로에 대한 사용자의 진행 상황 조회
router.get('/me/progress/:routeId', authenticate, (async (req, res) => {
    try {
        const userId = req.user.uid;
        const { routeId } = req.params;
        // Firestore에서 특정 경로에 대한 진행 상황 조회
        const progressSnapshot = await admin.firestore()
            .collection('progress')
            .where('userId', '==', userId)
            .where('routeId', '==', routeId)
            .limit(1)
            .get();
        if (progressSnapshot.empty) {
            return res.status(404).json({
                error: 'Progress data not found for this route'
            });
        }
        const progressDoc = progressSnapshot.docs[0];
        return res.status(200).json(Object.assign({ id: progressDoc.id }, progressDoc.data()));
    }
    catch (error) {
        functions.logger.error('Error fetching route progress:', error);
        return res.status(500).json({ error: 'Failed to fetch route progress' });
    }
}));
// 특정 경로에 대한 사용자의 진행 상황 업데이트/생성
router.patch('/me/progress/:routeId', authenticate, (async (req, res) => {
    try {
        const userId = req.user.uid;
        const { routeId } = req.params;
        const { currentLocation, currentStageId, completedStages, distance, lastActive } = req.body;
        // 업데이트할 데이터 준비
        const updateData = {
            userId,
            routeId,
            updatedAt: admin.firestore.FieldValue.serverTimestamp()
        };
        if (currentLocation !== undefined)
            updateData.currentLocation = currentLocation;
        if (currentStageId !== undefined)
            updateData.currentStageId = currentStageId;
        if (completedStages !== undefined)
            updateData.completedStages = completedStages;
        if (distance !== undefined)
            updateData.distance = distance;
        if (lastActive !== undefined)
            updateData.lastActive = lastActive;
        // 기존 진행 상황 조회
        const progressSnapshot = await admin.firestore()
            .collection('progress')
            .where('userId', '==', userId)
            .where('routeId', '==', routeId)
            .limit(1)
            .get();
        let progressId;
        if (progressSnapshot.empty) {
            // 진행 상황이 없는 경우 새로 생성
            updateData.createdAt = admin.firestore.FieldValue.serverTimestamp();
            const newProgressRef = await admin.firestore()
                .collection('progress')
                .add(updateData);
            progressId = newProgressRef.id;
        }
        else {
            // 기존 진행 상황 업데이트
            const progressDoc = progressSnapshot.docs[0];
            progressId = progressDoc.id;
            await admin.firestore()
                .collection('progress')
                .doc(progressId)
                .update(updateData);
        }
        // 업데이트된 진행 상황 조회
        const updatedProgressDoc = await admin.firestore()
            .collection('progress')
            .doc(progressId)
            .get();
        return res.status(200).json({
            message: 'Progress updated successfully',
            progress: Object.assign({ id: progressId }, updatedProgressDoc.data())
        });
    }
    catch (error) {
        functions.logger.error('Error updating progress:', error);
        return res.status(500).json({ error: 'Failed to update progress' });
    }
}));
// 프로필 사진 업로드를 위한 서명된 URL 생성
router.post('/me/profile-upload-url', authenticate, (async (req, res) => {
    try {
        const userId = req.user.uid;
        const { contentType } = req.body;
        if (!contentType || !contentType.startsWith('image/')) {
            return res.status(400).json({ error: 'Invalid content type. Only images are allowed.' });
        }
        // 파일 확장자 결정
        const fileExtension = contentType.split('/')[1] || 'jpeg';
        // 파일명 생성 (프로필 이미지는 사용자 ID로 고정, 타임스탬프 추가)
        const fileName = `profile_${userId}_${Date.now()}.${fileExtension}`;
        // 스토리지 경로 생성
        const filePath = `users/${userId}/profile/${fileName}`;
        // Firebase Storage 버킷 참조
        const bucket = admin.storage().bucket();
        const file = bucket.file(filePath);
        // 서명된 URL 생성 (업로드용)
        const [uploadUrl] = await file.getSignedUrl({
            version: 'v4',
            action: 'write',
            expires: Date.now() + 15 * 60 * 1000,
            contentType
        });
        // 읽기용 URL 생성
        const [downloadUrl] = await file.getSignedUrl({
            version: 'v4',
            action: 'read',
            expires: Date.now() + 24 * 60 * 60 * 1000 // 24시간 유효
        });
        return res.status(200).json({
            uploadUrl,
            downloadUrl,
            filePath
        });
    }
    catch (error) {
        functions.logger.error('Error generating signed URL:', error);
        return res.status(500).json({ error: 'Failed to generate upload URL' });
    }
}));
// 업로드된 프로필 사진 URL을 사용자 정보에 업데이트
router.post('/me/profile-photo', authenticate, (async (req, res) => {
    try {
        const userId = req.user.uid;
        const { filePath } = req.body;
        if (!filePath) {
            return res.status(400).json({ error: 'File path is required' });
        }
        // 스토리지 파일 참조
        const bucket = admin.storage().bucket();
        const file = bucket.file(filePath);
        // 파일 존재 여부 확인
        const [exists] = await file.exists();
        if (!exists) {
            return res.status(404).json({ error: 'File not found' });
        }
        // 공개 URL 생성
        const publicUrl = `https://storage.googleapis.com/${bucket.name}/${filePath}`;
        // Firestore 사용자 프로필 업데이트
        await admin.firestore().collection('users').doc(userId).update({
            photoURL: publicUrl,
            updatedAt: admin.firestore.FieldValue.serverTimestamp()
        });
        return res.status(200).json({
            message: 'Profile photo updated successfully',
            photoURL: publicUrl
        });
    }
    catch (error) {
        functions.logger.error('Error updating profile photo:', error);
        return res.status(500).json({ error: 'Failed to update profile photo' });
    }
}));
// 특정 ID의 사용자 공개 프로필 조회
router.get('/:userId', (async (req, res) => {
    try {
        const { userId } = req.params;
        // Firestore에서 사용자 정보 조회
        const userDoc = await admin.firestore().collection('users').doc(userId).get();
        if (!userDoc.exists) {
            return res.status(404).json({ error: 'User not found' });
        }
        const userData = userDoc.data();
        // 비공개 필드 제거
        const { email, phoneNumber, isDeleted } = userData, publicUserData = __rest(userData, ["email", "phoneNumber", "isDeleted"]);
        // 삭제된 사용자인 경우
        if (isDeleted) {
            return res.status(404).json({ error: 'User not found' });
        }
        return res.status(200).json({
            user: publicUserData
        });
    }
    catch (error) {
        functions.logger.error('Error fetching user profile:', error);
        return res.status(500).json({ error: 'Failed to fetch user profile' });
    }
}));
exports.default = router;
//# sourceMappingURL=userRoutes.js.map