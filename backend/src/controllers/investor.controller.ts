import { Request, Response } from 'express';
import { PrismaClient } from '@prisma/client';
import { AuthRequest } from '../middlewares/auth.middleware';

const prisma = new PrismaClient();

// ── Watchlist (Saved Deals) ──────────────────────────────────────────

export const toggleSavedDeal = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const userId = req.user?.userId;
    const { pitchId } = req.body;

    if (!userId || !pitchId) {
      res.status(400).json({ message: 'Missing userId or pitchId' });
      return;
    }

    const existing = await prisma.savedDeal.findUnique({
      where: {
        userId_pitchId: {
          userId,
          pitchId,
        },
      },
    });

    if (existing) {
      await prisma.savedDeal.delete({
        where: { id: existing.id },
      });
      res.status(200).json({ message: 'Removed from watchlist', saved: false });
    } else {
      await prisma.savedDeal.create({
        data: {
          userId,
          pitchId,
        },
      });
      res.status(200).json({ message: 'Added to watchlist', saved: true });
    }
  } catch (error) {
    console.error('Error toggling saved deal:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
};

export const getSavedDeals = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const userId = req.user?.userId;
    if (!userId) {
      res.status(401).json({ message: 'Unauthorized' });
      return;
    }

    const savedDeals = await prisma.savedDeal.findMany({
      where: { userId },
      include: {
        pitch: {
          include: {
            founder: {
              select: {
                id: true,
                email: true,
                profile: {
                  select: {
                    firstName: true,
                    lastName: true,
                    companyName: true,
                  },
                },
              },
            },
          },
        },
      },
      orderBy: { createdAt: 'desc' },
    });

    const pitches = savedDeals.map((sd) => sd.pitch);
    res.status(200).json({ pitches });
  } catch (error) {
    console.error('Error getting saved deals:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
};

// ── NDA & VDR ────────────────────────────────────────────────────────

export const signNda = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const userId = req.user?.userId;
    const { pitchId } = req.body;

    if (!userId || !pitchId) {
      res.status(400).json({ message: 'Missing userId or pitchId' });
      return;
    }

    const existing = await prisma.ndaSignature.findUnique({
      where: {
        userId_pitchId: {
          userId,
          pitchId,
        },
      },
    });

    if (existing) {
      res.status(400).json({ message: 'NDA already signed for this pitch' });
      return;
    }

    const nda = await prisma.ndaSignature.create({
      data: {
        userId,
        pitchId,
      },
    });

    res.status(200).json({ message: 'NDA signed successfully', nda });
  } catch (error) {
    console.error('Error signing NDA:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
};

export const getNdaStatus = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const userId = req.user?.userId;
    const { pitchId } = req.params;

    if (!userId || !pitchId) {
      res.status(400).json({ message: 'Missing userId or pitchId' });
      return;
    }

    const nda = await prisma.ndaSignature.findUnique({
      where: {
        userId_pitchId: {
          userId,
          pitchId,
        },
      },
    });

    res.status(200).json({ signed: !!nda, nda });
  } catch (error) {
    console.error('Error getting NDA status:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
};

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
      firmName,
      role,
      notifyNewDeals,
      notifyMessages,
      notifyNdaStatus,
    } = req.body;

    const updatedProfile = await prisma.profile.update({
      where: { userId },
      data: {
        firstName,
        lastName,
        firmName,
        role,
        notifyNewDeals,
        notifyMessages,
        notifyNdaStatus,
      },
    });

    res.status(200).json({ message: 'Profile updated successfully', profile: updatedProfile });
  } catch (error) {
    console.error('Error updating profile:', error);
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
    console.error('Error getting profile:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
};

// ── Investments (Portfolio) ──────────────────────────────────────────

export const getInvestments = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const userId = req.user?.userId;
    if (!userId) {
      res.status(401).json({ message: 'Unauthorized' });
      return;
    }

    const investments = await prisma.investment.findMany({
      where: { investorId: userId },
      include: {
        pitch: {
          include: {
            founder: {
              select: {
                id: true,
                profile: {
                  select: {
                    firstName: true,
                    lastName: true,
                  },
                },
              },
            },
          },
        },
      },
      orderBy: { createdAt: 'desc' },
    });

    res.status(200).json({ investments });
  } catch (error) {
    console.error('Error getting investments:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
};
