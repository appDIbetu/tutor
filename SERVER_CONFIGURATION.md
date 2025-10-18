# Server Configuration Examples

## Node.js Server Example

### 1. Install Dependencies
```bash
npm install firebase-admin express cors dotenv
```

### 2. Create server.js
```javascript
const admin = require('firebase-admin');
const express = require('express');
const cors = require('cors');
require('dotenv').config();

const app = express();
app.use(cors());
app.use(express.json());

// Initialize Firebase Admin
const serviceAccount = {
  type: "service_account",
  project_id: process.env.FIREBASE_PROJECT_ID,
  private_key_id: process.env.FIREBASE_PRIVATE_KEY_ID,
  private_key: process.env.FIREBASE_PRIVATE_KEY.replace(/\\n/g, '\n'),
  client_email: process.env.FIREBASE_CLIENT_EMAIL,
  client_id: process.env.FIREBASE_CLIENT_ID,
  auth_uri: "https://accounts.google.com/o/oauth2/auth",
  token_uri: "https://oauth2.googleapis.com/token",
  auth_provider_x509_cert_url: "https://www.googleapis.com/oauth2/v1/certs",
  client_x509_cert_url: `https://www.googleapis.com/robot/v1/metadata/x509/${process.env.FIREBASE_CLIENT_EMAIL}`
};

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  projectId: process.env.FIREBASE_PROJECT_ID
});

// Middleware to verify Firebase ID token
async function verifyToken(req, res, next) {
  try {
    const idToken = req.headers.authorization?.split('Bearer ')[1];
    
    if (!idToken) {
      return res.status(401).json({ error: 'No token provided' });
    }

    const decodedToken = await admin.auth().verifyIdToken(idToken);
    req.user = decodedToken;
    next();
  } catch (error) {
    console.error('Error verifying token:', error);
    return res.status(401).json({ error: 'Invalid token' });
  }
}

