import { Router } from 'express';
import { register, login } from '../controllers/auth.controller';
import { requireAuth, requireRole } from '../middlewares/auth.middleware';
import { Role } from '@prisma/client';

const router = Router();

// Public routes
router.post('/register', register);
router.post('/login', login);

// Example protected route (for testing)
router.get('/me', requireAuth, (req, res) => {
  res.status(200).json({ message: 'You are authenticated!', user: (req as any).user });
});

// Example RBAC protected route (for testing)
router.get('/admin-only', requireAuth, requireRole([Role.ADMIN]), (req, res) => {
  res.status(200).json({ message: 'Welcome to the admin portal.' });
});

export default router;
