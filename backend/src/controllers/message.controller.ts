import { Request, Response } from 'express';
import { PrismaClient } from '@prisma/client';
import { AuthRequest } from '../middlewares/auth.middleware';

const prisma = new PrismaClient(); // Trigger TS refresh again



export const getConversations = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const userId = req.user?.userId;
    if (!userId) {
      res.status(401).json({ message: 'Unauthorized' });
      return;
    }

    // A conversation is typically linked to a pitch and between founder and investor.
    // For simplicity, we fetch all messages where user is sender or receiver.
    // Then we group them by the "other" user and pitchId.

    const messages = await prisma.message.findMany({
      where: {
        OR: [
          { senderId: userId },
          { receiverId: userId },
        ],
      },
      include: {
        sender: {
          select: {
            id: true,
            profile: { select: { firstName: true, lastName: true, companyName: true, firmName: true } },
          },
        },
        receiver: {
          select: {
            id: true,
            profile: { select: { firstName: true, lastName: true, companyName: true, firmName: true } },
          },
        },
        pitch: {
          select: { id: true, startupName: true },
        },
      },
      orderBy: { createdAt: 'desc' },
    });

    // Grouping logic
    const conversationsMap = new Map<string, any>();

    for (const msg of messages) {
      const isSender = msg.senderId === userId;
      const otherUser = isSender ? msg.receiver : msg.sender;
      const otherUserId = otherUser.id;
      const pitchId = msg.pitchId;
      const convKey = `${otherUserId}_${pitchId}`;

      if (!conversationsMap.has(convKey)) {
        const profile = otherUser.profile;
        const name = `${profile?.firstName || ''} ${profile?.lastName || ''}`.trim() || 'Unknown';
        const company = profile?.companyName || profile?.firmName || msg.pitch.startupName;

        conversationsMap.set(convKey, {
          id: convKey,
          otherUserId,
          pitchId,
          name,
          company,
          lastMessage: msg.text,
          timeAgo: msg.createdAt, // Frontend will format this
          isUnread: !isSender && msg.isUnread, // Unread if we received it and it's unread
          initial: name ? name[0].toUpperCase() : 'U',
          messages: [],
        });
      }

      // Add message to conversation
      const conv = conversationsMap.get(convKey);
      conv.messages.unshift({ // unshift because we iterate from newest to oldest, but want array oldest to newest
        id: msg.id,
        text: msg.text,
        fromMe: isSender,
        time: msg.createdAt,
      });
    }

    const conversations = Array.from(conversationsMap.values());

    res.status(200).json({ conversations });
  } catch (error) {
    console.error('Error fetching conversations:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
};

export const sendMessage = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const senderId = req.user?.userId;
    if (!senderId) {
      res.status(401).json({ message: 'Unauthorized' });
      return;
    }

    const { receiverId, pitchId, text } = req.body;

    if (!receiverId || !pitchId || !text) {
      res.status(400).json({ message: 'Missing required fields' });
      return;
    }

    const message = await prisma.message.create({
      data: {
        senderId,
        receiverId,
        pitchId,
        text,
        isUnread: true,
      },
      include: {
        sender: {
          select: {
            id: true,
            profile: { select: { firstName: true, lastName: true } },
          },
        },
      }
    });

    res.status(201).json({ message });
  } catch (error) {
    console.error('Error sending message:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
};
