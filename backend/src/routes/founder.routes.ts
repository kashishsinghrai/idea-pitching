import { Router } from 'express';
import { requireAuth } from '../middlewares/auth.middleware';
import { getProfile, updateProfile } from '../controllers/founder.controller';

const router = Router();

// Profile Routes
router.get('/profile', requireAuth, getProfile);
router.put('/profile', requireAuth, updateProfile);

export default router;
