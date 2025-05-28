import * as admin from 'firebase-admin';
import { readFileSync } from 'fs';

const serviceAccount = JSON.parse(
  readFileSync('src/config/firebase-service-account.json', 'utf8'),
);

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

export default admin;
