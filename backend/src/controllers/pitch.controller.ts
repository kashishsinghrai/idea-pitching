import { Request, Response } from 'express';
import { PrismaClient } from '@prisma/client';
import { AuthRequest } from '../middlewares/auth.middleware';

const prisma = new PrismaClient();

export const createPitch = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const userId = req.user?.userId;
    if (!userId) {
      res.status(401).json({ message: 'Unauthorized' });
      return;
    }

    const {
      startupName,
      industry,
      stage,
      tagline,
      description,
      askAmount,
      valuation,
      videoUrl
    } = req.body;

    const files = req.files as { [fieldname: string]: Express.Multer.File[] };
    const pitchDeckUrl = files?.['pitchDeck']?.[0]?.path;
    const executiveSummaryUrl = files?.['executiveSummary']?.[0]?.path;

    // Check if founder already has a pitch
    const existingPitch = await prisma.pitch.findUnique({
      where: { founderId: userId }
    });

    if (existingPitch) {
      res.status(400).json({ message: 'You have already submitted a pitch.' });
      return;
    }

    const pitch = await prisma.pitch.create({
      data: {
        founderId: userId,
        startupName,
        industry,
        stage,
        tagline,
        description,
        askAmount: Number(askAmount),
        valuation: Number(valuation),
        videoUrl, // new URL string from frontend
        pitchDeckUrl,
        executiveSummaryUrl,
        status: 'PENDING'
      }
    });

    res.status(201).json({ message: 'Pitch submitted successfully', pitch });
  } catch (error) {
    console.error('Error creating pitch:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
};

export const getMyPitches = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const userId = req.user?.userId;
    if (!userId) {
      res.status(401).json({ message: 'Unauthorized' });
      return;
    }

    const pitches = await prisma.pitch.findMany({
      where: { founderId: userId },
      orderBy: { createdAt: 'desc' }
    });

    res.status(200).json({ data: pitches });
  } catch (error) {
    console.error('Error fetching my pitches:', error);
    res.status(500).json({ error: 'Failed to fetch pitches' });
  }
};

export const getDealFlow = async (req: Request, res: Response): Promise<void> => {
  try {
    const { industry, stage } = req.query;

    const filters: any = {
      status: 'APPROVED'
    };

    if (industry) {
      filters.industry = String(industry);
    }
    
    if (stage) {
      filters.stage = String(stage);
    }

    const pitches = await prisma.pitch.findMany({
      where: filters,
      include: {
        founder: {
          select: {
            id: true,
            email: true,
            profile: {
              select: {
                firstName: true,
                lastName: true,
                companyName: true
              }
            }
          }
        }
      },
      orderBy: {
        createdAt: 'desc'
      }
    });

    res.json({ pitches });
  } catch (error) {
    console.error('Error fetching deal flow:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
};
