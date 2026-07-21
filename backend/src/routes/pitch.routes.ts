import { Router } from 'express';
import multer from 'multer';
import { createPitch, getMyPitches, getDealFlow } from '../controllers/pitch.controller';
import { requireAuth, requireRole } from '../middlewares/auth.middleware';
import { Role } from '@prisma/client';

const router = Router();

const upload = multer({ dest: 'uploads/' });

// Create a new pitch (Founders only)
router.post(
  '/',
  requireAuth,
  requireRole([Role.FOUNDER]),
  upload.fields([{ name: 'pitchDeck', maxCount: 1 }, { name: 'executiveSummary', maxCount: 1 }]),
  createPitch
);

// Get my pitch (Founders only)
router.get(
  '/me',
  requireAuth,
  requireRole([Role.FOUNDER]),
  getMyPitches
);

// Get deal flow (Investors and Admins only)
router.get(
  '/deal-flow',
  requireAuth,
  requireRole([Role.INVESTOR, Role.ADMIN]),
  getDealFlow
);

export default router;
