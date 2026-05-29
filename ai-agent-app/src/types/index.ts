export interface StructuredFormData {
  name: string;
  email: string;
  phone: string;
  sport: string;
}

export interface FreetextFormData {
  rawInput: string;
  sessionId: string;
}

export interface ValidationResult {
  status: 'success' | 'missing';
  message: string;
  details?: string[];
}