// Protected route example
app.get('/api/user/profile', verifyToken, async (req, res) => {
  try {
    const uid = req.user.uid;
    const userRecord = await admin.auth().getUser(uid);
    
    res.json({
      uid: userRecord.uid,
      email: userRecord.email,
      displayName: userRecord.displayName,
      photoURL: userRecord.photoURL
    });
  } catch (error) {
    console.error('Error getting user profile:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Exam result submission
app.post('/api/exam-results', verifyToken, async (req, res) => {
  try {
    const { examId, score, answers, timeSpent } = req.body;
    const uid = req.user.uid;
    
    // Save exam result to your database
    // Example: await saveExamResult(uid, examId, score, answers, timeSpent);
    
    res.json({ 
      success: true, 
      message: 'Exam result saved successfully',
      examId,
      score 
    });
  } catch (error) {
    console.error('Error saving exam result:', error);
    res.status(500).json({ error: 'Failed to save exam result' });
  }
});

// User profile update
app.put('/api/user/profile', verifyToken, async (req, res) => {
  try {
    const uid = req.user.uid;
    const { name, mobile, address } = req.body;
    
    // Update user profile in your database
    // Example: await updateUserProfile(uid, { name, mobile, address });
    
    res.json({ 
      success: true, 
      message: 'Profile updated successfully' 
    });
  } catch (error) {
    console.error('Error updating profile:', error);
    res.status(500).json({ error: 'Failed to update profile' });
  }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
```

### 3. Create .env file
```env
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_PRIVATE_KEY_ID=your-private-key-id
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\nYOUR_PRIVATE_KEY\n-----END PRIVATE KEY-----\n"
FIREBASE_CLIENT_EMAIL=firebase-adminsdk-xxxxx@your-project-id.iam.gserviceaccount.com
FIREBASE_CLIENT_ID=your-client-id
PORT=3000
```

## Python Server Example

### 1. Install Dependencies
```bash
pip install firebase-admin flask flask-cors python-dotenv
```

### 2. Create server.py
```python
from flask import Flask, request, jsonify
from flask_cors import CORS
import firebase_admin
from firebase_admin import credentials, auth
import os
from dotenv import load_dotenv

load_dotenv()

app = Flask(__name__)
CORS(app)

# Initialize Firebase Admin
cred = credentials.Certificate({
    "type": "service_account",
    "project_id": os.getenv('FIREBASE_PROJECT_ID'),
    "private_key_id": os.getenv('FIREBASE_PRIVATE_KEY_ID'),
    "private_key": os.getenv('FIREBASE_PRIVATE_KEY').replace('\\n', '\n'),
    "client_email": os.getenv('FIREBASE_CLIENT_EMAIL'),
    "client_id": os.getenv('FIREBASE_CLIENT_ID'),
    "auth_uri": "https://accounts.google.com/o/oauth2/auth",
    "token_uri": "https://oauth2.googleapis.com/token",
    "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
    "client_x509_cert_url": f"https://www.googleapis.com/robot/v1/metadata/x509/{os.getenv('FIREBASE_CLIENT_EMAIL')}"
})

firebase_admin.initialize_app(cred)

def verify_token(f):
    def decorated_function(*args, **kwargs):
        try:
            auth_header = request.headers.get('Authorization')
            if not auth_header or not auth_header.startswith('Bearer '):
                return jsonify({'error': 'No token provided'}), 401
            
            id_token = auth_header.split('Bearer ')[1]
            decoded_token = auth.verify_id_token(id_token)
            request.user = decoded_token
            return f(*args, **kwargs)
        except Exception as e:
            print(f'Error verifying token: {e}')
            return jsonify({'error': 'Invalid token'}), 401
    return decorated_function

@app.route('/api/user/profile', methods=['GET'])
@verify_token
def get_user_profile():
    try:
        uid = request.user['uid']
        user_record = auth.get_user(uid)
        
        return jsonify({
            'uid': user_record.uid,
            'email': user_record.email,
            'displayName': user_record.display_name,
            'photoURL': user_record.photo_url
        })
    except Exception as e:
        print(f'Error getting user profile: {e}')
        return jsonify({'error': 'Internal server error'}), 500

@app.route('/api/exam-results', methods=['POST'])
@verify_token
def submit_exam_result():
    try:
        data = request.get_json()
        exam_id = data.get('examId')
        score = data.get('score')
        answers = data.get('answers')
        time_spent = data.get('timeSpent')
        uid = request.user['uid']
        
        # Save exam result to your database
        # Example: save_exam_result(uid, exam_id, score, answers, time_spent)
        
        return jsonify({
            'success': True,
            'message': 'Exam result saved successfully',
            'examId': exam_id,
            'score': score
        })
    except Exception as e:
        print(f'Error saving exam result: {e}')
        return jsonify({'error': 'Failed to save exam result'}), 500

@app.route('/api/user/profile', methods=['PUT'])
@verify_token
def update_user_profile():
    try:
        data = request.get_json()
        name = data.get('name')
        mobile = data.get('mobile')
        address = data.get('address')
        uid = request.user['uid']
        
        # Update user profile in your database
        # Example: update_user_profile(uid, name, mobile, address)
        
        return jsonify({
            'success': True,
            'message': 'Profile updated successfully'
        })
    except Exception as e:
        print(f'Error updating profile: {e}')
        return jsonify({'error': 'Failed to update profile'}), 500

if __name__ == '__main__':
    app.run(debug=True, port=3000)
```

## Testing Your Server

### Test with curl
```bash
# Get ID token from your Flutter app (check console logs)
ID_TOKEN="your-id-token-here"

# Test protected endpoint
curl -H "Authorization: Bearer $ID_TOKEN" \
     http://localhost:3000/api/user/profile

# Test exam result submission
curl -X POST \
     -H "Authorization: Bearer $ID_TOKEN" \
     -H "Content-Type: application/json" \
     -d '{"examId":"SET001","score":85,"answers":{"1":"A","2":"B"},"timeSpent":1800}' \
     http://localhost:3000/api/exam-results
```

## Database Schema Examples

### User Profile Table
```sql
CREATE TABLE user_profiles (
    uid VARCHAR(255) PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    name VARCHAR(255),
    mobile VARCHAR(20),
    address TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

### Exam Results Table
```sql
CREATE TABLE exam_results (
    id INT AUTO_INCREMENT PRIMARY KEY,
    uid VARCHAR(255) NOT NULL,
    exam_id VARCHAR(50) NOT NULL,
    score INT NOT NULL,
    total_questions INT NOT NULL,
    answers JSON,
    time_spent INT NOT NULL,
    completed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (uid) REFERENCES user_profiles(uid)
);
```

## Deployment Considerations

### Environment Variables
- Use different Firebase projects for development, staging, and production
- Store sensitive keys in environment variables, not in code
- Use a secrets management service for production

### Security
- Always verify ID tokens on the server
- Implement rate limiting
- Use HTTPS in production
- Validate all input data

### Monitoring
- Set up Firebase Performance Monitoring
- Use Firebase Crashlytics for error tracking
- Monitor server logs and metrics
