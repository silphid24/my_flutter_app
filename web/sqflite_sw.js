// SQLite 웹 워커 파일
self.importScripts('https://cdn.jsdelivr.net/npm/sql.js@1.8.0/dist/sql-wasm.js');

// 메시지 리스너
self.onmessage = async function(e) {
  const data = e.data;
  
  // SQL.js가 로드되었는지 확인
  if (typeof self.initSqlJs === 'undefined') {
    self.postMessage({
      id: data.id,
      error: 'SQL.js가 초기화되지 않았습니다'
    });
    return;
  }
  
  try {
    // SQL.js 초기화
    const SQL = await self.initSqlJs();
    
    // 명령 처리
    switch (data.action) {
      case 'open':
        // 새 데이터베이스 생성 또는 기존 데이터베이스 열기
        const db = new SQL.Database(data.buffer);
        self.db = db;
        self.postMessage({
          id: data.id,
          result: 'Database opened'
        });
        break;
        
      case 'execute':
        // SQL 쿼리 실행
        if (!self.db) {
          throw new Error('데이터베이스가 열려있지 않습니다');
        }
        
        const result = self.db.exec(data.sql, data.params);
        self.postMessage({
          id: data.id,
          result: result
        });
        break;
        
      case 'close':
        // 데이터베이스 닫기
        if (self.db) {
          const buffer = self.db.export();
          self.db.close();
          self.db = null;
          
          self.postMessage({
            id: data.id,
            result: 'Database closed',
            buffer: buffer
          });
        } else {
          self.postMessage({
            id: data.id,
            result: 'No database to close'
          });
        }
        break;
        
      default:
        throw new Error(`알 수 없는 액션: ${data.action}`);
    }
  } catch (error) {
    self.postMessage({
      id: data.id,
      error: error.message
    });
  }
}; 