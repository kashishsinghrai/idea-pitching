import { Router } from 'express';
import {
  toggleSavedDeal,
  getSavedDeals,
  signNda,
  getNdaStatus,
  updateProfile,
  getProfile,
  getInvestments,
} from '../controllers/investor.controller';
import { requireAuth, requireRole } from '../middlewares/auth.middleware';
import { Role } from '@prisma/client';

const router = Router();

// Require investor or founder authentication for most of these
// Settings apply to both, but Investments and SavedDeals are investor-heavy.

// Watchlist (Saved Deals)
router.post('/watchlist/toggle', requireAuth, toggleSavedDeal);
router.get('/watchlist', requireAuth, getSavedDeals);

// NDA
router.post('/nda/sign', requireAuth, signNda);
router.get('/nda/status/:pitchId', requireAuth, getNdaStatus);

// Profile
router.put('/profile', requireAuth, updateProfile);
router.get('/profile', requireAuth, getProfile);

// Investments
router.get('/investments', requireAuth, requireRole([Role.INVESTOR, Role.ADMIN]), getInvestments);

export default router;
