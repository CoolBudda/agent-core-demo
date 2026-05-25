import apiClient from '../../../services/api/client';
import type { StructuredFormData, ValidationResult } from '../../../types';

export async function validateStructuredForm(
  data: StructuredFormData
): Promise<ValidationResult> {
  const response = await apiClient.post<ValidationResult>(
    '/validate/structured',
    data
  );
  return response.data;
}
