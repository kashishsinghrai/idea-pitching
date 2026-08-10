import { Request, Response } from 'express';
import { PrismaClient } from '@prisma/client';
import { AuthRequest } from '../middlewares/auth.middleware';

const prisma = new PrismaClient(); // Trigger TS refresh


// ── Profile Settings ──────────────────────────────────────────────────

export const updateProfile = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const userId = req.user?.userId;
    if (!userId) {
      res.status(401).json({ message: 'Unauthorized' });
      return;
    }

    const {
      firstName,
      lastName,
      companyName, // Founders can use this as their Startup Name / Company Name
      role,
      notifyNewDeals, // Re-used for Founder notifications if needed
      notifyMessages,
      notifyNdaStatus,
    } = req.body;

    const updatedProfile = await prisma.profile.update({
      where: { userId },
      data: {
        firstName,
        lastName,
        companyName,
        role,
        notifyNewDeals,
        notifyMessages,
        notifyNdaStatus,
      },
    });

    res.status(200).json({ message: 'Profile updated successfully', profile: updatedProfile });
  } catch (error) {
    console.error('Error updating founder profile:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
};

export const getProfile = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const userId = req.user?.userId;
    if (!userId) {
      res.status(401).json({ message: 'Unauthorized' });
      return;
    }

    const profile = await prisma.profile.findUnique({
      where: { userId },
    });

    res.status(200).json({ profile });
  } catch (error) {
    console.error('Error getting founder profile:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
};
