import apiClient from '../../../services/api/client';
import type { FreetextFormData, ValidationResult } from '../../../types';

export async function validateFreetextForm(
  data: FreetextFormData
): Promise<ValidationResult> {
  const response = await apiClient.post<ValidationResult>(
    '/validate/freetext',
    data
  );
  return response.data;
}
