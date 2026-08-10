import { Router } from 'express';
import { getConversations, sendMessage } from '../controllers/message.controller';
import { requireAuth } from '../middlewares/auth.middleware';

const router = Router();

router.get('/conversations', requireAuth, getConversations);
router.post('/send', requireAuth, sendMessage);

export default router;
