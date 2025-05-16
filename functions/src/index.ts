import * as functions from 'firebase-functions/v1';
import * as admin from 'firebase-admin';
import express from 'express';
import cors from 'cors';

// 라우트 불러오기 (상대 경로 수정)
import userRoutes from './routes/userRoutes';

// Firebase 초기화
admin.initializeApp();

// Express 앱 초기화
const app = express();

// 미들웨어 설정
app.use(cors({ origin: true }));
app.use(express.json());

// 라우트 등록
app.use('/api/users', userRoutes);

// 기본 라우트
app.get('/', (req: express.Request, res: express.Response) => {
  res.status(200).send('Camino de Santiago API Server');
});

// API 서버 함수 내보내기
export const api = functions.https.onRequest(app);

// Firestore 트리거 함수 - v1 스타일 API 사용
export const onUserCreated = functions.firestore
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
    } catch (error) {
      functions.logger.error(`Error creating settings for user: ${userId}`, error);
      return null;
    }
  });

// 사용자 업데이트 트리거
export const onUserUpdated = functions.firestore
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