import { z } from 'zod';

export const structuredFormSchema = z.object({
  name: z.string().min(1, 'Name is required').max(100, 'Name too long'),
  email: z.string().min(1, 'Email is required').email('Invalid email address'),
  phone: z
    .string()
    .min(1, 'Phone is required')
    .regex(/^\+?[\d\s\-().]{7,20}$/, 'Invalid phone number'),
  sport: z.string().min(1, 'Sport is required').max(50, 'Sport name too long'),
});

export type StructuredFormSchema = z.infer<typeof structuredFormSchema>;

export const freetextFormSchema = z.object({
  rawInput: z.string().min(1, 'Input is required').max(2000, 'Input too long'),
});

export type FreetextFormSchema = z.infer<typeof freetextFormSchema>;
