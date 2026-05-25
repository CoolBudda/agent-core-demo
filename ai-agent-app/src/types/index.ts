export interface StructuredFormData {
  name: string;
  email: string;
  phone: string;
  sport: string;
}

export interface FreetextFormData {
  rawInput: string;
}

export interface ValidationResult {
  status: 'valid' | 'invalid' | 'pending';
  message: string;
  details?: string[];
}
